_: {
  # gvfs lets file pickers/managers (GTK's file-chooser portal, etc.) browse
  # smb://, nfs://, ftp:// etc. without a persistent mount; the smb backend
  # needs cifs-utils on PATH for actual SMB auth+mount, and nfs-utils covers
  # the NFS gvfs backend plus manual `mount -t nfs`.
  config.nixosModules = [
    ({ pkgs, ... }: {
      services.gvfs.enable = true;

      environment.systemPackages = with pkgs; [
        cifs-utils
        nfs-utils
      ];
    })
  ];
}
