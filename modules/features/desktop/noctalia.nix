{ inputs, ... }:
{
  config.nixosModules = [
    inputs.noctalia.nixosModules.default
    {
      programs.noctalia.recommendedServices.enable = true;
    }
  ];

  config.hmModules = [
    inputs.noctalia.homeModules.default
    {
      # GTK/Qt/KColorScheme theming is owned by Stylix's own targets now
      # (modules/features/desktop/stylix.nix), which write nix-managed files
      # to the same paths (e.g. gtk-3.0/gtk.css) — enabling Noctalia's own
      # builtin templates for these would fight over them. Noctalia's palette
      # itself still comes from Stylix via programs.noctalia.customPalettes.
      programs.noctalia.enable = true;
    }
  ];
}
