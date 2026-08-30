_: {
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

      # Stylix's firefox target can't discover profile names on its own.
      stylix.targets.firefox.profileNames = [ "default" ];
    })
  ];
}
