{
  inputs,
  system,
  pkgs,
  ...
}: let
  skillsTree = pkgs.runCommand "agents-skills" {} ''
    mkdir -p $out
    for d in ${../skills}/*; do
      ln -s "$d" "$out/$(basename "$d")"
    done
    ln -sfn ${inputs.tui-wright.skills}/tui-wright $out/tui-wright
    ln -sfn ${inputs.gent.packages.${system}.skill} $out/configuration
    for s in a11y-debugging chrome-devtools chrome-devtools-cli debug-optimize-lcp troubleshooting; do
      ln -sfn ${inputs.chrome-devtools-mcp}/skills/$s $out/$s
    done
  '';
in {
  home.file = {
    ".agents/skills".source = skillsTree;
    ".agents/AGENTS.md".source = ../agents/AGENTS.md;
    ".claude/skills".source = skillsTree;
  };
}
