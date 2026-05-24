{ ... }:
{
  config.hmModules = [
    {
      programs.wezterm = {
        enable = true;
        extraConfig = ''
          local wezterm = require("wezterm")
          local config = wezterm.config_builder()

          config.font = wezterm.font("JetBrainsMono Nerd Font")
          config.font_size = 13.0
          config.color_scheme = "Tokyo Night"
          config.window_background_opacity = 0.95
          config.window_decorations = "NONE"
          config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
          config.enable_tab_bar = true
          config.hide_tab_bar_if_only_one_tab = true
          config.use_fancy_tab_bar = false
          config.tab_bar_at_bottom = true
          config.scrollback_lines = 10000
          config.default_cursor_style = "BlinkingBar"
          config.cursor_blink_rate = 500
          config.window_close_confirmation = "NeverPrompt"

          return config
        '';
      };
    }
  ];
}
