_: {
  # gvfs lets file pickers/managers (GTK's file-chooser portal, etc.) browse
  # smb://, nfs://, ftp:// etc. without a persistent mount; the smb backend
  # needs cifs-utils on PATH for actual SMB auth+mount, and nfs-utils covers
  # the NFS gvfs backend plus manual `mount -t nfs`. glib provides the `gio`
  # CLI (not bundled by services.gvfs itself) that both manual use and the
  # Yazi gvfs plugin below shell out to for mounting/unmounting.
  config.nixosModules = [
    ({ pkgs, ... }: {
      services.gvfs.enable = true;

      environment.systemPackages = with pkgs; [
        cifs-utils
        nfs-utils
        glib
      ];
    })
  ];

  # Yazi (the file manager, configured in shell/packages.nix) has no native
  # smb:// browsing, so add the gvfs plugin: `M m` mounts+jumps to a device,
  # `M a` adds a new mount URI (smb://user@host/share), `M u` unmounts, and
  # `g m` jumps back to an already-mounted device. Password prompts aren't
  # persisted since there's no secret-service/keyring running on these hosts.
  config.hmModules = [
    ({ pkgs, ... }: {
      programs.yazi = {
        plugins.gvfs = {
          package = pkgs.yaziPlugins.gvfs;
          setup = true;
        };
        keymap.mgr.prepend_keymap = [
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
        ];
      };
    })
  ];
}
