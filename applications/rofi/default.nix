{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    width = 60;
    lines = 10;
    borderWidth = 2;
    padding = 30;
    theme = ".slate";
  };

  home.file.".slate.rasi".text = builtins.readFile (pkgs.fetchFromGitHub {
      owner = "davatorium";
      repo = "rofi-themes";
      rev = "5261d22a0af973d1abd7ac7dcff76a9745afb730";
      sha256 = "03yl6mcb9a3brf14mrryqv4z2ckphji2jnpnzmj0f7cq90x3867h";
    }
    + "/User Themes/slate.rasi");
}
