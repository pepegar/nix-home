{ ... }:

{
  homebrew = {
    enable = true;

    global = { brewfile = true; };

    casks = [
      "1password"
      "discord"
      "docker"
      "flycut"
      "intellij-idea"
      "iterm2"
      "notion"
      "quip"
      "raycast"
      "rectangle"
      "slack"
      "spotify"
      "tailscale"
      "webex"
      "zoom"
    ];
  };
}
