# Starship prompt — works across Fish, Zsh, and Nushell.
# Starship reads git status, language versions, etc. and renders a
# clean, fast prompt. Config below is a minimal Tokyo Night style.
{ ... }:

{
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

      git_status = {
        style = "#f7768e";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bold #e0af68";
      };
    };
  };
}
