{ ... }:
{
  # dconf backs GTK's gsettings; Stylix's gtk target requires this to be set
  # at the system level (it can't enable it itself from the HM side).
  config.nixosModules = [
    {
      programs.dconf.enable = true;
    }
  ];

  config.hmModules = [
    ({ pkgs, ... }: {
      # adw-gtk3 and qt6ct are pulled in declaratively by Stylix's gtk/qt
      # targets (gtk.theme.package, qt.platformTheme.name) — no need to
      # install them manually here.
      home.packages = with pkgs; [
        nwg-look
        gsettings-desktop-schemas
      ];
    })
  ];
}
