_: {
  config.hmModules = [
    (_: {
      programs.gpg.enable = true;

      services.gpg-agent = {
        enable = true;
        # HM defaults to pinentry-gnome3, which pairs with the adw-gtk3/GTK
        # theming already set up in theming.nix.
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
    })
  ];
}
