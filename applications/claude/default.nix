{...}: let
  secrets = import ../../secrets.nix;
in {
  home.sessionVariables = {
    ANTHROPIC_AUTH_TOKEN = secrets.ANTHROPIC_AUTH_TOKEN;
    ANTHROPIC_BASE_URL = secrets.ANTHROPIC_BASE_URL;
    ANTHROPIC_SMALL_FAST_MODEL = secrets.ANTHROPIC_SMALL_FAST_MODEL;
    ANTHROPIC_MODEL = secrets.ANTHROPIC_MODEL;
  };

  home.file.".claude/agents/jira-manager.md".source = ./jira-manager.md;
  home.file.".claude/agents/github-manager.md".source = ./github-manager.md;
}
