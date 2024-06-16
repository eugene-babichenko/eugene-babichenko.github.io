---
layout: post
title: Generating pretty version strings (including nightly) with Git and Makefiles
date: 2019-09-28 16:45:00+03:00
categories: git makefile golang
---

In my recent project, I faced the need to generate pretty version numbers for my
local and nightly builds. Here I will describe the approach I came up with. In
this tutorial, we will use Git, which stores version tags and the entire setup
uses Makefiles. However, you should be able to adapt this approach to any build
system.

In the end, we will be able to get pretty and very informative version strings
like `0.2.1-next-314da12-20190928`.

You can check out the code from this article in [this Gist][gist].

First of all, we need to have versions based on git tags. Here, I will assume
that version tags are in the format `v0.1.2`. Given that, we can extract the
latest tag and strip the `v`:

```makefile
TAG_COMMIT := $(shell git rev-list --abbrev-commit --tags --max-count=1)
# `2>/dev/null` suppress errors and `|| true` suppress the error codes.
TAG := $(shell git describe --abbrev=0 --tags ${TAG_COMMIT} 2>/dev/null || true)
# here we strip the version prefix
VERSION := $(TAG:v%=%)
```

This script will not fail if there are no tags in the current repository, but
this will generate an empty version string. In this case, we can build a version
string from the latest git commit hash and add the commit date for additional
info:

```makefile
# get the latest commit hash in the short form
COMMIT := $(shell git rev-parse --short HEAD)
# get the latest commit date in the form of YYYYmmdd
DATE := $(shell git log -1 --format=%cd --date=format:"%Y%m%d")
# check if the version string is empty
ifeq $(VERSION,)
	VERSION := $(COMMIT)-$(DATA)
endif
```

This will give us a version string in a format like `314da12-20190928` which
gives us pretty much information about the build. Particularly, when the change
was made and which commit we should look for.

On top of that, we can deal with nightly builds that appeared after a particular
version like that: `0.2.1-next-314da12-20190928`. This line contains even more
information as it includes the last stable version. We can quickly grab the
version number and compare our changes to it to see what went wrong. This is how
we generate this:

```makefile
ifneq ($(COMMIT), $(TAG_COMMIT))
	VERSION := $(VERSION)-next-$(COMMIT)-$(DATE)
endif
```

Finally, we can indicate that we were building from a dirty git state (e.g. we
had uncommitted changes during the build):

```makefile
# git status --porcelain outputs a machine-readable text and the output is empty
# if the working tree is clean
ifneq ($(shell git status --porcelain),)
	VERSION := $(VERSION)-dirty
endif
```

This is how the script looks in the end:

```makefile
TAG_COMMIT := $(shell git rev-list --abbrev-commit --tags --max-count=1)
TAG := $(shell git describe --abbrev=0 --tags ${TAG_COMMIT} 2>/dev/null || true)
COMMIT := $(shell git rev-parse --short HEAD)
DATE := $(shell git log -1 --format=%cd --date=format:"%Y%m%d")
VERSION := $(TAG:v%=%)
ifneq ($(COMMIT), $(TAG_COMMIT))
	VERSION := $(VERSION)-next-$(COMMIT)-$(DATE)
endif
ifeq $(VERSION,)
	VERSION := $(COMMIT)-$(DATA)
endif
ifneq ($(shell git status --porcelain),)
	VERSION := $(VERSION)-dirty
endif
```

That's all! For me, this looks very good, because it does not use any additional
tools apart from Git and `make`. Hope you will find this useful!

As a bonus, I would like to show how I integrate that with Go builds.

First, you need to specify the `version` variable in your `main` package (I do
it exactly this way because this is compatible with GoReleaser):

```go
package main

import (
	// ...
)

var version = "dev"

func main() {
	// ...
}
```

And this is my `Makefile` for filling in that variable

```makefile
FLAGS := -ldflags "-X main.version=$(VERSION)"

build:
	go build $(FLAGS) -o projectname-$(VERSION) main.go

run:
	go run $(FLAGS) main.go

install:
	go install $(FLAGS)
```

[gist]: https://gist.github.com/eugene-babichenko/f37d15626160914427563dff2edd57ed
