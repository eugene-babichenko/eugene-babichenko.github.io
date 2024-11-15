+++
title = "Rust code coverage without 3rd party utilities"
date = 2024-11-15T21:05:53+02:00
[extra]
toc = true
+++

Today I got fed up with my CI being slow and dealing with overall clunkiness of
coverage software. So I decided to finally give a read to the amazing
["Instrumentation-based Code Coverage"](https://doc.rust-lang.org/rustc/instrument-coverage.html)
article from the rustc book. And while it is pretty exhaustive, some parts of it
are not very up to date, some may be done nicer (e.g. without the use of 3rd
party tools in your CI), and some important practical aspects are not covered by
it at all (interfacing with code coverage services). So let's dive into it!

## The Basics

The entire approach is built around LLVM
[source-based code coverage instrumentation](https://clang.llvm.org/docs/SourceBasedCodeCoverage.html).
This thing is fairly straightforward: you add a flag when building your program
and when you run it, it outputs the profiling information. For Rust it is done
like that:

```bash
export RUSTFLAGS="-C instrument-coverage"
cargo test # or cargo build, or cargo run
```

If you check your project directory after running this, you will see one more
files that look like this:

```
default_16297040162499240015_0_10889.profraw
```

These are outputs from the profiler instrumentation that got built into your
application and test binaries.

By themselves, they are not of much use and we need to generate a _profile data
file_. For that, we need the tools:

```bash
rustup component add llvm-tools
```

In theory, we could use the tools that come with the standard LLVM distribution.
But we have something guaranteed to work with what rustc produces, so why
bother? Anyway, at this point the rustc book recommends us to install
`cargo-binutils`. This tool is needed because `llvm-tools` don't get exposed via
the `PATH` variable to avoid conflicts with the actual LLVM installation that
may be present in your system. And I am not against convenience, but when
running inside of CI this convenience becomes a liability: this is something
that takes time to install and is a potential security hole.

So, after some digging on my own machine I found these tools residing at
`~/.rustup/toolchains/stable-aarch64-apple-darwin/lib/rustlib/aarch64-apple-darwin/bin/`.
After a bit of digging and talking to Claude, I came up with this abomination to
add the tools to `PATH`:

```bash
toolchain="$(grep '^default_toolchain' $HOME/.rustup/settings.toml | cut -d'"' -f2)"
PATH="$HOME/.rustup/toolchains/$toolchain/lib/rustlib/${toolchain#*-}/bin:$PATH"
```

It just takes the name of the currently active toolchain and finds the directory
where the `llvm-tools` component lives. If you need to adjust it to support
multiple toolchains, I'll leave it up to you.

With that out of the way, we can finally build the needed file:

```bash
llvm-profdata merge -sparse default_*.profraw -o tests.profdata
```

And `tests.profdata` is going to be the source of any visualization we want to
do.

First, let's try and output a simple table with code coverage data per file and
a summary per the rustc book recommendations:

```bash
llvm-cov report --use-color --ignore-filename-regex='/.cargo/registry' -instr-profile tests.profdata $objects
```

But hey, what is this `objects` variable? Well, you need to list the test
binaries in the format of `--object <binary>`. And this is our second deviation
from the rustc book, since their recommendation simply doesn't work. So this is
what I came up with:

```bash
objects="$(cargo test --no-run --message-format=json | jq -r 'select(.profile.test == true) | .filenames[] | "--object " + .' | tr '\n' ' ')"
```

What this line does is:

- Take the json output of `cargo test` without actually running the tests.
- Extract the names of the test binaries adding the `--object` flag in the
  process.
- Turn it into a single line.

Yes, yes, I can hear you. I promised "no third party tools" and now `jq` pops
up. But it is included in the GitHub Actions environment out of the box and
almost everyone has it installed anyway, so that doesn't count 😜.

Now that we have `objects`, we can run `llvm-cov` and see a nice table with our
coverage data. I'll leave it up to you to figure out generating nice and shiny
HTML reports.

## `lcov` and interfacing with code coverage services

Now, let's get to another thing not covered by the rustc book: interfacing with
code coverage services like [Coveralls](https://coveralls.io/) (unfortunately,
they don't pay me). These things are nice, because they give everyone a shared
look into the code coverage data retrieved in a controlled environment (e.g.
CI). For Coveralls we would need to convert out `.profdata` into something that
Coveralls can actually consumed. I went with `lcov` and this is a rather simple
conversion:

```bash
llvm-cov export -format=lcov -instr-profile tests.profdata $objects -sources src/{,**/}*.rs > tests.lcov
```

In GitHub Actions we can just use the Coveralls action with the default setup:

```yaml
- name: Upload coverage report
  uses: coverallsapp/github-action@v2
    with:
      github-token: ${{ secrets.GITHUB_TOKEN }}
```
