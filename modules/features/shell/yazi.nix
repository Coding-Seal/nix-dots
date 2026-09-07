_: {
  # Yazi (the file manager) and everything about it — install, desktop
  # integration, and all plugins including gvfs for SMB/NFS/etc. share
  # browsing. The system-wide gvfs/cifs-utils/nfs-utils/glib packages that
  # the gvfs plugin needs live in apps/network/network-shares.nix instead,
  # since those aren't Yazi-specific (GTK file pickers use them too).
  config.hmModules = [
    ({ pkgs, ... }: {
      programs.yazi = {
        enable = true;

        plugins = {
          # SMB/NFS/SFTP/FTP/etc. share browsing via gvfs+gio.
          gvfs = {
            package = pkgs.yaziPlugins.gvfs;
            setup = true;
          };

          # General QoL plugins, no init.lua setup() needed for any of
          # these — `plugin <name>` in keymap.toml loads them on-demand
          # from the linked plugins/<name>.yazi directory.
          mount = pkgs.yaziPlugins.mount;
          smart-enter = pkgs.yaziPlugins.smart-enter;
          smart-filter = pkgs.yaziPlugins.smart-filter;
          smart-paste = pkgs.yaziPlugins.smart-paste;
          chmod = pkgs.yaziPlugins.chmod;
          diff = pkgs.yaziPlugins.diff;
        };

        keymap.mgr.prepend_keymap = [
          # gvfs: `M m` mounts+jumps to a device, `M a` adds a new mount
          # URI (e.g. smb://user@host/share), `M u` unmounts, and `g m`
          # jumps back to an already-mounted device. Password prompts
          # aren't persisted since there's no secret-service/keyring
          # running on these hosts.
          {
            on = [
              "M"
              "m"
            ];
            run = "plugin gvfs -- select-then-mount --jump";
            desc = "Mount and jump to device";
          }
          {
            on = [
              "M"
              "u"
            ];
            run = "plugin gvfs -- select-then-unmount";
            desc = "Unmount device";
          }
          {
            on = [
              "M"
              "a"
            ];
            run = "plugin gvfs -- add-mount";
            desc = "Add GVFS mount URI (e.g. smb://user@host/share)";
          }
          {
            on = [
              "g"
              "m"
            ];
            run = "plugin gvfs -- jump-to-device";
            desc = "Jump to device mount point";
          }

          # Local disk/USB mounts (udisksctl/lsblk/eject). Bound to "U"
          # rather than the plugin's own suggested "M" because that's
          # already claimed above as a prefix (M m/M u/M a) for gvfs.
          {
            on = [ "U" ];
            run = "plugin mount";
            desc = "Manage local disk mounts (USB, etc.)";
          }
          {
            on = [ "l" ];
            run = "plugin smart-enter";
            desc = "Enter the child directory, or open the file";
          }
          {
            on = [ "F" ];
            run = "plugin smart-filter";
            desc = "Smart filter";
          }
          {
            on = [ "p" ];
            run = "plugin smart-paste";
            desc = "Paste into the hovered directory or CWD";
          }
          {
            on = [
              "c"
              "m"
            ];
            run = "plugin chmod";
            desc = "Chmod on selected files";
          }
          {
            on = [ "<C-d>" ];
            run = "plugin diff";
            desc = "Diff the selected with the hovered file";
          }
        ];
      };

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
