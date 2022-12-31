{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      sessionist
      sensible
      resurrect
      yank
      pain-control
    ];

    extraConfig = ''
      set-option -g mouse on
      set-option -g status-position top
    '';
  };
}
