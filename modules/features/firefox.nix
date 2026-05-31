{ ... }:
{
  config.hmModules = [
    ({ pkgs, ... }: {
      programs.firefox = {
        enable = true;
        configPath = ".mozilla/firefox";
        profiles.default = {
          isDefault = true;
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            bitwarden
            vimium
            languagetool
          ];
        };
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html"               = "firefox.desktop";
          "x-scheme-handler/http"   = "firefox.desktop";
          "x-scheme-handler/https"  = "firefox.desktop";
          "x-scheme-handler/about"  = "firefox.desktop";
          "x-scheme-handler/unknown" = "firefox.desktop";
        };
      };
    })
  ];
}
