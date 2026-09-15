{ inputs, ... }:
{
  # herdr isn't in the pinned nixos-26.05 nixpkgs yet — pull it from
  # nixpkgs-unstable instead of tracking a separate herdr flake.
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = [ inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.herdr ];

      # "system" routes toast delivery through the desktop's own notification
      # service (Noctalia here) instead of herdr's in-app toast or an
      # outer-terminal escape sequence.
      xdg.configFile."herdr/config.toml".text = ''
        onboarding = false

        [ui.toast]
        delivery = "system"

        [ui.sound]
        enabled = true
      '';
    })
  ];
}
