{ config, inputs, ... }:
{
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Binary cache — pre-built Noctalia/Quickshell binaries (saves ~30 min compile)
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
      ../hosts/nixos/disko.nix
      ../hosts/nixos/hardware-configuration.nix

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

      # VM-specific overrides
      {
        networking.hostName = "nixos";
        networking.proxy.default = "http://192.168.122.1:2081";
        networking.proxy.noProxy = "127.0.0.1,localhost";
        services.spice-vdagentd.enable = true;

        # Load the DRM driver for the VM's GPU so niri can find /dev/dri/card0.
        # QXL is the default for SPICE/KVM VMs; virtio-gpu is used when the VM
        # display adapter is set to "Virtio" in virt-manager.
        boot.kernelModules = [ "qxl" "virtio-gpu" ];
      }
    ] ++ config.nixosModules;
  };
}
