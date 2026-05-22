# WezTerm terminal emulator configuration.
# Config is written in Lua (WezTerm's native config language).
{ ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")
      local config = wezterm.config_builder()

      -- Font
      config.font = wezterm.font("JetBrainsMono Nerd Font")
      config.font_size = 13.0

      -- Color scheme (Tokyo Night matches Niri border colors and Neovim theme)
      config.color_scheme = "Tokyo Night"

      -- Window appearance
      config.window_background_opacity = 0.95
      config.window_decorations = "NONE"  -- no title bar (Niri handles it)
      config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }

      -- Tab bar
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.use_fancy_tab_bar = false
      config.tab_bar_at_bottom = true

      -- Scrollback
      config.scrollback_lines = 10000

      -- Cursor
      config.default_cursor_style = "BlinkingBar"
      config.cursor_blink_rate = 500

      -- Don't ask when closing with running processes
      config.window_close_confirmation = "NeverPrompt"

      -- Keybinds: Ctrl+Shift+T = new tab, Ctrl+Shift+W = close tab
      -- These are WezTerm defaults; add your own here if needed

      return config
    '';
  };
}
