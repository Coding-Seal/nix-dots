# Neovim with LazyVim.
# LazyVim is a Neovim "distribution" — it pre-configures LSP, syntax
# highlighting, fuzzy finding, and dozens of quality-of-life plugins.
# It bootstraps itself on first launch by downloading lazy.nvim from git.
#
# The actual Lua config lives in config/nvim/ and is linked into ~/.config/nvim/
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;  # sets $EDITOR=nvim
    viAlias = true;         # `vi` → nvim
    vimAlias = true;        # `vim` → nvim
  };

  # Link our nvim config directory into ~/.config/nvim
  # LazyVim will read init.lua from here on first launch
  xdg.configFile."nvim" = {
    source = ../config/nvim;
    recursive = true;
  };

  # Runtime dependencies that LazyVim plugins expect to find in PATH
  home.packages = with pkgs; [
    # Language servers (LSP)
    nil              # Nix LSP
    lua-language-server

    # Tree-sitter compiler (for syntax highlighting)
    gcc
    gnumake

    # Tools used by Telescope, LazyVim built-ins
    lazygit          # git UI inside Neovim (Mod+gg)
    nodejs           # required by many LSP servers (typescript-language-server etc.)

    # Formatter runner
    prettierd
    stylua           # Lua formatter
  ];
}
