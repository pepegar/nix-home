{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty.overrideAttrs {
      doInstallCheck = false;
    };

    font = {
      name = "PragmataPro Mono Liga";
      size = 18;
    };
  };
}
