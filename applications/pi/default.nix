{...}: {
  home.file.".pi/agent/skills" = {
    source = ../../skills;
    recursive = true;
  };
}
