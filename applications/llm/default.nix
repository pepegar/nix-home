{pkgs, ...}: let
  llmConfig = [
    {
      model_id = "sonnet";
      model_name = "anthropic/claude-sonnet-4-5-20250929";
      api_base = "https://litellm.ml.goodnotesbeta.com";
      api_key_name = "litellm";
    }
    {
      model_id = "haiku";
      model_name = "anthropic/claude-haiku-4-5-20251001";
      api_base = "https://litellm.ml.goodnotesbeta.com";
      api_key_name = "litellm";
    }
  ];
in {
  home.packages = [pkgs.llm];

  home.file."Library/Application Support/io.datasette.llm/extra-openai-models.yaml" = {
    text = builtins.toJSON llmConfig;
  };
}
