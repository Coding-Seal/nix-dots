{ ... }:
{
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.google-chrome ];
    })
  ];
}
