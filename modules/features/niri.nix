{ inputs, self, ... }:

{
  config.flake.wrappersModules.niri = { config, lib, ... }:
  {
    options.terminal = lib.mkOption {
      type = lib.types.str;
      default = "wezterm";
    };

    config.v2-settings = true;

    config.settings = {
      prefer-no-csd = _: {};

      input = {
        keyboard = {
          xkb = {
            layout = "us,ru";
            options = "grp:alt_shift_toggle";
          };
          repeat-rate = 40;
          repeat-delay = 250;
        };
        touchpad = {
          tap = _: {};
          natural-scroll = _: {};
          dwt = _: {};
        };
        mouse.accel-profile = "flat";
      };

      layout = {
        gaps = 12;
        center-focused-column = "never";
        default-column-width.proportion = 0.5;
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        focus-ring = {
          width = 2;
          active-color = "#7aa2f7";
          inactive-color = "#3b4261";
        };
      };

      binds = {
        "Mod+Return".spawn = config.terminal;
        "Mod+D".spawn-sh = "noctalia msg panel-toggle launcher";
        "Mod+B".spawn = "firefox";

        "Mod+Q".close-window = _: {};
        "Mod+F".fullscreen-window = _: {};
        "Mod+Shift+F".toggle-window-floating = _: {};
        "Mod+C".center-column = _: {};

        "Mod+H".focus-column-left = _: {};
        "Mod+L".focus-column-right = _: {};
        "Mod+J".focus-window-down = _: {};
        "Mod+K".focus-window-up = _: {};
        "Mod+Left".focus-column-left = _: {};
        "Mod+Right".focus-column-right = _: {};
        "Mod+Down".focus-window-down = _: {};
        "Mod+Up".focus-window-up = _: {};

        "Mod+Shift+H".move-column-left = _: {};
        "Mod+Shift+L".move-column-right = _: {};
        "Mod+Shift+J".move-window-down = _: {};
        "Mod+Shift+K".move-window-up = _: {};
        "Mod+Shift+Left".move-column-left = _: {};
        "Mod+Shift+Right".move-column-right = _: {};

        "Mod+Ctrl+H".set-column-width = "-5%";
        "Mod+Ctrl+L".set-column-width = "+5%";
        "Mod+Ctrl+J".set-window-height = "-5%";
        "Mod+Ctrl+K".set-window-height = "+5%";

        "Mod+1".focus-workspace = "w0";
        "Mod+2".focus-workspace = "w1";
        "Mod+3".focus-workspace = "w2";
        "Mod+4".focus-workspace = "w3";
        "Mod+5".focus-workspace = "w4";

        "Mod+Shift+1".move-column-to-workspace = "w0";
        "Mod+Shift+2".move-column-to-workspace = "w1";
        "Mod+Shift+3".move-column-to-workspace = "w2";
        "Mod+Shift+4".move-column-to-workspace = "w3";
        "Mod+Shift+5".move-column-to-workspace = "w4";

        "Mod+Tab".focus-workspace-down = _: {};
        "Mod+Shift+Tab".focus-workspace-up = _: {};

        "Mod+WheelScrollDown".focus-column-left = _: {};
        "Mod+WheelScrollUp".focus-column-right = _: {};
        "Mod+Ctrl+WheelScrollDown".focus-workspace-down = _: {};
        "Mod+Ctrl+WheelScrollUp".focus-workspace-up = _: {};

        "Print".screenshot = _: {};
        "Ctrl+Print".screenshot-screen = _: {};
        "Alt+Print".screenshot-window = _: {};

        "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

        "XF86MonBrightnessUp".spawn-sh = "brightnessctl set +5%";
        "XF86MonBrightnessDown".spawn-sh = "brightnessctl set 5%-";

        "XF86AudioPlay".spawn-sh = "playerctl play-pause";
        "XF86AudioNext".spawn-sh = "playerctl next";
        "XF86AudioPrev".spawn-sh = "playerctl previous";

        "Mod+Shift+Slash".show-hotkey-overlay = _: {};

        "Mod+Shift+E".quit = _: {};

        "Mod+R".switch-preset-column-width = _: {};
        "Mod+E".spawn-sh = "wezterm start -- yazi";
        "Mod+Comma".consume-window-into-column = _: {};
        "Mod+Period".expel-window-from-column = _: {};
      };

      workspaces = let s = { layout.gaps = 12; }; in {
        "w0" = s; "w1" = s; "w2" = s; "w3" = s; "w4" = s;
      };

      window-rules = [
        {
          matches = [ { app-id = "^zoom$"; } ];
          open-floating = true;
        }
      ];

      spawn-at-startup = [ "noctalia" ];
    };
  };

  # Build a wrapped niri package with the config baked in
  config.perSystem = { pkgs, ... }: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [ self.wrappersModules.niri ];
    };
  };

  # Wire the wrapped package into NixOS
  config.nixosModules = [
    ({ pkgs, ... }: {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
      };
      programs.fish.enable = true;

      # niri (>=25.08) auto-spawns XWayland on demand via xwayland-satellite
      # when an X11-only app (e.g. Zoom) connects — it just needs the binary
      # on PATH, no manual systemd unit or $DISPLAY wiring required.
      environment.systemPackages = [ pkgs.xwayland-satellite ];
    })
  ];
}
