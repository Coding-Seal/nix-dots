_: {
  # nixpkgs renamed the `nekoray` package to `throne` — Throne (throneproj/Throne)
  # is the continuation of the original NekoRay project: same Qt GUI, with
  # subscription groups and VLESS/VMess/Trojan/Shadowsocks/Hysteria support
  # via bundled Xray/sing-box cores.
  config.hmModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.throne ];
    })
  ];
}
