{...}: let
  secrets = import ../../secrets.nix;
  claudeConfig = {
    env = {
      ANTHROPIC_AUTH_TOKEN = secrets.ANTHROPIC_AUTH_TOKEN;
      ANTHROPIC_BASE_URL = secrets.ANTHROPIC_BASE_URL;
      ANTHROPIC_SMALL_FAST_MODEL = secrets.ANTHROPIC_SMALL_FAST_MODEL;
      ANTHROPIC_MODEL = secrets.ANTHROPIC_MODEL;
    };
  };
in {
  programs.claude-code = {
    enable = true;
    settings = claudeConfig;
  };
}
