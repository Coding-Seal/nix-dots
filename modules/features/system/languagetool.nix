_: {
  # Self-hosted LanguageTool server for the browser extension (already
  # installed via Firefox's NUR addon in apps/browsers/firefox.nix) to point
  # at instead of the public API. Bound to loopback only — no auth on the
  # LanguageTool HTTP API, so it must not be reachable from the LAN.
  config.nixosModules = [
    {
      virtualisation.podman.enable = true;
      virtualisation.oci-containers = {
        backend = "podman";
        containers.languagetool = {
          image = "erikvl87/languagetool:latest";
          ports = [ "127.0.0.1:8010:8010" ];
          autoStart = true;
        };
      };
    }
  ];
}
