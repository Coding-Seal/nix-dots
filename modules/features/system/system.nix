{ config, inputs, ... }:
{
  config.nixosModules = [
    { nixpkgs.overlays = [ inputs.nur.overlays.default ]; }
    ({ pkgs, lib, ... }: {
      # systemd-boot by default; hosts that need to dual-boot another OS
      # override this (see modules/lumar.nix, which switches to GRUB).
      boot.loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = lib.mkDefault true;
      };

      # Timezone is set automatically via geoclue2 location lookup below.
      services.automatic-timezoned.enable = true;
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "ru_RU.UTF-8/UTF-8"
      ];
      users.users.${config.username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "audio"
          "seat"
        ];
        shell = pkgs.fish;
      };
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Without this, nix daemon rejects client-specified settings from
      # non-trusted users with warnings devenv treats as fatal errors.
      nix.settings.trusted-users = [
        "root"
        "@wheel"
      ];
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
