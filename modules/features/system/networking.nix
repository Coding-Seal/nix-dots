{ ... }:
{
  config.nixosModules = [
    {
      networking.networkmanager.enable = true;
    }
  ];
}
