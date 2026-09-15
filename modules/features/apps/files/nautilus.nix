_: {
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.nautilus ];
    })
  ];
}
