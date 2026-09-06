_: {
  config.hmModules = [
    {
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = true;
        extraConfig = {
          PROJECTS = "$HOME/Projects";
          SCREENSHOTS = "$HOME/Pictures/Screenshots";
        };
      };
    }
  ];
}
