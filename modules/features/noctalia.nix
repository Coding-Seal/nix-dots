{ inputs, ... }:
{
  config.hmModules = [
    inputs.noctalia.homeModules.default
    {
      programs.noctalia-shell.enable = true;
    }
  ];
}
