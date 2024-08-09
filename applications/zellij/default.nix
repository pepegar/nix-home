{ ... }:

{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "nord";
      default_layout = "compact";
    };
  };
}
