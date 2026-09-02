_: {
  # nixpkgs renamed the `nekoray` package to `throne` — Throne (throneproj/Throne)
  # is the continuation of the original NekoRay project: same Qt GUI, with
  # subscription groups and VLESS/VMess/Trojan/Shadowsocks/Hysteria support
  # via bundled Xray/sing-box cores.
  #
  # Uses nixpkgs' own programs.throne module (NixOS-level, not HM) rather than
  # a raw package install: it wraps the sing-box Core binary via
  # security.wrappers with cap_net_admin/cap_net_raw so TUN mode works without
  # running the whole GUI as root, and adds a polkit rule so systemd-resolved
  # doesn't triple-prompt for DNS control while TUN mode is active.
  config.nixosModules = [
    {
      programs.throne = {
        enable = true;
        tunMode.enable = true;
      };
    }
  ];
}
