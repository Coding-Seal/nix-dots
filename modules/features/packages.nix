{ ... }:
{
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = with pkgs; [
        git
        claude-code
        zed-editor
        yazi
        ripgrep
        fd
        bat
        eza
        fzf
        zoxide
        wget
        curl
        htop
        unzip
        wl-clipboard
        grim
        slurp
        brightnessctl
        playerctl
        pavucontrol
        nerd-fonts.jetbrains-mono
      ];
    })
  ];
}
