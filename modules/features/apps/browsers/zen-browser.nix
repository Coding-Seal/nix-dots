{ inputs, ... }:
{
  config.hmModules = [
    inputs.zen-browser.homeModules.default
    {
      programs.zen-browser = {
        enable = true;
        profiles.default.isDefault = true;
        setAsDefaultBrowser = true;
      };

      xdg.mimeApps.enable = true;

      # Stylix's zen-browser target has no way to discover profile names on its
      # own (unlike its firefox target) — it warns and no-ops without this.
      stylix.targets.zen-browser.profileNames = [ "default" ];
    }
  ];
}
