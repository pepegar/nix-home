{...}: {
  homebrew = {
    enable = true;

    global = {brewfile = true;};

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };

    taps = [
      "messense/macos-cross-toolchains"
    ];

    brews = [
      "git-lfs"
      "lua-language-server"
      "stylua"
      "x86_64-unknown-linux-gnu"
      "aarch64-unknown-linux-gnu"
    ];

    casks = [
      "1password"
      "1password-cli"
      "anaconda"
      "deskpad"
      "discord"
      "docker"
      "ghostty"
      "karabiner-elements"
      "keymapp"
      "ngrok"
      "notion"
      "obsidian"
      "quip"
      "raycast"
      "slack"
      "spotify"
      "tailscale"
      "webex"
      "whatsapp"
    ];

    # name = id
    # the id can be found with `mas search $appName`
    # or from the URL.  XCode's appstore url is https://apps.apple.com/us/app/xcode/id497799835?mt=12,
    # hence, id 497799835.
    masApps = {
      Flighty = 1358823008;
      Numbers = 409203825;
      Pages = 409201541;
      "Things 3" = 904280696;
      Xcode = 497799835;
    };
  };
}
