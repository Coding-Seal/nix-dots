_: {
  # gvfs lets file pickers/managers (GTK's file-chooser portal, Yazi's gvfs
  # plugin — see shell/yazi.nix — etc.) browse smb://, nfs://, ftp:// etc.
  # without a persistent mount; the smb backend needs cifs-utils on PATH for
  # actual SMB auth+mount, and nfs-utils covers the NFS gvfs backend plus
  # manual `mount -t nfs`. glib provides the `gio` CLI (not bundled by
  # services.gvfs itself) that both manual use and the Yazi gvfs plugin
  # shell out to for mounting/unmounting.
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
}
