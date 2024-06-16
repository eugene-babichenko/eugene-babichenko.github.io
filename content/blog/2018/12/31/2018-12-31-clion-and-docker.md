---
layout: post
title:
  "Using CLion to develop C/C++ applications in Docker (or any other remote
  development)"
date: 2018-12-31 19:35:00+03:00
categories: tutorials docker clion
extra:
  toc: true
---

We often use Docker in development for a variety of reasons: to work on the
production-like environment, to isolate the application, etc. In particular, I
use Docker for Mac to develop applications that are intended to be run on Linux.
Along with bash scripts to set up the environment, it allows not to work with
VMs (well, virtually, because Docker for Mac runs in the VM that is not exposed
to an end-user) and also gives me a bunch of isolated lightweight working
environments. Unfortunately, there is a downside: poor IDE support. And while
IDEs like PyCharm handle that pretty well with its [Remote Interpreters][1]
feature, CLion have not gone that far yet. However, there is the [Remote
Projects][2] feature that allows us to work on any machine that exposes SSH and
ports required by debuggers and any other software. In this tutorial, I will
review the Docker-based approach. However, you can omit the Docker part and go
with the same setup for your VM or remote server.

## Prerequisites

- CLion 2018.3
- Docker

## Building your Dockerfile

First of all, we need to define what will you need to install into your
development environment:

- `rsync` if your host is macOS or Linux;
- `make`, `cmake`, `gdb` and compilers -- those are essential;
- SSH server;
- Optionally you can add `valgrind` and any other dependency required by your
  process.

So let's write a simple Dockerfile:

```dockerfile
FROM ubuntu:bionic
RUN apt-get update && \
    apt-get install -y build-essential cmake gdb openssh-server python
# This allows you to log in as the root user and your password will be `root`
RUN echo 'root:root' | chpasswd && \
    mkdir /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
EXPOSE 22 63342
# -D flag runs sshd in foreground
CMD ["/usr/sbin/sshd", "-D"]
```

Build it, tag it, run it:
`docker run -p 2222:22 -p 63342:63342 --security-opt seccomp:unconfined yourimagetag`.
`seccomp:unconfined` is required to run a debugger.

To verify that you have access to SSH run `ssh -p 2222 root@localhost`, you
should be able to log in with the password root. If you can, then you can move
to the next step.

You can also combine this approach with [Docker multi-stage builds][4] to
separate your environments.

## CLion setup

This part mostly repeats the [official guide][2] to CLion Remote Project.

1. Add a new toolchain. Near the **Name** field select the **Remote host
   option**. Then enter the SSH credentials of the running container and wait
   until CLion detects all the software.

   ![CLion remote toolchain setup][image-1]

1. Add a new CMake configuration. You just need to copy the existing one and
   change the toolchain to the one you have added in the previous step.

   ![CLion custom toolchain configuration][image-2]

1. Finally, wait for some time until CLion builds the index for the remote
   environment and switch to it in **Run Configurations**.

   ![Selecting the appropriate run configration][image-4]

## Conclusion

Congrats, now you are all set for a painless Docker/remote/VM-based C++
development! This is a pretty good approach until full-featured Docker support
arrives in CLion. Now when you want to develop your dockerized application you
just need to run your container and wait for CLion to connect to it.

## Acknowledgements

- [C-program with CLion and Docker containers][3] -- for the general idea.

## Useful links

- [CLion Remote Projects][2]

[1]:
  https://www.jetbrains.com/help/pycharm/using-docker-as-a-remote-interpreter.html
[2]: https://www.jetbrains.com/help/clion/remote-projects-support.html
[3]: http://ebagdasa.me/2017-01-20/docker-clion-debugging/
[4]: https://docs.docker.com/develop/develop-images/multistage-build/
[image-1]: /assets/2018-12-31-clion-and-docker-image-1.png
[image-2]: /assets/2018-12-31-clion-and-docker-image-2.png
[image-4]: /assets/2018-12-31-clion-and-docker-image-4.png
