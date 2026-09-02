_: {
  # Hide launcher clutter: apps we have installed (directly or as a
  # dependency of something else) but never want to see in the app launcher.
  # A minimal override .desktop file with NoDisplay=true in
  # ~/.local/share/applications takes precedence over the same Desktop File
  # ID shipped by the package, per the XDG Desktop Entry Specification.
  config.hmModules = [
    {
      xdg.dataFile =
        let
          hidden = ''
            [Desktop Entry]
            Type=Application
            NoDisplay=true
          '';
        in
        {
          "applications/blueman-manager.desktop".text = hidden; # Bluetooth Manager
          "applications/htop.desktop".text = hidden;
          "applications/base.desktop".text = hidden; # LibreOffice Base
          "applications/startcenter.desktop".text = hidden; # LibreOffice
          "applications/math.desktop".text = hidden; # LibreOffice Math
          "applications/draw.desktop".text = hidden; # LibreOffice Draw
          "applications/dev.noctalia.Noctalia.desktop".text = hidden; # Noctalia
          "applications/org.pulseaudio.pavucontrol.desktop".text = hidden; # Volume Control
        };
    }
  ];
}
