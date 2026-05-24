{ config, ... }:
{
  config.nixosModules = [
    ({ pkgs, ... }: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      time.timeZone = "UTC";
      i18n.defaultLocale = "en_US.UTF-8";

      users.users.${config.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "video" "audio" "seat" ];
        shell = pkgs.fish;
      };

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;

      security.polkit.enable = true;
      security.rtkit.enable = true;

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
      };

      system.stateVersion = "25.05";
    })
  ];
}
