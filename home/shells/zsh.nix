# Zsh configuration.
# Not the default shell, but available by running `zsh`.
{ ... }:

{
  programs.zsh = {
    enable = true;

    # Quality-of-life features
    autosuggestion.enable = true;    # grey ghost text as you type
    syntaxHighlighting.enable = true; # commands turn green/red before you run them

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      share = true;
    };

    initContent = ''
      # zoxide (smart cd)
      eval "$(zoxide init zsh)"

      # Abbreviation-style aliases
      alias ls='eza --icons'
      alias ll='eza -la --icons'
      alias lt='eza --tree --icons'
      alias cat='bat'
    '';
  };
}
