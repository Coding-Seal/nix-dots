{ config, ... }:
{
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = with pkgs; [
        (pkgs.callPackage ../../../pkgs/rtk.nix { })
        git
        gh
        claude-code
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
        quickshell
        nerd-fonts.jetbrains-mono
        nh
      ];

      # nh needs to know which flake to operate on by default
      home.sessionVariables.NH_FLAKE = "/home/${config.username}/nix-dots";

      # Override yazi's desktop entry so launchers open it in a terminal
      xdg.desktopEntries.yazi = {
        name = "Yazi File Manager";
        exec = "wezterm start -- yazi %f";
        terminal = false;
        icon = "yazi";
        categories = [
          "System"
          "FileManager"
          "FileTools"
        ];
        mimeType = [ "inode/directory" ];
      };
    })
  ];
}
