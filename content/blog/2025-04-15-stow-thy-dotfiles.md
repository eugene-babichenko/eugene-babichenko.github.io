+++
title = "stow thy dotfiles"
date = 2025-04-15T16:44:55+03:00
+++

I have a lot of dotfiles. Initially, I managed them using symlinks, but
maintaining a bunch of symlinks by hand is a bit tedious. Then I tried using
stuff like YADM and chezmoi and was left disappointed. They are just a bit too
complicated for a simple task of managing a bunch of configuration files and
keeping them accessible from the right location.

So, symlinks. But instead of managing them by hand, manage them with GNU Stow.
This is a simple tool, that just takes your files and symlinks them where they
need to be.

This is the structure of my repo with dotfiles:

```
.config
├── bat
├── fish
├── mpv
├── tmux
├── wezterm
└── yazi
```

It essentially emulates the actual structure what is happening in the home
directory. Install GNU Stow and run `stow -t $HOME .` and everything gets
symlinked to where it needs to be. Magic. One thing done right without stupid
back and forth. You open the file from the repo, you open it from
`~/.config/...`, doesn't matter, the change will apply regardless. The
embodiment of the UNIX philosphy. And then you just manage it with git. Want
something automatically encrypted in that repo? There are tools for that, and
they are good at it.

That's it, that's peak configuration management.
