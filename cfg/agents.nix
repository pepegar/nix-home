{
  inputs,
  system,
  lib,
  ...
}: let
  goodnotes-skills-dir = builtins.readDir "${inputs.goodnotes-skills}";
  goodnotes-skill-names =
    builtins.filter
    (name: goodnotes-skills-dir.${name} == "directory" && name != ".git" && name != "scripts" && name != "__pycache__")
    (builtins.attrNames goodnotes-skills-dir);

  mkGoodnotesSkills = prefix:
    builtins.listToAttrs (map (name: {
        name = "${prefix}/skills/${name}";
        value = {
          source = "${inputs.goodnotes-skills}/${name}";
          recursive = true;
        };
      })
      goodnotes-skill-names);
in {
  home.activation.installPlaywrightCli = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! command -v playwright-cli &>/dev/null && command -v npm &>/dev/null; then
      run --quiet /bin/sh -c 'export PATH="/opt/homebrew/bin:$PATH" && npm install -g @playwright/cli'
    fi
  '';

  home.file =
    {
      ".agents/skills" = {
        source = ../skills;
        recursive = true;
      };

      ".agents/skills/tui-wright" = {
        source = "${inputs.tui-wright.skills}/tui-wright";
        recursive = true;
      };

      ".agents/skills/configuration" = {
        source = "${inputs.gent.packages.${system}.skill}";
        recursive = true;
      };

      ".agents/skills/playwright-cli" = {
        source = "${inputs.playwright-cli}/skills/playwright-cli";
        recursive = true;
      };

      ".agents/skills/a11y-debugging" = {
        source = "${inputs.chrome-devtools-mcp}/skills/a11y-debugging";
        recursive = true;
      };

      ".agents/skills/chrome-devtools" = {
        source = "${inputs.chrome-devtools-mcp}/skills/chrome-devtools";
        recursive = true;
      };

      ".agents/skills/chrome-devtools-cli" = {
        source = "${inputs.chrome-devtools-mcp}/skills/chrome-devtools-cli";
        recursive = true;
      };

      ".agents/skills/debug-optimize-lcp" = {
        source = "${inputs.chrome-devtools-mcp}/skills/debug-optimize-lcp";
        recursive = true;
      };

      ".agents/skills/troubleshooting" = {
        source = "${inputs.chrome-devtools-mcp}/skills/troubleshooting";
        recursive = true;
      };

      ".agents/AGENTS.md" = {
        source = ../agents/AGENTS.md;
      };

      ".claude/skills" = {
        source = ../skills;
        recursive = true;
      };

      ".claude/skills/tui-wright" = {
        source = "${inputs.tui-wright.skills}/tui-wright";
        recursive = true;
      };

      ".claude/skills/playwright-cli" = {
        source = "${inputs.playwright-cli}/skills/playwright-cli";
        recursive = true;
      };

      ".claude/skills/a11y-debugging" = {
        source = "${inputs.chrome-devtools-mcp}/skills/a11y-debugging";
        recursive = true;
      };

      ".claude/skills/chrome-devtools" = {
        source = "${inputs.chrome-devtools-mcp}/skills/chrome-devtools";
        recursive = true;
      };

      ".claude/skills/chrome-devtools-cli" = {
        source = "${inputs.chrome-devtools-mcp}/skills/chrome-devtools-cli";
        recursive = true;
      };

      ".claude/skills/debug-optimize-lcp" = {
        source = "${inputs.chrome-devtools-mcp}/skills/debug-optimize-lcp";
        recursive = true;
      };

      ".claude/skills/troubleshooting" = {
        source = "${inputs.chrome-devtools-mcp}/skills/troubleshooting";
        recursive = true;
      };

      ".claude/skills/configuration" = {
        source = "${inputs.gent.packages.${system}.skill}";
        recursive = true;
      };
    }
    // mkGoodnotesSkills ".agents"
    // mkGoodnotesSkills ".claude";
}
