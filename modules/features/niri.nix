{ config, inputs, self, ... }:

let
  username = config.username;
in
{
  # Custom wrapper module — defines niri options and settings.
  # Imported when building the wrapped package below.
  config.flake.wrappersModules.niri = { config, lib, ... }: {
    options.terminal = lib.mkOption {
      type = lib.types.str;
      default = "wezterm";
    };

    config.settings = {
      # Fix PATH for apps spawned by niri — niri-session doesn't forward
      # PATH into the systemd user session, so binaries aren't found otherwise.
      environment.PATH =
        "/etc/profiles/per-user/${username}/bin"
        + ":/run/current-system/sw/bin"
        + ":/nix/var/nix/profiles/default/bin";

      prefer-no-csd = null;

      input = {
        keyboard = {
          xkb.layout = "us";
          repeat-rate = 40;
          repeat-delay = 250;
        };
        touchpad = {
          tap = null;
          natural-scroll = null;
          dwt = null;
        };
        mouse.accel-profile = "flat";
      };

      layout = {
        gaps = 12;
        center-focused-column = "never";
        default-column-width.proportion = 0.5;

        focus-ring = {
          width = 2;
          active-color = "#7aa2f7";
          inactive-color = "#3b4261";
        };
      };

      binds = {
        "Mod+Return".spawn = config.terminal;
        "Mod+D".spawn = "fuzzel";
        "Mod+B".spawn = "firefox";

        "Mod+Q".close-window = null;
        "Mod+F".fullscreen-window = null;
        "Mod+Shift+F".toggle-window-floating = null;
        "Mod+C".center-column = null;

        "Mod+H".focus-column-left = null;
        "Mod+L".focus-column-right = null;
        "Mod+J".focus-window-down = null;
        "Mod+K".focus-window-up = null;
        "Mod+Left".focus-column-left = null;
        "Mod+Right".focus-column-right = null;
        "Mod+Down".focus-window-down = null;
        "Mod+Up".focus-window-up = null;

        "Mod+Shift+H".move-column-left = null;
        "Mod+Shift+L".move-column-right = null;
        "Mod+Shift+J".move-window-down = null;
        "Mod+Shift+K".move-window-up = null;
        "Mod+Shift+Left".move-column-left = null;
        "Mod+Shift+Right".move-column-right = null;

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

        "Mod+Tab".focus-workspace-down = null;
        "Mod+Shift+Tab".focus-workspace-up = null;

        "Mod+WheelScrollDown".focus-column-left = null;
        "Mod+WheelScrollUp".focus-column-right = null;
        "Mod+Ctrl+WheelScrollDown".focus-workspace-down = null;
        "Mod+Ctrl+WheelScrollUp".focus-workspace-up = null;

        "Print".screenshot = null;
        "Ctrl+Print".screenshot-screen = null;
        "Alt+Print".screenshot-window = null;

        "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

        "XF86MonBrightnessUp".spawn-sh = "brightnessctl set +5%";
        "XF86MonBrightnessDown".spawn-sh = "brightnessctl set 5%-";

        "XF86AudioPlay".spawn-sh = "playerctl play-pause";
        "XF86AudioNext".spawn-sh = "playerctl next";
        "XF86AudioPrev".spawn-sh = "playerctl previous";

        "Mod+Shift+E".quit = null;
      };

      workspaces = let s = { layout.gaps = 12; }; in {
        "w0" = s; "w1" = s; "w2" = s; "w3" = s; "w4" = s;
      };

      spawn-at-startup = [ "noctalia-shell" ];
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
        package = self.packages.${pkgs.system}.niri;
      };
      programs.fish.enable = true;
    })
  ];
}
