{ inputs, ... }:
{
  config.nixosModules = [
    inputs.noctalia.nixosModules.default
    {
      programs.noctalia.recommendedServices.enable = true;
    }
  ];

  config.hmModules = [
    inputs.noctalia.homeModules.default
    (
      { config, ... }:
      {
        programs.noctalia = {
          # GTK/Qt/KColorScheme theming is owned by Stylix's own targets now
          # (modules/features/desktop/stylix.nix), which write nix-managed files
          # to the same paths (e.g. gtk-3.0/gtk.css) — enabling Noctalia's own
          # builtin templates for these would fight over them. Same story for
          # wezterm (Stylix's wezterm target) and telegram (this repo builds
          # its own gruvbox theme for it, see communication/telegram.nix) —
          # theme.templates is left empty below on purpose.
          enable = true;

          # nixpkgs' bundled Stylix "noctalia" target only wires the deprecated
          # programs.noctalia-shell option (unused here), so it's a no-op —
          # build the real palette by hand from the same base16 scheme instead.
          #
          # Field names match Noctalia's *current* compiled (C++) custom-palette
          # schema (theme/theme_service.cpp: readPaletteJson + readModeTerminalJson) —
          # unprefixed role names plus a required `terminal` block.
          #
          # Role/slot choices below are picked to match how Noctalia's own bundled
          # "Gruvbox" builtin theme (theme/builtin_palettes.cpp) applies each role —
          # e.g. primary is base0B (green), not base0D, because that's what the
          # official theme uses for primary. Purely base16-driven throughout: base16
          # only has one shade per hue, so terminal.normal and terminal.bright reuse
          # the same slots (unlike true Gruvbox's separate muted/vivid ANSI tones) —
          # that palette difference is fine, this is only about matching *which*
          # role gets *which* hue.
          customPalettes.stylix.dark = with config.lib.stylix.colors.withHashtag; {
            primary = base0B;
            onPrimary = base00;
            secondary = base0A;
            onSecondary = base00;
            tertiary = base0D;
            onTertiary = base00;
            error = base08;
            onError = base00;
            surface = base00;
            onSurface = base07;
            hover = base0D;
            onHover = base00;
            surfaceVariant = base01;
            onSurfaceVariant = base06;
            outline = base03;
            shadow = base00;

            terminal = {
              normal = {
                black = base00;
                red = base08;
                green = base0B;
                yellow = base0A;
                blue = base0D;
                magenta = base0E;
                cyan = base0C;
                white = base06;
              };
              bright = {
                black = base03;
                red = base08;
                green = base0B;
                yellow = base0A;
                blue = base0D;
                magenta = base0E;
                cyan = base0C;
                white = base06;
              };
              foreground = base06;
              background = base00;
              cursor = base06;
              cursorText = base00;
              selectionFg = base06;
              selectionBg = base03;
            };
          };

          # Ported from the live GUI-managed ~/.local/state/noctalia/settings.toml
          # (config_version 12) so this becomes the declared baseline instead —
          # Noctalia's own config/state layering (see
          # https://docs.noctalia.dev/noctalia/configuration/) means GUI edits
          # matching these values get deduplicated back out automatically.
          settings = {
            accessibility.ui_scale = 1.0500000081956387;

            backdrop.enabled = true;

            bar.default = {
              capsule_group = [ ];
              concave_edge_corners = false;
              end = [
                "media"
                "tray"
                "clipboard"
                "notifications"
                "network"
                "bluetooth"
                "volume"
                "brightness"
                "battery"
                "control-center"
                "session"
              ];
              margin_ends = 0;
              start = [
                "wallpaper"
                "workspaces"
              ];
              thickness = 35;
              widget_spacing = 15;
            };

            calendar = {
              enabled = true;
              account.personal_google.type = "google";
            };

            dock = {
              concave_edge_corners = false;
              enabled = true;
              icon_size = 30;
              main_axis_padding = 10;
              radius = 10;
              reserve_space = false;
              show_dots = true;
              smart_auto_hide = true;
            };

            lockscreen.fingerprint = false;

            lockscreen_widgets = {
              enabled = true;
              schema_version = 2;
              widget_order = [
                "lockscreen-login-box@HDMI-A-1"
                "lockscreen-login-box@eDP-1"
                "lockscreen-widget-0000000000000001"
              ];

              grid = {
                cell_size = 16;
                major_interval = 4;
                visible = true;
              };

              widget = {
                "lockscreen-login-box@HDMI-A-1" = {
                  box_height = 196.0;
                  box_width = 810.0;
                  cx = 1280.0;
                  cy = 1258.0;
                  output = "HDMI-A-1";
                  rotation = 0.0;
                  type = "login_box";
                  settings = {
                    background_color = "surface_variant";
                    background_opacity = 0.88;
                    background_radius = 12.0;
                    center_password_text = false;
                    input_opacity = 1.0;
                    input_radius = 6.0;
                    layout = "regular";
                    show_caps_lock = true;
                    show_keyboard_layout = true;
                    show_login_button = true;
                    show_media = true;
                    show_session_buttons = true;
                    show_unlock_hint = true;
                    show_weather = true;
                  };
                };

                "lockscreen-login-box@eDP-1" = {
                  box_height = 196.0;
                  box_width = 810.0;
                  cx = 960.0;
                  cy = 898.0;
                  output = "eDP-1";
                  rotation = 0.0;
                  type = "login_box";
                  settings = {
                    background_color = "surface_variant";
                    background_opacity = 0.88;
                    background_radius = 12.0;
                    center_password_text = false;
                    input_opacity = 1.0;
                    input_radius = 6.0;
                    layout = "regular";
                    show_caps_lock = true;
                    show_keyboard_layout = true;
                    show_login_button = true;
                    show_media = true;
                    show_session_buttons = true;
                    show_unlock_hint = true;
                    show_weather = true;
                  };
                };

                "lockscreen-widget-0000000000000001" = {
                  box_height = 0.0;
                  box_width = 0.0;
                  cx = 960.0;
                  cy = 218.0;
                  output = "eDP-1";
                  rotation = 0.0;
                  type = "clock";
                  settings.clock_style = "digital";
                };
              };
            };

            nightlight.enabled = true;

            plugins.enabled = [ "icefish/phone-connect" ];

            shell = {
              font_family = "JetBrainsMono Nerd Font Mono";
              niri_overview_type_to_launch_enabled = true;
              password_style = "random";
              launcher.providers.session.global = true;
              screenshot.confirm_region = true;
            };

            # Real palette wiring for the real option (see customPalettes.stylix
            # above) -- this is what nixpkgs' dead Stylix target was meant to do.
            theme = {
              source = "custom";
              custom_palette = "stylix";
              mode = "dark";
            };

            # Wallpaper is Stylix-managed: `stylix.image` (stylix.nix) is the
            # single source of truth for the *active* wallpaper, referenced
            # here so Noctalia's background follows it instead of an
            # independently GUI-picked image. `directory` deliberately stays a
            # literal live filesystem path (not a Nix store path copied from
            # ../../../wallpaper) so the in-app picker's browsing pool sees new
            # files dropped into the repo's wallpaper/ folder without requiring
            # a rebuild first.
            wallpaper.directory = "/home/${config.home.username}/Projects/nix-dots/wallpaper";
            wallpaper.default.path = toString config.stylix.image;
          };
        };
      }
    )
  ];
}
