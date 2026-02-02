{...}: let
  secrets = import ../../secrets.nix;
in {
  home.file.".codex/skills" = {
    source = ../../skills;
    recursive = true;
  };

  home.sessionVariables = {
    OPENAI_BASE_URL = secrets.LITELLM_BASE_URL;
    OPENAI_API_KEY = secrets.LITELLM_AUTH_TOKEN;
  };
}
