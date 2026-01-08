{...}: {
  programs.chromium = {
    enable = false;
    #package = pkgs.google-chrome;
  };
}
