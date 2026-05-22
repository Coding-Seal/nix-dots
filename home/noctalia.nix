# Noctalia desktop shell configuration.
# Noctalia provides the visual layer on top of Niri:
# status bar, app dock, notifications, widgets, lock screen.
#
# The homeModules.default import (in home/default.nix) provides
# the programs.noctalia-shell option used here.
#
# Full settings reference: https://docs.noctalia.dev/v4/
{ ... }:

{
  programs.noctalia-shell = {
    enable = true;

    # settings = { ... };
    # Noctalia ships a built-in setup wizard — on first launch it will
    # walk you through picking a color scheme and layout. You can then
    # export your choices back into this settings block for reproducibility.
    # See https://docs.noctalia.dev/v4/ for all available options.
  };
}
