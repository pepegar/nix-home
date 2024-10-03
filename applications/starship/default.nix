{...}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      format = "$directory$git_branch$\{custom.git_branch_description\}$nix_shell$aws$fill$line_break$character";
      custom.git_branch_description = {
        command = "git config branch.$(git rev-parse --abbrev-ref HEAD 2>/dev/null).description";
        when = "git rev-parse --is-inside-work-tree 2>/dev/null";
        format = "[ - $output]($style) ";
        style = "bold yellow";
      };
      command_timeout = 1000;
      directory.read_only = " ";
      battery = {
        full_symbol = "•";
        charging_symbol = "⇡";
        discharging_symbol = "⇣";
      };
      git_branch = {
        format = "[\\[$branch\\]]($style)";
        style = "bright-black";
      };
      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](bright-black)( $ahead_behind$stashed)]($style) ";
        style = "cyan";
        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };
      git_state = {
        format = "([$state( $progress_current/$progress_total)]($style) )";
        style = "bright-black";
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };
    };
  };
}
