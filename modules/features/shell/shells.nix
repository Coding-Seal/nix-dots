{ ... }:
{
  config.hmModules = [
    {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting ""
          zoxide init fish | source
        '';
        shellAbbrs = {
          ls  = "eza --icons";
          ll  = "eza -la --icons";
          lt  = "eza --tree --icons";
          cat = "bat";
          cd  = "z";
        };
      };

      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        history = {
          size = 50000;
          save = 50000;
          ignoreDups = true;
          share = true;
        };
        initContent = ''
          eval "$(zoxide init zsh)"
          alias ls='eza --icons'
          alias ll='eza -la --icons'
          alias lt='eza --tree --icons'
          alias cat='bat'
        '';
      };

      programs.nushell = {
        enable = true;
        configFile.text = ''
          $env.config = {
              show_banner: false
              edit_mode: vi
              history: {
                  max_size: 50000
                  sync_on_enter: true
                  file_format: "sqlite"
              }
              completions: {
                  case_sensitive: false
                  quick: true
                  partial: true
                  algorithm: "fuzzy"
              }
              cursor_shape: {
                  vi_insert: line
                  vi_normal: block
              }
          }
          alias ls  = eza --icons
          alias ll  = eza -la --icons
          alias lt  = eza --tree --icons
          alias cat = bat
        '';
        envFile.text = ''
          zoxide init nushell | save -f ~/.zoxide.nu
          $env.EDITOR = "nvim"
        '';
        loginFile.text = ''
          source ~/.zoxide.nu
        '';
      };

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
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
    }
  ];
}
