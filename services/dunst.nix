{pkgs, ...}: {
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome3.adwaita-icon-theme;
      size = "32x32";
    };
    settings = {
      global = {
        font = "PragmataPro, Noto Color Emoji 8";
        markup = "yes";
        plain_text = "no";
        format = ''
          <b>%s</b> %p
          %b'';
        sort = "no";
        indicate_hidden = "yes";
        alignment = "center";
        bounce_freq = 0;
        show_age_threshold = -1;
        word_wrap = "yes";
        ignore_newline = "no";
        geometry = "300x5-15+49";
        transparency = 15;
        idle_threshold = 120;
        monitor = 0;
        follow = "mouse";
        sticky_history = "no";
        history_length = 20;
        show_indicators = "yes";
        line_height = 0;
        separator_height = 2;
        padding = 5;
        horizontal_padding = 5;
        separator_color = "frame";
        startup_notification = true;
        dmenu = "/usr/bin/dmenu -p dunst";
        browser = "/usr/bin/firefox -new-tab";
        icon_position = "left";
        max_icon_size = 48;
        icon_folders = "${pkgs.gnome3.adwaita-icon-theme}/48x48/emblems/:${pkgs.gnome3.adwaita-icon-theme}/48x48/mimetypes/:${pkgs.gnome3.adwaita-icon-theme}/48x48/status/:${pkgs.gnome3.adwaita-icon-theme}/48x48/devices/:${pkgs.gnome3.adwaita-icon-theme}/48x48/apps/";
        frame_width = 3;
        frame_color = "#000000";
      };

      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };

      urgency_low = {
        background = "#5c6370";
        foreground = "#000000";
        timeout = 10;
      };

      urgency_normal = {
        background = "#56b6c2";
        foreground = "#ffffff";
        timeout = 10;
      };

      urgency_critical = {
        background = "#f44747";
        foreground = "#000000";
        timeout = 0;
      };
    };
  };
}
