{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    tmuxp.enable = true;
    plugins = with pkgs; [
      tmuxPlugins.cpu
      tmuxPlugins.battery
    ];
  };
}
