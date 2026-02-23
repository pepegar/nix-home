{...}: {
  home.file.".agents/skills" = {
    source = ../skills;
    recursive = true;
  };

  home.file.".agents/AGENTS.md" = {
    source = ../agents/AGENTS.md;
  };
}
