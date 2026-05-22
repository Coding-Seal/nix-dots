-- Bootstrap lazy.nvim (downloads it on first launch if not present)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before lazy loads plugins (many plugins bind to <leader>)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
  spec = {
    -- Load LazyVim core and its default plugin set
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- Your personal plugin overrides live in lua/plugins/
    -- Add files there to enable extra LazyVim modules or add your own plugins
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false, -- always use latest git commits
  },
  install = {
    colorscheme = { "tokyonight", "habamax" },
  },
  checker = {
    enabled = true,  -- notify when plugin updates are available
    notify = false,  -- don't notify on every startup
  },
  performance = {
    rtp = {
      -- Disable built-in Neovim plugins we don't use (speeds up startup)
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
