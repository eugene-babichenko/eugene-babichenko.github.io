---
layout: post
title:  "Building tiny Docker images with multi-stage builds"
date:   2018-08-11 18:42:00 +0300
categories: docker tutorials
---

The big issue with Docker images is that they tend to get **really** big. Big projects can have so much build time dependencies and generated garbage that we may end up with images of, let's say, from thousands of megabytes to gigabytes. This can make virtualization pretty painful because it hurts just to wait until the image is downloaded from a Docker registry.

What can help us to get around those issues?

Let's start with an example. Suppose we have a Python application that uses some crypto stuff and runs a web server inside of it.

So here is our `Dockerfile`:

```dockerfile
# This base image contains stuff like OpenSSL and all of *-dev libraries
FROM python:latest
WORKDIR /project

# Copy and install the list of dependencies separately to speed the things up
COPY ./requirements.txt .
RUN pip3 install -r ./requirements.txt

# The rest is not interesting for us
```

And this is our `requirements.txt`:

```
cryptography
aiohttp
```

Pretty simple, huh? However, when we build this and check out the size of the image we have... Oops, **956MB** for a project with only two explicitly specified dependencies.

What we can do is to move to a slimmer base image. The best fit for Docker images is [Alpine Linux](https://alpinelinux.org/). With only Busybox, [musl](https://www.musl-libc.org/) (libc implementation), [libressl](https://www.libressl.org/) (OpenSSL compatible crypto) and apk (package manager) it is **5MB** unpacked.

```dockerfile
FROM alpine:edge
RUN apk --update --no-cache add pkgconf build-base autoconf automake python3 python3-dev libffi-dev libressl-dev
COPY ./requirements.txt .
RUN pip3 install -r ./requirements.txt
```

Here we need to handle a lot of dependencies manually, but now it's **295MB**. We just cut down our image by more than **3 times**!

Now we can move further. We definitely don't need all of the dependencies that are required for building the project. Here are two options for how to deal with them:

1. Remove them manually (apk even have syntactic sugar for that called virtual packages) and then squash layers together by using software like [docker-squash](https://github.com/jwilder/docker-squash).
1. Instead, we can use the feature of Docker called [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/).

The last variant seems better because it doesn't involve additional software, so let's try it:

```dockerfile
# In this stage called `build` we install just everything and build the project.
FROM alpine:edge as build
RUN apk --update --no-cache add pkgconf build-base autoconf automake python3 python3-dev libffi-dev libressl-dev
# Create a custom directory for installing Python packages
RUN mkdir /install
ENV PYTHONUSERBASE=/install
COPY ./requirements.txt .
RUN pip3 install --user -r ./requirements.txt

# Start an image from scratch...
FROM alpine:edge as release
# Install only necessary dependencies
RUN apk --update --no-cache add python3 libffi
# Copy installed dependencies from the previous stage
COPY --from=build /install /install
ENV PYTHONUSERBASE=/install
```

And now we have just **70.5MB**! The image size was cut down **more than 10 times**.

To sum up, the approach for building a minimal Docker image is the following:

1. Use some minimal image as the base. Alpine Linux is a good one.
1. Create a build stage with all of the dependencies required for both building and running your software.
1. Build your software in this image.
1. Then create a separate build stage from the base image.
1. Install the minimal set of dependencies required for running your application.
1. Use the `copy from` feature to copy the built software to the release image.
1. ...
1. PROFIT
