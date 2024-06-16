---
layout: post
title:  "Patching fonts to get powerline symbols"
date:   2018-08-17 16:25:00+03:00
categories: tutorials
tags:   terminal powerline fonts customization fontforge
---

Many shell/vim/etc extensions require powerline fonts to be installed in your system. Usually, people stick with fonts available in the [powerline repository](https://github.com/powerline/fonts), but if you want to continue using your favorite font while taking benefits of powerline symbols?

Pretty obvious solution: just patch it!

Here is what you'll need:

1. Python 2.x.
1. [Fontforge](https://github.com/fontforge/fontforge) with Python support. On a Mac, it is pretty easy to install: `brew install fontforge --with-python`.
1. Powerline [font patcher](https://github.com/powerline/fontpatcher). Just clone it: `git clone --depth=1 https://github.com/powerline/fontpatcher.git`.
1. Your font file.

After you have everything installed, go to the `scripts` directory of `powerline` repository and run `./powerline <your_font_file_name>`. For instance, I did `./powerline-fontpatcher /System/Library/Fonts/Monaco.dfont` to patch the default monospace font of macOS. Then you'll get your patched font in the directory you're currently at and that's it! You just need to install this font and enjoy your favorite font with new powerline symbols.
