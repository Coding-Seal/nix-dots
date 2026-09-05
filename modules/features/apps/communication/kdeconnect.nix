_: {
  # Installs kdeconnect-kde (daemon, CLI, indicator, settings app) and opens
  # the TCP/UDP port range (1714-1764) it needs for LAN discovery/pairing.
  config.nixosModules = [
    {
      programs.kdeconnect.enable = true;
    }
  ];
}
