---
layout: post
title:  "Setting up pre-commit git hook to check Rust code formatting"
date:   2018-11-08 17:05:00 +0300
categories: git rust tutorials
---

The whole thing this article is about is pretty common. But it might save you
some time when you set up a Rust repository. Quick recap: git hooks are scripts
that are triggered by git on certain actions. Here we are interested in
the pre-commit hook which is fired before you enter the commit message. We will
use it to check the code style with `rustfmt` which you need to install first:
`cargo install rustfmt`. Try running it with the following command:
`cargo fmt -- --force --write-mode diff`. This will output the suggested patch
to fix your codestyle. In-place fixes can be performed with the
`cargo fmt -- --force --write-mode overwrite` command.

[Github Gist with the materials of this tutorial](https://gist.github.com/eugene-babichenko/ca9645fa8b579b9c56668f7b0eb74095)

## Writing the hook

So let's wrap it in a simple bash script that will check files staged for
commit:

```bash
#!/bin/bash

HAS_ISSUES=0
FIRST_FILE=1

for file in $(git diff --name-only --staged); do
    FMT_RESULT="$(rustfmt --skip-children --force --write-mode diff $file 2>/dev/null || true)"
    if [ "$FMT_RESULT" != "" ]; then
        if [ $FIRST_FILE -eq 0 ]; then
            echo -n ", "
        fi  
        echo -n "$file"
        HAS_ISSUES=1
        FIRST_FILE=0
    fi
done

if [ $HAS_ISSUES -eq 0 ]; then
    exit 0
fi

echo ". Your code has formatting issues in files listed above. Format your code with \`make format\` or call rustfmt manually."
exit 1
```

Explanation:

- `git diff --name-only --staged` gather names of staged files;
- `rustfmt --skip-children --force --write-mode diff $file 2>/dev/null || true`
  does the check magic:
  - `--skip-children` -- this flag is required to not check submodules of a
    module. This is here because those files may be uncommitted but cause the
    check to fail.
  - `--force` -- just a bypass for the warning that suggests installing the
    nightly version of `rustfmt`.
  - `--write-mode diff` -- we check that the diff is empty which actually means
    that the code style is OK.
  - `2>/dev/null || true` -- `rustfmt` signalizes that it cannot format some
    lines (for example, very long constant strings) with error messages. With
    that, we suppress error messages and make the command to exit with 0. That
    might not be a very good practice but it works for me. Actually, long
    strings were the only problem.

The rest of the script is pretty trivial and is all about pretty-printing the
result of the check.

## Putting it to work

When working with got hooks you need to keep in mind that you need to share
them. My approach is to create the folder called `.githooks` and put all scripts
into it. For example, the above script is saved under the name `pre-commit`.
Don't forget to make it executable!

To make git see hooks in `.githooks` run `git config core.hooksPath .githooks`.
I put this command to my `Makefile` to make it runnable with `make init`. I also
put a script under `make format` to quickly fix everything.

## Final result

Now if you have any formatting issues git will let you know!

```
❯ git commit
build.rs, src/main.rs. Your code has formatting issues in files listed above.
Format your code with `make format` or call rustfmt manually.
```

You can also slightly modify this script by using
`git diff --name-only HEAD~1 HEAD` to fetch the list of files to perform code
style check on your CI system.
