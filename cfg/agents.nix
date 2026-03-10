{
  inputs,
  system,
  lib,
  ...
}: {
  home.activation.installPlaywrightCli = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! command -v playwright-cli &>/dev/null; then
      run --quiet /bin/sh -c 'export PATH="/opt/homebrew/bin:$PATH" && npm install -g @playwright/cli'
    fi
  '';
  home.file.".agents/skills" = {
    source = ../skills;
    recursive = true;
  };

  home.file.".agents/skills/tui-wright" = {
    source = "${inputs.tui-wright.skills}/tui-wright";
    recursive = true;
  };

  home.file.".agents/skills/configuration" = {
    source = "${inputs.gent.packages.${system}.skill}";
    recursive = true;
  };

  home.file.".agents/skills/playwright-cli" = {
    source = "${inputs.playwright-cli}/skills/playwright-cli";
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

  home.file.".claude/skills/playwright-cli" = {
    source = "${inputs.playwright-cli}/skills/playwright-cli";
    recursive = true;
  };

  home.file.".claude/skills/configuration" = {
    source = "${inputs.gent.packages.${system}.skill}";
    recursive = true;
  };
}
