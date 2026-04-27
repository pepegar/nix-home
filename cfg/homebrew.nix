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
      "atlassian/homebrew-acli"
      "ossianhempel/tap"
      "johannesnagl/tap"
    ];

    brews = [
      "aarch64-unknown-linux-gnu"
      "acli"
      "ast-grep"
      "ffmpeg"
      "ghostscript"
      "git-lfs"
      "json-c"
      "libevent"
      "libwebsockets"
      "lua-language-server"
      "nodejs"
      "pinentry-mac"
      "r"
      "rtk"
      "silicon"
      "sox"
      "stylua"
      "tailscale"
      "things3-cli"
      "ttyd"
      "vhs"
      "woff2"
      "x86_64-unknown-linux-gnu"
      "xcodegen"
      "xcodes"
    ];

    casks = [
      "1password"
      "1password-cli"
      "chatgpt"
      "cleanshot"
      "creality-print"
      "deskpad"
      "docker-desktop"
      "ghostty"
      "intellij-idea"
      "karabiner-elements"
      "keymapp"
      "mouseless"
      "ngrok"
      "notion"
      "obsidian"
      "orcaslicer"
      "pritunl"
      "quip"
      "raycast"
      "rescuetime"
      "rstudio"
      "session-manager-plugin"
      "slack"
      "spotify"
      "webex"
      "whatsapp"
      "zoom"
      "showmd"
    ];

    # name = id
    # the id can be found with `mas search $appName`
    # or from the URL.  XCode's appstore url is https://apps.apple.com/us/app/xcode/id497799835?mt=12,
    # hence, id 497799835.

    # commenting, since mas is broken for now ... https://github.com/mas-cli/mas/issues/1029
    #masApps = {
    #Flighty = 1358823008;
    #Numbers = 409203825;
    #Pages = 409201541;
    #"Things 3" = 904280696;
    #Xcode = 497799835;
    #};
  };
}
