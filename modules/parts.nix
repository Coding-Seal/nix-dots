{ lib, ... }:
{
  config.systems = [ "x86_64-linux" ];

  options = {
    # TODO: change to your actual username
    username = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
    };

    # NixOS modules contributed by feature files — assembled in nixos.nix
    nixosModules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [];
    };

    # Home Manager modules contributed by feature files — assembled in nixos.nix
    hmModules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [];
    };
  };
}
