{
  inputs,
  pkgs,
  ...
}: {
  programs.wezterm = {
    enable = true;
    package = inputs.wezterm-flake.packages.${pkgs.system}.default;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
