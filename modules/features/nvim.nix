{ ... }:
{
  config.hmModules = [
    ({ pkgs, ... }: {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };

      xdg.configFile."nvim" = {
        source = ../../config/nvim;
        recursive = true;
      };

      home.packages = with pkgs; [
        nil
        lua-language-server
        gcc
        gnumake
        lazygit
        nodejs
        prettierd
        stylua
      ];
    })
  ];
}
