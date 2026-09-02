_: {
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.telegram-desktop ];
    })
  ];
}
