{ config, inputs, ... }:
{
  config.nixosModules = [
    { nixpkgs.overlays = [ inputs.nur.overlays.default ]; }
    ({ pkgs, ... }: {
      # Replace systemd-boot with GRUB for dual boot
      boot.loader = {
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          useOSProber = true;
        };
      };

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
      environment.systemPackages = [ pkgs.os-prober ];
      system.stateVersion = "25.05";
    })
  ];
}