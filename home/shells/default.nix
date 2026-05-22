# Shell configuration — all three shells + shared Starship prompt.
# Fish is the default login shell (set in hosts/nixos/default.nix).
# To try another: type `zsh` or `nu` in the terminal.
{ ... }:

{
  imports = [
    ./fish.nix
    ./zsh.nix
    ./nushell.nix
    ./starship.nix
  ];
}
