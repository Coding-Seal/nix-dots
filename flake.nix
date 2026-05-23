{
  description = "NixOS workstation configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, noctalia, disko, ... }:
    let
      system = "x86_64-linux";
      # TODO: change this to your actual username (the one you set during NixOS install)
      username = "nixos";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        # specialArgs lets us pass extra variables into NixOS modules (like username)
        specialArgs = { inherit username; };
        modules = [
          # Binary cache — lets Nix download pre-built Noctalia/Quickshell
          # binaries instead of compiling them locally (saves ~30 min)
          {
            nix.settings = {
              extra-substituters = [ "https://noctalia.cachix.org" ];
              extra-trusted-public-keys = [
                "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
              ];
            };
          }

          disko.nixosModules.disko
          ./hosts/nixos/disko.nix
          ./hosts/nixos/default.nix

          # Home Manager as a NixOS module — one rebuild applies everything
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;      # share nixpkgs config (allowUnfree etc.)
              useUserPackages = true;    # install HM packages into /etc/profiles
              backupFileExtension = "bak"; # back up existing dotfiles on conflict
              extraSpecialArgs = { inherit noctalia username; };
              users.${username} = import ./home/default.nix;
            };
          }
        ];
      };
    };
}
