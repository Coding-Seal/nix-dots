_: {
  config.hmModules = [
    {
      programs = {
        fish = {
          enable = true;
          interactiveShellInit = ''
            set fish_greeting ""
            zoxide init fish | source
          '';
          shellAbbrs = {
            ls = "eza --icons";
            ll = "eza -la --icons";
            lt = "eza --tree --icons";
            cat = "bat";
            cd = "z";
          };
        };

        starship = {
          enable = true;
          enableFishIntegration = true;
          settings = {
            format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
            character = {
              success_symbol = "[❯](bold #7aa2f7)";
              error_symbol = "[❯](bold #f7768e)";
              vimcmd_symbol = "[❮](bold #9ece6a)";
            };
            directory = {
              style = "bold #7dcfff";
              truncation_length = 3;
              truncate_to_repo = true;
            };
            git_branch = {
              symbol = " ";
              style = "bold #bb9af7";
            };
            git_status.style = "#f7768e";
            cmd_duration = {
              min_time = 2000;
              style = "bold #e0af68";
            };
          };
        };
      };
    }
  ];
}
