{pkgs, ...}: {
  services.yabai = {
    enable = true;
    enableScriptingAddition = false;
    config = {
      layout = "bsp";
      mouse_follows_focus = "on";
      focus_follows_mouse = "off";
      window_shadow = "on";
      window_opacity = "off";
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
    };
    extraConfig = ''
      yabai -m rule --add app="System Settings" manage=off
      yabai -m rule --add app="Finder" manage=off
      yabai -m rule --add app="Activity Monitor" manage=off
      yabai -m rule --add app="Calculator" manage=off
    '';
  };

  launchd.user.agents.jankyborders = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
        "style=round"
        "width=6.0"
        "hidpi=on"
        "active_color=0xff00ff00"
        "inactive_color=0xff555555"
      ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}
