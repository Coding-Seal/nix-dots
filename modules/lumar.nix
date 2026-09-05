{ config, inputs, ... }:
{
  flake.nixosConfigurations.lumar = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      {
        nix.settings = {
          extra-substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://noctalia.cachix.org"
          ];
          extra-trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];
        };
      }

      inputs.disko.nixosModules.disko
      ../hosts/lumar/disko.nix
      ../hosts/lumar/hardware-configuration.nix

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "bak";
          users.${config.username} = {
            imports = config.hmModules ++ config.personalHmModules;
            home = {
              inherit (config) username;
              homeDirectory = "/home/${config.username}";
              stateVersion = "25.05";
            };
            programs.home-manager.enable = true;
          };
        };
      }

      # Laptop-specific settings
      ({ pkgs, ... }: {
        networking = {
          hostName = "lumar";
        };

        # Dual-boots Windows — GRUB + os-prober instead of the shared systemd-boot default.
        boot.loader = {
          systemd-boot.enable = false;
          grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            useOSProber = true;
          };
        };
        environment.systemPackages = [ pkgs.os-prober ];
      })
    ]
    ++ config.nixosModules;
  };
}
