{...}: let
  secrets = import ../../secrets.nix;
  claudeConfig = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    env = {
      ANTHROPIC_AUTH_TOKEN = secrets.ANTHROPIC_AUTH_TOKEN;
      ANTHROPIC_BASE_URL = secrets.ANTHROPIC_BASE_URL;
      ANTHROPIC_SMALL_FAST_MODEL = secrets.ANTHROPIC_SMALL_FAST_MODEL;
      ANTHROPIC_MODEL = secrets.ANTHROPIC_MODEL;
    };
  };
in {
  home.file.".claude/settings.json".text = builtins.toJSON claudeConfig;
  home.file.".claude/agents/jira-manager.md".source = ./jira-manager.md;
  home.file.".claude/agents/github-manager.md".source = ./github-manager.md;
}
