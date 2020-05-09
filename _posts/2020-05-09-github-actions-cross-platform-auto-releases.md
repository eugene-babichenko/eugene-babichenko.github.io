---
layout: post
title: Automated multi-platform releases with GitHub Actions
date: 2020-05-09 15:20:00 +0300
categories: github ci tutorial
---

GitHub Actions allows you to create releases, build binaries, and upload them.
Unfortunately, there is no official tutorial on how to create a release, build
the code for multiple platforms, and upload binaries to the release. I will
cover how to do that without any 3rd-party actions in this post. I assume that
you are familiar with the basics of GitHub Actions.

## Selecting the workflow trigger

First things first: let's select the trigger for our workflow. I `git` tags for
versioning, and for simplicity they begin with `v`, so the simplest trigger we
can use

```yaml
on:
  push:
    tags:
      - 'v[0-9]+.*'
```

Let's continue to defining our jobs.

## Creating the release

Since we are going to do multiple builds defined in a matrix, creating the new
release should be obviously done in a separate job. GitHub has the official
[example][example] for that. The only difference from the example is that we
add the job output. This output will be used by build jobs to upload their
results to the created release.

```yaml
{% raw %}
jobs:
  create_release:
    name: Create release
    runs-on: ubuntu-latest
    # Note this. We are going to use that in further jobs.
    outputs:
      upload_url: ${{ steps.create_release.outputs.upload_url }}
    steps:
      - name: Create release
        id: create_release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          draft: false
          prerelease: false
{% endraw %}
```

## Build and upload

This is the final step. I won't dive into the details too much because you will
have your own build scenarios. But here are a couple of things to highlight:

* The build jobs will have `create_release` as a dependency.
* The output of `create_release` is used in the last "upload step".

You can get more details on assets uploads [here][upload-assets].

```yaml
{% raw %}
# ...
  release_assets:
    name: Release assets
    needs: create_release # we need to know the upload URL
    runs-on: ${{ matrix.config.os }} # we run many different builds
    strategy:
      # just an example matrix
      matrix:
        config:
          - os: ubuntu-latest
          - os: macos-latest
          - os: windows-latest
    steps:
      # checkout of cource
      - name: Checkout code
        uses: actions/checkout@v1
      # ... whatever build and packaging steps you need here
      # and finally do an upload!
      - name: Upload release assets
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ needs.create_release.outputs.upload_url }}
          # This is how it will be named on the release page. Put hatever name
          # you like, remember that they need to be different for each platform.
          # You can choose any build matrix parameters. For Rust I use the
          # target triple.
          asset_name: program-name-${{ matrix.config.os }}
          # The path to the file you want to upload.
          asset_path: ./path/to/your/file
          # probably you will need to change it, but most likely you are
          # uploading a binary file
          asset_content_type: application/octet-stream
{% endraw %}
```

A note on executable formats: if you are building for Windows and uploading an
`.exe` you can use two different steps for uploading the executable. One should
have `if: matrix.config.os == 'windows-latest'` and asset path
`asset_path: ./path/to/your/file.exe`. For *nix operating systems that usually
are not using extensions for executables, use
`if: matrix.config.os != 'windows-latest'`. This is a very useful trick overall
when creating jobs that should handle multiple platforms.

[example]: https://github.com/actions/create-release#example-workflow---create-a-release
[upload-assets]: https://github.com/actions/upload-release-asset
