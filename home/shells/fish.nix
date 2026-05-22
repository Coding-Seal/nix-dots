# Fish shell — default login shell.
# Fish is beginner-friendly: autosuggestions and syntax highlighting work
# out of the box with no plugins needed.
{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting ""   # no "Welcome to fish" message on startup

      # zoxide (smart cd) — type `z <partial-dir-name>` to jump to it
      zoxide init fish | source
    '';

    # Abbreviations expand when you press Space, unlike aliases.
    # e.g. type "ls " and it becomes "eza --icons " before running
    shellAbbrs = {
      ls  = "eza --icons";
      ll  = "eza -la --icons";
      lt  = "eza --tree --icons";
      cat = "bat";
      cd  = "z";
    };
  };
}
