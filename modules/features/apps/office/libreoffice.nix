_: {
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.libreoffice-fresh ];

      # No CUPS service is configured on this system, but LibreOffice still
      # probes it on every document open to fetch printer/page info. It tries
      # ::1:631 first; with nothing listening there, the SYN just hangs until
      # the kernel's retry timeout gives up (~30s) before falling back. This
      # skips the CUPS probe entirely — opening a real .docx drops from ~30s
      # to ~2s.
      home.sessionVariables.SAL_DISABLE_CUPS = "true";
    })
  ];
}
