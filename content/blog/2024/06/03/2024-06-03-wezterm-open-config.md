---
layout: post
title: "WezTerm: an actually good config key binding recipe"
date: 2024-06-03 19:40:00+03:00
categories: terminal wezterm lua
---

While [WezTerm][wez] is a great terminal with sane defaults, it doesn't provide
the default key binding to open the configuration file and edit it. That is
understandable, everyone may have their own preference for that. Here we will
figure out the recipe that would work everywhere and abide by modern standards.

In my opinion, the proper way to go is to open the configuration file with the
editor specified in the `EDITOR` environment variable. I am also using macOS
most of the time, so the most natural key binding to configure something is
`Cmd+,`. In many applications this key binding is universal for all operating
systems.

It is easy to find out where the WezTerm configuration file is located: there is
always the `WEZTERM_CONFIG_FILE` variable. Also there is always the
`WEZTERM_CONFIG_DIR` variable that should allow us to specify the working
directory for our editor.

The problem with the `EDITOR` variable is that it may not be immediately
accessible to WezTerm config via `os.getenv("EDITOR")` if it was specified in
your shell configuration (e.g. `.bashrc`) and not it some other magical place.
To solve this we will obviously need to load our editor inside the shell, which
is conveniently accessible via the `SHELL` variable.

Considering all of the above, we end up with the code like this:

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.keys = {
  {
    key = ",",
    mods = "SUPER",
    action = act.SpawnCommandInNewWindow({
      cwd = os.getenv("WEZTERM_CONFIG_DIR"),
      args = { os.getenv("SHELL"), "-c", "$EDITOR $WEZTERM_CONFIG_FILE" },
    }),
  },
}
```

This greatness of this specific recipe is that it will work regardless of your
preferred shell end editor as long as the `EDITOR` variable is set. The `-c`
flag is accepted by all major \*nix shells. Also, regardless of the fact your
editor is running with an shell, the window will close immediately after you
close the editor. And of course, you can swap `SpawnCommandInNewWindow` with
`SpawnCommandInNewTab` or any custom `SpawnCommand` call.

[wez]: https://wezfurlong.org/wezterm/
