_: {
  config.hmModules = [
    {
      # font/color scheme are left to Stylix's ghostty target (modules/features/desktop/stylix.nix).
      # Opacity is also Stylix's job here (unlike WezTerm's own opacity setting)
      # since the ghostty target writes settings.background-opacity itself —
      # see stylix.opacity.terminal in stylix.nix instead of duplicating it here.
      programs.ghostty = {
        enable = true;
        settings = {
          window-decoration = false;
          window-padding-x = 10;
          window-padding-y = 10;
          cursor-style = "bar";
          cursor-style-blink = true;
          confirm-close-surface = false;

          # Shell integration (cursor/title/path) is on by default via
          # shell-integration = detect, which auto-injects for fish. The ssh-*
          # features default off: ssh-env rewrites TERM/COLORTERM for remote
          # compatibility, ssh-terminfo auto-installs Ghostty's terminfo on
          # remote hosts (via local infocmp + remote tic) to avoid "unknown
          # terminal type" errors.
          shell-integration-features = "ssh-env,ssh-terminfo";
        };
      };
    }
  ];
}
