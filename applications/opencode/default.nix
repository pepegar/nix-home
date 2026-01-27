{...}: let
  secrets = import ../../secrets.nix;
  opencodeConfig = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    provider = {
      litellm = {
        npm = "@ai-sdk/openai-compatible";
        name = "LiteLLM";
        options = {
          baseURL = "${secrets.LITELLM_BASE_URL}v1";
          apiKey = secrets.LITELLM_AUTH_TOKEN;
        };
        models = {
          "anthropic/claude-opus-4-5" = {
            name = "Claude Opus 4.5";
            attachment = true;
          };
          "anthropic/claude-haiku-4-5-20251001" = {
            name = "Claude Haiku 4.5";
            attachment = true;
          };
        };
      };
    };
  };
in {
  xdg.configFile."opencode/opencode.json".text = opencodeConfig;
}
