{ inputs, ... }:
{
  config.nixosModules = [
    inputs.noctalia.nixosModules.default
    {
      programs.noctalia.recommendedServices.enable = true;
    }
  ];

  config.hmModules = [
    inputs.noctalia.homeModules.default
    {
      programs.noctalia.enable = true;
    }
  ];
}
