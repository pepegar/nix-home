{ pkgs, ... }:


let
  xdgUtils = pkgs.xdg_utils.overrideAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
      postInstall = old.postInstall + "\n" + ''
        wrapProgram $out/bin/xdg-open --suffix PATH : /run/current-system/sw/bin
      '';
    }
  );
  openCalendar = "${pkgs.gnome3.gnome-calendar}/bin/gnome-calendar";
  openGithub = "${xdgUtils}/bin/xdg-open https\\://github.com/notifications";

  myPolybar = pkgs.polybar.override {
    alsaSupport   = true;
    githubSupport = true;
    mpdSupport    = true;
    pulseSupport  = true;
  };
in {
  services.polybar = {
    enable = true;
    script = "polybar top &";
    config = {
      "bar/top" = {
        monitor = "HDMI-0";
        width = "100%";
        height = "3%";
        radius = 0;
        enable-ipc = "true";
        tray-position = "right";
        modules-right = "clickable-date";
        modules-left = "xmonad";

        font-0 = "PragmataPRO:style=Medium:size=12;3";
        font-1 = "icomoon-feather:style=Medium:size=14;3";
        font-2 = "PragmataPRO:style=Medium:size=30;3";
        font-3 = "PragmataPRO:style=Medium:size=23;3";
        font-4 = "PragmataPRO:style=Medium:size=7;3";

      };
      "module/date" = {
        type = "internal/date";
        internal = 5;
        date = "%d.%m.%y";
        time = "%H:%M";
        label = "%time%  %date%";
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

    };
    package = myPolybar;
  };
}
