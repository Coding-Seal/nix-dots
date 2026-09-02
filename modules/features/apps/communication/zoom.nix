_: {
  # Personal/leisure app — opted into via personalHmModules, so it's absent
  # on the work laptop (scadrial) without any per-host conditional.
  config.personalHmModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.zoom-us ];
    })
  ];
}
