{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      tmux-fzf
      sessionist
      sensible
      resurrect
      yank
      pain-control
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-fahrenheit false
          set -g @dracula-show-weather false
          set -g @dracula-show-battery false
          set -g @dracula-show-powerline true
        '';
      }
    ];

    extraConfig = ''
      set-option -g mouse on
      set-option -g status-position top
    '';
  };
}
