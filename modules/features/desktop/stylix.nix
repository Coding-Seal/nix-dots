{ inputs, ... }:
{
  # Importing the NixOS module (rather than just the HM module) means Stylix
  # auto-injects itself into every home-manager user via `home-manager.sharedModules` —
  # no separate hmModules entry needed. This is also what lets it derive
  # Noctalia's palette (programs.noctalia.customPalettes.stylix) from the same
  # base16 scheme used everywhere else.
  config.nixosModules = [
    inputs.stylix.nixosModules.stylix
    ({ pkgs, ... }: {
      stylix = {
        enable = true;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

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
