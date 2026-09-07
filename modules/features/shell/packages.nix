{ config, ... }:
{
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = with pkgs; [
        (pkgs.callPackage ../../../pkgs/rtk.nix { })
        git
        gh
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
        quickshell
        nerd-fonts.jetbrains-mono
        nh
      ];

      # nh needs to know which flake to operate on by default
      home.sessionVariables.NH_FLAKE = "/home/${config.username}/Projects/nix-dots";
    })
  ];
}
