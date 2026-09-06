{ lib, ... }:
{
  config.systems = [ "x86_64-linux" ];

  options = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "r.ganiullin";
    };

    # NixOS modules contributed by feature files — assembled in nixos.nix
    nixosModules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [ ];
    };

    # Home Manager modules contributed by feature files — assembled in nixos.nix
    hmModules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [ ];
    };

    # Personal-use HM modules (leisure apps, personal dev tools) — opted into
    # explicitly per host, unlike hmModules which every host gets. Only
    # taldain/lumar (personal machines) pull these in; scadrial (work
    # laptop) does not.
    personalHmModules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [ ];
    };
  };
}
