{...}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      format = "$directory$git_branch$git_commit$git_state$git_metrics$git_status$\{custom.git_branch_description\}$fill$nix_shell$aws$line_break$jobs$battery$time$status$os$container$shell$character";
      palette = "catppuccin_latte";
      fill = {
        symbol = " ";
        style = "bright-black";
      };
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

      palettes.catppuccin_latte = {
        rosewater = "#dc8a78";
        flamingo = "#dd7878";
        pink = "#ea76cb";
        mauve = "#8839ef";
        red = "#d20f39";
        maroon = "#e64553";
        peach = "#fe640b";
        yellow = "#df8e1d";
        green = "#40a02b";
        teal = "#179299";
        sky = "#04a5e5";
        sapphire = "#209fb5";
        blue = "#1e66f5";
        lavender = "#7287fd";
        text = "#4c4f69";
        subtext1 = "#5c5f77";
        subtext0 = "#6c6f85";
        overlay2 = "#7c7f93";
        overlay1 = "#8c8fa1";
        overlay0 = "#9ca0b0";
        surface2 = "#acb0be";
        surface1 = "#bcc0cc";
        surface0 = "#ccd0da";
        base = "#eff1f5";
        mantle = "#e6e9ef";
        crust = "#dce0e8";
      };

      palettes.catppuccin_frappe = {
        rosewater = "#f2d5cf";
        flamingo = "#eebebe";
        pink = "#f4b8e4";
        mauve = "#ca9ee6";
        red = "#e78284";
        maroon = "#ea999c";
        peach = "#ef9f76";
        yellow = "#e5c890";
        green = "#a6d189";
        teal = "#81c8be";
        sky = "#99d1db";
        sapphire = "#85c1dc";
        blue = "#8caaee";
        lavender = "#babbf1";
        text = "#c6d0f5";
        subtext1 = "#b5bfe2";
        subtext0 = "#a5adce";
        overlay2 = "#949cbb";
        overlay1 = "#838ba7";
        overlay0 = "#737994";
        surface2 = "#626880";
        surface1 = "#51576d";
        surface0 = "#414559";
        base = "#303446";
        mantle = "#292c3c";
        crust = "#232634";
      };

      palettes.catppuccin_macchiato = {
        rosewater = "#f4dbd6";
        flamingo = "#f0c6c6";
        pink = "#f5bde6";
        mauve = "#c6a0f6";
        red = "#ed8796";
        maroon = "#ee99a0";
        peach = "#f5a97f";
        yellow = "#eed49f";
        green = "#a6da95";
        teal = "#8bd5ca";
        sky = "#91d7e3";
        sapphire = "#7dc4e4";
        blue = "#8aadf4";
        lavender = "#b7bdf8";
        text = "#cad3f5";
        subtext1 = "#b8c0e0";
        subtext0 = "#a5adcb";
        overlay2 = "#939ab7";
        overlay1 = "#8087a2";
        overlay0 = "#6e738d";
        surface2 = "#5b6078";
        surface1 = "#494d64";
        surface0 = "#363a4f";
        base = "#24273a";
        mantle = "#1e2030";
        crust = "#181926";
      };

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
    };
  };
}
