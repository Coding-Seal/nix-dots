_: {
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.libreoffice-fresh ];
    })
  ];
}
