_: {
  # No Stylix target exists for Telegram (see CLAUDE.md) -- it draws its own
  # chat UI independent of the Qt platform theme, using .tdesktop-theme files
  # (a zip of a colors.tdesktop-theme palette + background image) selected
  # through its own Settings UI and stored in opaque local storage (tdata).
  #
  # We can't make Telegram *use* a theme declaratively, but we can generate
  # one from the active Stylix palette: take Telegram's own official night
  # theme (which already has sensible dark values for all ~200 semantic
  # keys) and recolor every literal hex onto the base16 scheme, preserving
  # each color's original lightness so hover/active/selected gradients stay
  # legible. See telegram-theme-recolor.py for the algorithm.
  #
  # One-time manual step still required: Settings -> Chat Settings -> Themes
  # -> "+" / "Choose from file" -> pick the file this module drops at
  # ~/.local/share/telegram-desktop-theme/gruvbox.tdesktop-theme
  config.hmModules = [
    (
      { pkgs, config, ... }:
      let
        nightTheme = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/telegramdesktop/tdesktop/954f75623dd0e98a1d3c7831df35bc30d694083e/Telegram/Resources/night.tdesktop-theme";
          sha256 = "0fhxjl4xjn4dyxicqqmw9091d6v9k3yk7ixrdphpfcs5i1rcskrn";
        };

        colors = config.lib.stylix.colors.withHashtag;
        base16Json = builtins.toJSON {
          inherit (colors)
            base00
            base01
            base02
            base03
            base04
            base05
            base06
            base07
            base08
            base09
            base0A
            base0B
            base0C
            base0D
            base0E
            base0F
            ;
        };

        gruvboxTheme =
          pkgs.runCommand "gruvbox.tdesktop-theme"
            {
              nativeBuildInputs = [
                pkgs.python3
                pkgs.unzip
                pkgs.zip
              ];
            }
            ''
              mkdir extracted
              unzip -q ${nightTheme} -d extracted
              python3 ${./telegram-theme-recolor.py} '${base16Json}' \
                extracted/colors.tdesktop-theme extracted/colors.tdesktop-theme
              cd extracted
              zip -q -X $out colors.tdesktop-theme background.png
            '';
      in
      {
        home.packages = [ pkgs.telegram-desktop ];
        xdg.dataFile."telegram-desktop-theme/gruvbox.tdesktop-theme".source = gruvboxTheme;
      }
    )
  ];
}
