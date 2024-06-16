---
layout: post
title: Highly configurable software and Lua greatness
date: 2024-06-10 14:00:00+03:00
categories: lua
---

Recently, I have started using two things: [Neovim][nvim] and [WezTerm][wez].
Both pieces of software are designed with great flexibility in mind. And both
are configured with [Lua][lua]. After rocking them for a while, I decided to
share my thoughts.

This story started with me trying to give the entire Vim thing another shot.
Then I remembered that there is Neovim. The interesting thing for me was the
first-class LSP support. But then I also remembered it can be configured (or
programmed, really) in Lua instead of VimScript, which I think is an utterly
horrible programming language which was put in there for the lack of a better
alternative at the time.

Before that I have used Lua in some obscure robotics platform and it was fine,
so I though "why not?". After all, it seemed like a rather small and limited,
but still a "proper" programming language. A tiny JS-like thing, if you will. So
I decided to go with configuring my Neovim installation in Lua instead of
VimScript.

Can you imagine my surprise finding an entire Lua-based ecosystem? Everything
felt like such a breeze after struggling with VimScript and Emacs Lisp. And
quite contrary to my fears about putting an entire proper scripting language
into any software, the thing is _properly quick_. My Neovim installation
contains 30+ plugins including dependencies and this thing easily loads in
sub-100 (60-70 ms to be precise) milliseconds time. In a blink of an eye really.

And then came WezTerm. At the time, I've been looking for an alternative to
kitty. The thing worked, it was relatively quick, but it just felt _clunky_ and
the way it was configured have been driving me nuts for a while. Like, I have a
Python interpreter shipped with this thing, and yet I have to write every
`CMD+number` key binding in a custom config language to get iTerm-like tab
switching by hand? Really? But what are the alternatives? Alacritty and the
likes of it seems too minimalistic and I am not a fan of tmux. And I would have
had to use it because Alacritty lacks any multiplexing capabilities. I moved
away from iTerm because of poor rendering perforamce: it is not slow, but it
does eat through battery, and this is something important for me. And then I
stumbled upon WezTerm on [r/neovim][rnvim]. WezTerm allows to neatly fit that in
a three-line for-loop because, you guessed it, it's config is a Lua script.

If you are building software designed to be used by other engineers and want to
bring in a great degree of configurability, Lua is a great choice. It may not be
the most powerful or expressive programming language, but the goal is to write
scripts, so it doesn't have to be. It promises to be a quick embeddable
scripting language and it delivers on this promise. It is simple enough to be
learnt in an evening for the purposes of just writing a config. Unlike languages
like VimScript or Emacs Lisp it is not unique to specific software. And unlike
Python, Ruby or JavaScript it is quick and tiny: the entire interpreter is 32k
LOC. It comes with proper development tooling: a formatter and a language
server. I hope to use it in my projects someday, but for now I am just enjoying
the great software.

[nvim]: https://neovim.io/
[wez]: https://wezfurlong.org/wezterm/index.html
[lua]: https://lua.org/
[rnvim]: https://www.reddit.com/r/neovim/
