{ inputs, ... }:
{
  # Importing the NixOS module (rather than just the HM module) means Stylix
  # auto-injects itself into every home-manager user via `home-manager.sharedModules` —
  # no separate hmModules entry needed, and `config.lib.stylix.colors` /
  # `config.stylix.image` become available in every HM module (e.g.
  # noctalia.nix, which builds its own customPalettes.stylix from this --
  # nixpkgs' bundled Stylix "noctalia" target only wires the deprecated
  # programs.noctalia-shell option, not the real programs.noctalia this repo
  # uses, so that part has to be done by hand rather than via autoEnable).
  config.nixosModules = [
    inputs.stylix.nixosModules.stylix
    ({ pkgs, ... }: {
      stylix = {
        enable = true;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
        image = ../../../wallpaper/Szeth_Enters_The_Battle_by_Marie_Seeberger.jpg;

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.fira-mono;
            name = "FiraMono Nerd Font Mono";
          };
          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
          };
        };
      };
    })
  ];
}
