{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
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
      '';
  };
}
