---
layout: post
title: Just another terminal setup
date: 2019-06-13 11:00:00+03:00
categories: terminal zsh antigen
---

In this post, I will guide you through my terminal setup (which is quite simple
though). This post may be updated in the future and is also for my own
convenience when I need to set up everything on another machine.

![This is how it looks][terminal-screenshot]

## Terminal emulator

I have been using [iTerm2][iterm] on a Mac for quite a long time until I found
myself not using most of its features, so now I am fine with the default
`Terminal.app`.

## Themes

I am a big fan of [Solarized][solarized] themes and use Solarized Light light
most of the day and Solarized Dark if I work in the evening or overnight or in
bad lighting conditions.

Here is the [GitHub repository][themes-repo] with those themes implement for
`Terminal.app` by [@tomsilav][themes-author], iTerm2 has them out-of-the-box.

## Shell

I use [zsh][zsh] because I like its features (like autocompletion, shared
command history, and many others) and extensibility. I also tried [fish][fish]
but it lacked some features I needed that time. Maybe, I will give a try once
again.

## Plugins

First off, we need to somehow manage our plugins and `zsh` don't have such
capabilities out-of-the-box. I use [antigen][antigen] to manage my plugins but
there is a drawback: it is quite slow itself (mostly written in shell script and
Perl) and thus the shell start time is a bit slower. I also tried
[antibody][antibody] which is written in Go and thus much faster, but not all
of my plugins were working properly when I tried them with antibody and also its
syntax is very verbose when it comes to managing plugins bundled with
`oh-my-zsh`.

[oh-my-zsh][oh-my-zsh] is a configuration framework and a bunch of plugins for
`zsh`. Those include additional autocompletion, coloring man pages and so on.

This is an example of how to use `antigen` and `zsh` altogether (place this in
your `~/.zshrc` - the main `zsh` configuration file):

```bash
source /usr/local/share/antigen/antigen.zsh

# Use oh-my-zsh
antigen use oh-my-zsh

# Include an oh-my-zsh plugin
antigen bundle git

# Include a plugin from GitHub
antigen bundle zsh-users/zsh-autosuggestions
```

You can find the whole list of plugins I use in [this gist][gist], but I would
like to highlight a couple of them:

* [zdharma/fast-syntax-highlighting][fast-syntax-highlighting] which is
  basically a faster version of
  [zsh-users/zsh-syntax-highlighting][zsh-syntax-highlighting]
* [marzocchi/zsh-notify][zsh-notify] - notifies you when a command that was
  running for a long time in a background shell had finished.
* [sindresorhus/pure][pure] - my favorite `zsh` prompt.

[terminal-screenshot]: /assets/2019-06-13-terminal-screenshot.png
[iterm]: https://www.iterm2.com
[solarized]: https://ethanschoonover.com/solarized/
[themes-repo]: https://github.com/tomislav/osx-terminal.app-colors-solarized
[themes-author]: https://github.com/tomislav
[zsh]: https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH
[fish]: http://fishshell.com
[antigen]: https://github.com/zsh-users/antigen
[antibody]: https://github.com/getantibody/antibody
[oh-my-zsh]: https://github.com/robbyrussell/oh-my-zsh
[gist]: https://gist.github.com/eugene-babichenko/a8937d2c1a2f8b94b382103c093c8170
[fast-syntax-highlighting]: https://github.com/zdharma/fast-syntax-highlighting
[zsh-syntax-highlighting]: https://github.com/zsh-users/zsh-syntax-highlighting
[zsh-notify]: https://github.com/marzocchi/zsh-notify
[pure]: https://github.com/sindresorhus/pure
