{ ... }:

{
  homebrew = {
    enable = true;

    global = { brewfile = true; };

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };

    brews = [ "git-lfs" "lua-language-server" "stylua" ];

    casks = [
      "1password"
      "1password-cli"
      "discord"
      "docker"
      "flycut"
      "intellij-idea"
      "iterm2"
      "karabiner-elements"
      "keymapp"
      "notion"
      "ngrok"
      "quip"
      "raycast"
      "rectangle"
      "slack"
      "spotify"
      "tailscale"
      "webex"
      "whatsapp"
      "zoom"
      "steam"
      "loom"
      "anaconda"
      "cold-turkey-blocker"
      "obsidian"
    ];

    # name = id
    # the id can be found with `mas search $appName`
    # or from the URL.  XCode's appstore url is https://apps.apple.com/us/app/xcode/id497799835?mt=12,
    # hence, id 497799835.
    masApps = {
      Fantastical = 975937182;
      Flighty = 1358823008;
      Numbers = 409203825;
      Pages = 409201541;
      "Things 3" = 904280696;
      Xcode = 497799835;
    };
  };
}
