{ pkgs, ... }:

let colorscheme = ./colorschemes.yml;
in {
  programs.alacritty = {
    enable = true;
    settings = {
      bell = {
        animation = "EaseOutExpo";
        duration = 5;
        color = "#ffffff";
      };
      font = {
        normal = { family = "Iosevka Nerd Font"; };
        size = 17;
      };
      selection.save_to_clipboard = true;
      shell.program = "${pkgs.zsh}/bin/zsh";
      window = {
        decorations = "full";
        padding = {
          x = 5;
          y = 5;
        };
      };
      import = [ "${colorscheme}" ];
    };
  };
}
