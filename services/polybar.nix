{
  pkgs,
  config,
  ...
}: let
  xdgUtils = pkgs.xdg_utils.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs or [] ++ [pkgs.makeWrapper];
    postInstall =
      old.postInstall
      + "\n"
      + ''
        wrapProgram $out/bin/xdg-open --suffix PATH : /run/current-system/sw/bin
      '';
  });
  openCalendar = "${pkgs.gnome.gnome-calendar}/bin/gnome-calendar";
  openGithub = "${xdgUtils}/bin/xdg-open https\\://github.com/notifications";
  mprisScript = pkgs.callPackage ../scripts/mpris.nix {};
  myPolybar = pkgs.polybar.override {
    alsaSupport = true;
    githubSupport = true;
    mpdSupport = true;
    pulseSupport = true;
  };
  myConfig = {
    "global/wm" = {
      margin-top = 0;
      margin-bottom = 0;
    };

    "layout" = {
      module-padding = 1;
      icon-font = 2;
      bar-format = "%{T4}%fill%%indicator%%empty%%{F-}%{T-}";
      bar-fill-icon = "ﭳ";
      spacing = 0;
      dim-value = "1.0";
      tray-detached = false;
      tray-maxsize = 10;
      tray-offset-x = 0;
      tray-offset-y = 0;
      tray-padding = 0;
      tray-scale = "1.0";
    };

    "settings" = {screenchange-reload = true;};

    "bar/main" = {
      enable-ipc = "true";
      background = "''\${color.bg}";
      foreground = "#FFFFFF";
      font-0 = "JetBrainsMono Nerd Font:style=Medium:size=12;3";
      font-1 = "icomoon-feather:style=Medium:size=18;3";
      font-2 = "JetBrainsMono Nerd Font:style=Medium:size=30;3";
      font-3 = "JetBrainsMono Nerd Font:style=Medium:size=23;3";
      font-4 = "JetBrainsMono Nerd Font:style=Medium:size=7;3";
      height = "3%";
      monitor = "HDMI-0";
      radius = 0;
      width = "100%";
    };

    "bar/top" = {
      "inherit" = "bar/main";
      modules-left = "right-end-top xmonad left-end-bottom right-end-top left-end-top";
      modules-right = "left-end-top keyboard clickable-github clickable-date battery";
      tray-position = "center";
    };

    "bar/bottom" = {
      "inherit" = "bar/main";
      bottom = true;
      modules-left = "right-end-bottom mpris left-end-top cpu memory filesystem";
      modules-right = "left-end-bottom temperature wired-network pulseaudio left-end-bottom powermenu";
      tray-position = "none";
    };

    "module/xmonad" = {
      type = "custom/script";
      exec = "${pkgs.xmonad-log}/bin/xmonad-log";
      tail = "true";
    };

    "module/clickable-date" = {
      "inherit" = "module/date";
      "label" = "%{A1:${openCalendar}:}%time%%{A}";
    };

    "module/mpris" = {
      "type" = "custom/script";
      "exec" = "${mprisScript}/bin/mpris";
      "tail" = "true";
      "label-maxlen" = "60";
      "interval" = "2";
      "format" = "  <label>";
      "format-padding" = "2";
    };

    "module/clickable-github" = {
      "inherit " = "module/github";
      "token " = "''\${file:${config.xdg.configHome}/polybar/github-notifications-token}";
      "label " = "%{A1:${openGithub}:}  %notifications%%{A}";
    };
  };
  bars = builtins.readFile ./polybar/bars.ini;
  colors = builtins.readFile ./polybar/colors.ini;
  mods1 = builtins.readFile ./polybar/modules.ini;
  mods2 = builtins.readFile ./polybar/user-modules.ini;
in {
  services.polybar = {
    enable = true;
    script = ''
      export ETH_INTERFACE=enp5s0
      polybar top &
      polybar bottom &
    '';
    config = myConfig;
    extraConfig = bars + colors + mods1 + mods2;
    package = myPolybar;
  };
}
