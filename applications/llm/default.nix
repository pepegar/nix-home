{pkgs, ...}: let
  llmConfig = [
    {
      model_id = "litellm-opus";
      model_name = "anthropic/claude-opus-4-1-20250805";
      api_base = "https://litellm.ml.goodnotesbeta.com";
      api_key_name = "litellm";
    }
    {
      model_id = "litellm-sonnet";
      model_name = "anthropic/claude-sonnet-4-20250514";
      api_base = "https://litellm.ml.goodnotesbeta.com";
      api_key_name = "litellm";
    }
    {
      model_id = "litellm-haiku";
      model_name = "anthropic/claude-3-5-haiku-latest";
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
