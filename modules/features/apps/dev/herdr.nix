{ inputs, ... }:
{
  # herdr isn't in the pinned nixos-26.05 nixpkgs yet — pull it from
  # nixpkgs-unstable instead of tracking a separate herdr flake.
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = [ inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.herdr ];
    })
  ];
}
