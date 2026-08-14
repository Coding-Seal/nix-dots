{ ... }:
{
  config.hmModules = [
    ({ ... }: {
      programs.zed-editor = {
        enable = true;
        extensions = [ "go" ];
        userSettings = {
          # Spawn a shell via direnv before starting language servers/terminals,
          # so per-project devenv shells (e.g. languages.go) are picked up.
          load_direnv = "shell_hook";
          lsp.gopls.binary.path_lookup = true;
        };
      };
    })
  ];
}
