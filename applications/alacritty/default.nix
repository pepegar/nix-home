{...}: let
  colorscheme = ./colorschemes.yml;
in {
  programs.alacritty = {
    enable = false;
    settings = {
      bell = {
        animation = "EaseOutExpo";
        duration = 5;
        color = "#ffffff";
      };
      font = {
        normal = {family = "Iosevka";};
        size = 17;
      };
      selection.save_to_clipboard = true;
      # shell.program = "${pkgs.zsh}/bin/zsh";
      window = {
        decorations = "full";
        padding = {
          x = 5;
          y = 5;
        };
      };
      #key_bindings = [
      #{
      #key = "A";
      #mods = "Alt";
      #chars = "\\x1ba";
      #}
      #{
      #key = "B";
      #mods = "Alt";
      #chars = "\\x1bb";
      #}
      #{
      #key = "C";
      #mods = "Alt";
      #chars = "\\x1bc";
      #}
      #{
      #key = "D";
      #mods = "Alt";
      #chars = "\\x1bd";
      #}
      #{
      #key = "E";
      #mods = "Alt";
      #chars = "\\x1be";
      #}
      #{
      #key = "F";
      #mods = "Alt";
      #chars = "\\x1bf";
      #}
      #{
      #key = "G";
      #mods = "Alt";
      #chars = "\\x1bg";
      #}
      #{
      #key = "H";
      #mods = "Alt";
      #chars = "\\x1bh";
      #}
      #{
      #key = "I";
      #mods = "Alt";
      #chars = "\\x1bi";
      #}
      #{
      #key = "J";
      #mods = "Alt";
      #chars = "\\x1bj";
      #}
      #{
      #key = "K";
      #mods = "Alt";
      #chars = "\\x1bk";
      #}
      #{
      #key = "L";
      #mods = "Alt";
      #chars = "\\x1bl";
      #}
      #{
      #key = "M";
      #mods = "Alt";
      #chars = "\\x1bm";
      #}
      #{
      #key = "N";
      #mods = "Alt";
      #chars = "\\x1bn";
      #}
      #{
      #key = "O";
      #mods = "Alt";
      #chars = "\\x1bo";
      #}
      #{
      #key = "P";
      #mods = "Alt";
      #chars = "\\x1bp";
      #}
      #{
      #key = "Q";
      #mods = "Alt";
      #chars = "\\x1bq";
      #}
      #{
      #key = "R";
      #mods = "Alt";
      #chars = "\\x1br";
      #}
      #{
      #key = "S";
      #mods = "Alt";
      #chars = "\\x1bs";
      #}
      #{
      #key = "T";
      #mods = "Alt";
      #chars = "\\x1bt";
      #}
      #{
      #key = "U";
      #mods = "Alt";
      #chars = "\\x1bu";
      #}
      #{
      #key = "V";
      #mods = "Alt";
      #chars = "\\x1bv";
      #}
      #{
      #key = "W";
      #mods = "Alt";
      #chars = "\\x1bw";
      #}
      #{
      #key = "X";
      #mods = "Alt";
      #chars = "\\x1bx";
      #}
      #{
      #key = "Y";
      #mods = "Alt";
      #chars = "\\x1by";
      #}
      #{
      #key = "Z";
      #mods = "Alt";
      #chars = "\\x1bz";
      #}
      #];
      import = ["${colorscheme}"];
    };
  };
}
