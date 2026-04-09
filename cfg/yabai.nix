{...}: {
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      layout = "float";
      mouse_follows_focus = "on";
      focus_follows_mouse = "off";
      window_shadow = "on";
      window_opacity = "off";
    };
    extraConfig = ''
      yabai -m rule --add app="System Settings" manage=off
      yabai -m rule --add app="Finder" manage=off
      yabai -m rule --add app="Activity Monitor" manage=off
      yabai -m rule --add app="Calculator" manage=off
    '';
  };
}
