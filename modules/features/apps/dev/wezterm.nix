_: {
  config.hmModules = [
    {
      # font/color_scheme are left to Stylix's wezterm target (modules/features/desktop/stylix.nix).
      # Once it contributes `programs.wezterm.settings`, HM wraps `extraConfig` in a function
      # instead of inlining it directly — a self-contained `local config = ...; return config`
      # extraConfig would then only mutate a shadowed local and never reach the real output.
      programs.wezterm = {
        enable = true;
        settings = {
          window_background_opacity = 0.95;
          window_decorations = "NONE";
          window_padding = {
            left = 10;
            right = 10;
            top = 10;
            bottom = 10;
          };
          enable_tab_bar = true;
          hide_tab_bar_if_only_one_tab = true;
          use_fancy_tab_bar = false;
          tab_bar_at_bottom = true;
          scrollback_lines = 10000;
          default_cursor_style = "BlinkingBar";
          cursor_blink_rate = 500;
          window_close_confirmation = "NeverPrompt";
        };
      };
    }
  ];
}
