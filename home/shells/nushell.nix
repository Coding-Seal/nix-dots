# Nushell configuration.
# Not the default shell, but available by running `nu`.
# Nushell treats command output as structured data (tables, records)
# rather than plain text — great for scripting once you learn it.
{ ... }:

{
  programs.nushell = {
    enable = true;

    configFile.text = ''
      $env.config = {
          show_banner: false

          # Vi-style editing in the prompt (Esc to enter normal mode)
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

      # Aliases
      alias ls  = eza --icons
      alias ll  = eza -la --icons
      alias lt  = eza --tree --icons
      alias cat = bat
    '';

    envFile.text = ''
      # zoxide (smart cd)
      zoxide init nushell | save -f ~/.zoxide.nu

      $env.EDITOR = "nvim"
    '';

    loginFile.text = ''
      source ~/.zoxide.nu
    '';
  };
}
