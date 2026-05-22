# Home Manager root — user-space config.
# Everything here applies to the user, not the system.
{ pkgs, noctalia, username, ... }:

{
  imports = [
    # Noctalia desktop shell Home Manager module (provides programs.noctalia-shell)
    noctalia.homeModules.default

    ./niri.nix
    ./noctalia.nix
    ./shells/default.nix
    ./wezterm.nix
    ./nvim.nix
    ./firefox.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Common CLI tools available in all shells
  home.packages = with pkgs; [
    # Launcher (open with Mod+D in Niri)
    fuzzel

    # Modern CLI replacements
    ripgrep   # fast grep (also used by Neovim)
    fd        # fast find (also used by Neovim)
    bat       # cat with syntax highlighting
    eza       # ls with colors and icons
    fzf       # fuzzy finder
    zoxide    # smart cd (learns your most-used dirs)

    # System utilities
    wget
    curl
    htop
    unzip

    # Wayland utilities
    wl-clipboard    # copy/paste in Wayland (wl-copy, wl-paste)
    grim            # screenshot tool
    slurp           # select screen region (used with grim)
    brightnessctl   # screen brightness
    playerctl       # media player control (play/pause/next)
    pavucontrol     # audio volume GUI

    # Fonts (icon fonts for terminals and editors)
    nerd-fonts.jetbrains-mono
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Don't change this after initial install — it tracks HM state format version
  home.stateVersion = "25.05";
}
