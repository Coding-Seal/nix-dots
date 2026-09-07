_: {
  # General Yazi QoL plugins (unrelated to SMB/network shares, see
  # network-shares.nix for the gvfs plugin). All are bare packages with no
  # init.lua setup() needed — `plugin <name>` in keymap.toml loads them
  # on-demand from the linked plugins/<name>.yazi directory.
  config.hmModules = [
    ({ pkgs, ... }: {
      programs.yazi = {
        plugins = {
          mount = pkgs.yaziPlugins.mount;
          smart-enter = pkgs.yaziPlugins.smart-enter;
          smart-filter = pkgs.yaziPlugins.smart-filter;
          smart-paste = pkgs.yaziPlugins.smart-paste;
          chmod = pkgs.yaziPlugins.chmod;
          diff = pkgs.yaziPlugins.diff;
        };
        keymap.mgr.prepend_keymap = [
          # Local disk/USB mounts (udisksctl/lsblk/eject). Bound to "U" rather
          # than the plugin's own suggested "M" because network-shares.nix
          # already claims "M" as a prefix (M m/M u/M a) for gvfs.
          {
            on = [ "U" ];
            run = "plugin mount";
            desc = "Manage local disk mounts (USB, etc.)";
          }
          {
            on = [ "l" ];
            run = "plugin smart-enter";
            desc = "Enter the child directory, or open the file";
          }
          {
            on = [ "F" ];
            run = "plugin smart-filter";
            desc = "Smart filter";
          }
          {
            on = [ "p" ];
            run = "plugin smart-paste";
            desc = "Paste into the hovered directory or CWD";
          }
          {
            on = [
              "c"
              "m"
            ];
            run = "plugin chmod";
            desc = "Chmod on selected files";
          }
          {
            on = [ "<C-d>" ];
            run = "plugin diff";
            desc = "Diff the selected with the hovered file";
          }
        ];
      };
    })
  ];
}
