_: {
  config.hmModules = [
    (
      { pkgs, ... }:
      {
        programs.gpg.enable = true;

        services.gpg-agent = {
          enable = true;
          # HM's pinentry.package option defaults to null (no pinentry-program
          # line written at all) despite its name — must be set explicitly or
          # gpg fails with "No pinentry". pinentry-qt auto-falls-back to a
          # terminal prompt when no display is present, so one package
          # covers both GUI and shell callers.
          pinentry.package = pkgs.pinentry-qt;
          enableSshSupport = false;
        };

        programs.git = {
          enable = true;
          signing = {
            # TODO: replace with your real key fingerprint once generated/imported
            # (gpg --list-secret-keys --keyid-format=long).
            key = "REPLACE_WITH_GPG_KEY_ID";
            signByDefault = true;
          };
        };
      }
    )
  ];
}
