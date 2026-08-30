_: {
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

      # kvantummanager/nwg-look/qt5ct/qt6ct are all theming config tools —
      # kvantummanager and qt5ct/qt6ct pulled in by Stylix's qt target, nwg-look
      # installed above. Keep them installed but hidden from the app launcher
      # since none are meant to be opened by hand day-to-day.
      xdg.desktopEntries = {
        kvantummanager = {
          name = "Kvantum Manager";
          exec = "kvantummanager";
          icon = "kvantum";
          noDisplay = true;
        };
        nwg-look = {
          name = "GTK Settings";
          exec = "nwg-look";
          icon = "nwg-look";
          noDisplay = true;
        };
        qt5ct = {
          name = "Qt5 Settings";
          exec = "qt5ct";
          icon = "preferences-desktop-theme";
          noDisplay = true;
        };
        qt6ct = {
          name = "Qt6 Settings";
          exec = "qt6ct";
          icon = "preferences-desktop-theme";
          noDisplay = true;
        };
      };
    })
  ];
}
