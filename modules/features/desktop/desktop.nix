{ inputs, ... }:
{
  config.nixosModules = [
    inputs.noctalia-greeter.nixosModules.default
    ({ pkgs, ... }: {
      programs.noctalia-greeter.enable = true;

      hardware = {
        graphics.enable = true;
        bluetooth = {
          enable = true;
          powerOnBoot = true;
        };
      };

      services = {
        pipewire = {
          enable = true;
          alsa.enable = true;
          pulse.enable = true;
        };
        blueman.enable = true;
        power-profiles-daemon.enable = true;
        upower.enable = true;
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        # gnome implements the Mutter-style ScreenCast/RemoteDesktop DBus API that
        # niri speaks, so it must come first for screen sharing (Telegram, Zoom)
        # to work; gtk is the fallback for interfaces gnome doesn't implement
        # (e.g. FileChooser).
        config.common.default = [
          "gnome"
          "gtk"
        ];
      };

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-color-emoji
      ];
    })
  ];
}
