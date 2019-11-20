{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    tmuxp.enable = true;
    plugins = with pkgs; [
      tmuxPlugins.cpu
      tmuxPlugins.battery
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60'
        '';
      }
    ];
    extraConfig = ''
      # Open ~/.tmux.conf in vim and reload settings on quit
      unbind e
      bind e new-window -n '~/.tmux.conf' "sh -c 'nvim ~/.tmux.conf && tmux source ~/.tmux.conf'"

      # Use r to quickly reload tmux settings
      unbind r
      bind r \
	source-file ~/.tmux.conf \;\
	display 'Reloaded tmux config'
      # Set the history limit so we get lots of scrollback.
      setw -g history-limit 50000000

      # Length of tmux status line
      set -g status-left-length 30
      set -g status-right-length 150
      
      set-option -g status "on"
      
      set-option -g status-right "\
      #[fg=colour214, bg=colour237] \
      #[fg=colour246, bg=colour237]  %b %d %y \
      #[fg=colour109]  %H:%M \
      #[fg=colour248, bg=colour239]"
      
      set-window-option -g window-status-current-format "\
      #[fg=colour237, bg=colour214]\
      #[fg=colour239, bg=colour214] #I* \
      #[fg=colour239, bg=colour214, bold] #W \
      #[fg=colour214, bg=colour237]"
      
      set-window-option -g window-status-format "\
      #[fg=colour237,bg=colour239,noitalics]\
      #[fg=colour223,bg=colour239] #I \
      #[fg=colour223, bg=colour239] #W \
      #[fg=colour239, bg=colour237]"
      
      # Set the history limit so we get lots of scrollback.
      setw -g history-limit 50000000
      '';
  };
}
