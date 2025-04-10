+++
title = ".env.local (and .env.* in general) syntax highlighting in Neovim"
time = 2025-04-10T11:00:00+02:00
+++

Some development tooling use a rather unusual (to my taste) style of separating
`.env` files for different environments. Instead of doing `.local.env` leaving
the `.env` file extension in the end of a filename like I would do, they go with
`.env.local`, `.env.prod`, etc.

Neovim would normally highlight these with the `sh` filetype, but it requires
`.env` to be the actual file extension.

To fix this, add the following to your Neovim config (assuming the use of Lua):

```lua
vim.filetype.add({
  pattern = {
    [".env.*"] = "sh",
  },
})
```
