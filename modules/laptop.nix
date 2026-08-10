{ config, inputs, ... }:
{
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
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
      ../hosts/laptop/disko.nix
      ../hosts/laptop/hardware-configuration.nix

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "bak";
          users.${config.username} = {
            imports = config.hmModules;
            home.username = config.username;
            home.homeDirectory = "/home/${config.username}";
            programs.home-manager.enable = true;
            home.stateVersion = "25.05";
          };
        };
      }

      # Laptop-specific settings
      {
        networking.hostName = "laptop";
        networking.proxy.default = "socks4://192.168.1.143:1080";
        networking.proxy.noProxy = "127.0.0.1,localhost";
      }
    ] ++ config.nixosModules;
  };
}
