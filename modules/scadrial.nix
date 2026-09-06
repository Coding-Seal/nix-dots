{ config, inputs, ... }:
{
  flake.nixosConfigurations.scadrial = inputs.nixpkgs.lib.nixosSystem {
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
      ../hosts/scadrial/disko.nix
      ../hosts/scadrial/hardware-configuration.nix

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "bak";
          users.${config.username} = {
            imports = config.hmModules;
            home = {
              inherit (config) username;
              homeDirectory = "/home/${config.username}";
              stateVersion = "25.05";
            };
            programs.home-manager.enable = true;
          };
        };
      }

      # Work laptop-specific settings — add proxy/etc once known.
      (
        { pkgs, ... }:
        {
          networking.hostName = "scadrial";

          # Cisco AnyConnect VPN. openconnect speaks the AnyConnect SSL-VPN
          # protocol; the NetworkManager plugin wires it into nm-connection-editor /
          # Noctalia's network widget. `openconnect` is also on PATH for
          # command-line use (`sudo openconnect <host>`).
          networking.networkmanager.plugins = [ pkgs.networkmanager-openconnect ];
          environment.systemPackages = [
            pkgs.openconnect
            pkgs.networkmanagerapplet # nm-connection-editor — GUI to author the VPN profile
          ];
        }
      )
    ]
    ++ config.nixosModules;
  };
}
