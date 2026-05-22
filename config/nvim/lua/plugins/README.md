# Personal plugin overrides

Add `.lua` files here to:
- Enable extra LazyVim modules (e.g. `lazyvim.plugins.extras.lang.python`)
- Override LazyVim defaults
- Add your own plugins

Example — enable the Python language module:

```lua
-- lua/plugins/lang.lua
return {
  { import = "lazyvim.plugins.extras.lang.python" },
}
```

See https://www.lazyvim.org/extras for all available extras.
