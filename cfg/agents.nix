{inputs, ...}: {
  home.file.".agents/skills" = {
    source = ../skills;
    recursive = true;
  };

  home.file.".agents/skills/tui-wright" = {
    source = "${inputs.tui-wright.skills}/tui-wright";
    recursive = true;
  };

  home.file.".agents/AGENTS.md" = {
    source = ../agents/AGENTS.md;
  };

  home.file.".claude/skills" = {
    source = ../skills;
    recursive = true;
  };

  home.file.".claude/skills/tui-wright" = {
    source = "${inputs.tui-wright.skills}/tui-wright";
    recursive = true;
  };
}
