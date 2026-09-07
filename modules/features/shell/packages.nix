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

      # Managed via programs.yazi (not home.packages) so other modules can
      # declare plugins/keymap against it — see network-shares.nix for the
      # gvfs plugin that adds SMB browsing.
      programs.yazi.enable = true;

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

      # Make it the actual default handler for directories, not just an
      # entry that shows up in "open with" menus.
      xdg.mimeApps = {
        enable = true;
        defaultApplications."inode/directory" = "yazi.desktop";
      };
    })
  ];
}
