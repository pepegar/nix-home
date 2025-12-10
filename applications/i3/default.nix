{pkgs, ...}: let
  modifier = "Mod4";
  ws1 = "1:code";
  ws2 = "2:web";
  ws3 = "3:music";
  ws4 = "4";
  ws5 = "5";
  ws6 = "6";
  ws7 = "7";
  ws8 = "8";
  ws9 = "9";
in {
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = {
      modifier = modifier;
      fonts = ["PragmataPro"];
      gaps = {
        inner = 12;
        outer = 5;
      };
      keybindings = pkgs.lib.mkOptionDefault {
        "${modifier}+Return" = "exec urxvt";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+d" = "exec ${pkgs.bash}/bin/bash ~/.config/i3/rofi-wrapper";

        "${modifier}+j" = "focus left";
        "${modifier}+k" = "focus right";
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";

        "${modifier}+Shift+j" = "move left";
        "${modifier}+Shift+k" = "move right";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Right" = "move right";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";

        "${modifier}+h" = "split h";
        "${modifier}+v" = "split v";
        "${modifier}+f" = "fullscreen toggle";

        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";

        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+space" = "focus mode_toggle";

        "${modifier}+1" = "workspace ${ws1}";
        "${modifier}+2" = "workspace ${ws2}";
        "${modifier}+3" = "workspace ${ws3}";
        "${modifier}+4" = "workspace ${ws4}";
        "${modifier}+5" = "workspace ${ws5}";
        "${modifier}+6" = "workspace ${ws6}";
        "${modifier}+7" = "workspace ${ws7}";
        "${modifier}+8" = "workspace ${ws8}";
        "${modifier}+9" = "workspace ${ws9}";

        "${modifier}+Shift+1" = "move container to workspace ${ws1}";
        "${modifier}+Shift+2" = "move container to workspace ${ws2}";
        "${modifier}+Shift+3" = "move container to workspace ${ws3}";
        "${modifier}+Shift+4" = "move container to workspace ${ws4}";
        "${modifier}+Shift+5" = "move container to workspace ${ws5}";
        "${modifier}+Shift+6" = "move container to workspace ${ws6}";
        "${modifier}+Shift+7" = "move container to workspace ${ws7}";
        "${modifier}+Shift+8" = "move container to workspace ${ws8}";
        "${modifier}+Shift+9" = "move container to workspace ${ws9}";

        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+r" = "restart";
        "${modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";

        "${modifier}+r" = "mode resize";
      };

      bars = [
        {
          fonts = ["PragmataPro"];
          extraConfig = ''
            strip_workspace_numbers yes
          '';
        }
      ];
      assigns = {
        "${ws1}" = [{class = "^Emacs$";} {class = "^URxvt";}];
        "${ws2}" = [{class = "^Firefox$";} {class = "^Slack";}];
        "${ws3}" = [{class = "^Spotify$";}];
      };
    };
  };

  home.file.".config/i3/rofi-wrapper".text = ''
    #!/usr/bin/env bash

    ${pkgs.rofi}/bin/rofi -modi drun,run,ssh,vpn:rofi-vpn,keys,window -show drun -show-icons
  '';
}
