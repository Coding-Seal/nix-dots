# Niri compositor configuration.
# Niri is a scrollable tiling Wayland compositor — windows are arranged in
# infinite horizontal columns. Mod is the Super/Windows key.
{ username, ... }:

{
  # xdg.configFile writes files into ~/.config/
  # "niri/config.kdl" → ~/.config/niri/config.kdl
  xdg.configFile."niri/config.kdl".text = ''
    // ── Environment ──────────────────────────────────────────────────────────
    // niri-session does not forward PATH into the systemd user session,
    // so spawned apps can't find binaries without this.
    environment {
        PATH "/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin"
    }

    // ── Input ────────────────────────────────────────────────────────────────
    input {
        keyboard {
            xkb {
                // TODO: change to your keyboard layout, e.g. "gb", "de", "ru"
                layout "us"
            }
        }

        touchpad {
            tap                  // tap-to-click
            natural-scroll       // scroll direction matches finger movement
            dwt                  // disable while typing
        }

        mouse {
            accel-speed 0.0
        }
    }

    // ── Layout ───────────────────────────────────────────────────────────────
    layout {
        gaps 12

        center-focused-column "never"

        // Default window width: half the screen
        default-column-width { proportion 0.5; }

        border {
            width 2
            active-color "#7aa2f7"    // Tokyo Night blue
            inactive-color "#3b4261"
        }

        focus-ring {
            off
        }
    }

    // ── Appearance ───────────────────────────────────────────────────────────
    prefer-no-csd   // ask apps not to draw their own title bars

    // ── Startup ──────────────────────────────────────────────────────────────
    spawn-at-startup "noctalia-shell"   // desktop shell (bar, dock, notifications)

    // ── Keybinds ─────────────────────────────────────────────────────────────
    // Mod = Super (Windows key)
    binds {
        // Applications
        Mod+Return { spawn "wezterm"; }
        Mod+D      { spawn "fuzzel"; }   // app launcher
        Mod+B      { spawn "firefox"; }

        // Window management
        Mod+Q      { close-window; }
        Mod+F      { fullscreen-window; }
        Mod+C      { center-column; }

        // Focus: move between columns (←/→) and windows within a column (↑/↓)
        Mod+H      { focus-column-left; }
        Mod+L      { focus-column-right; }
        Mod+J      { focus-window-down; }
        Mod+K      { focus-window-up; }

        Mod+Left   { focus-column-left; }
        Mod+Right  { focus-column-right; }
        Mod+Down   { focus-window-down; }
        Mod+Up     { focus-window-up; }

        // Move windows
        Mod+Shift+H     { move-column-left; }
        Mod+Shift+L     { move-column-right; }
        Mod+Shift+J     { move-window-down; }
        Mod+Shift+K     { move-window-up; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }

        // Resize columns
        Mod+Minus   { set-column-width "-10%"; }
        Mod+Equal   { set-column-width "+10%"; }

        // Workspaces (virtual desktops)
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }

        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }

        Mod+Tab         { focus-workspace-down; }
        Mod+Shift+Tab   { focus-workspace-up; }

        // Screenshots
        Print           { screenshot; }
        Ctrl+Print      { screenshot-screen; }
        Alt+Print       { screenshot-window; }

        // Audio (works even when screen is locked)
        XF86AudioRaiseVolume  allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+"; }
        XF86AudioLowerVolume  allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-"; }
        XF86AudioMute         allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

        // Brightness
        XF86MonBrightnessUp   { spawn "brightnessctl" "set" "+5%"; }
        XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

        // Media
        XF86AudioPlay { spawn "playerctl" "play-pause"; }
        XF86AudioNext { spawn "playerctl" "next"; }
        XF86AudioPrev { spawn "playerctl" "previous"; }

        // Session
        Mod+Shift+E { quit; }
    }
  '';
}
