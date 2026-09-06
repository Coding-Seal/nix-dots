{ inputs, ... }:
{
  config.hmModules = [
    inputs.zen-browser.homeModules.default
    ({ pkgs, ... }: {
      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        profiles.default = {
          isDefault = true;

          # Via the NUR rycee repo (already wired system-wide in system.nix).
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            bitwarden
            vimium
            languagetool
          ];

          # In-browser preferences (prefs.js) — user can still override these
          # in about:config. See "zen." in about:config for the full list.
          settings = {
            "zen.workspaces.continue-where-left-off" = true;
            "zen.welcome-screen.seen" = true;
            "zen.urlbar.behavior" = "float";
            "zen.tabs.vertical.right-side" = true;
          };

          search = {
            force = true;
            default = "ddg";
            engines = {
              nixpkgs = {
                name = "NixOS Packages";
                urls = [ { template = "https://search.nixos.org/packages?query={searchTerms}"; } ];
                definedAliases = [ "@nx" ];
              };
              github = {
                name = "GitHub";
                urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
                definedAliases = [ "@gh" ];
              };
              perplexity = {
                name = "Perplexity";
                urls = [ { template = "https://www.perplexity.ai/search?q={searchTerms}"; } ];
                definedAliases = [ "@pplx" ];
              };
              yandex = {
                name = "Yandex";
                urls = [ { template = "https://yandex.ru/search/?text={searchTerms}"; } ];
                definedAliases = [ "@ya" ];
              };
              google = {
                name = "Google";
                urls = [ { template = "https://www.google.com/search?q={searchTerms}"; } ];
                definedAliases = [ "@g" ];
              };
            };
          };
        };
      };

      xdg.mimeApps.enable = true;

      # Stylix's zen-browser target has no way to discover profile names on its
      # own (unlike its firefox target) — it warns and no-ops without this.
      stylix.targets.zen-browser.profileNames = [ "default" ];
    })
  ];
}
