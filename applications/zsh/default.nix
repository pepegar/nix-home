{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      save = 100000;
      size = 100000;
    };

    defaultKeymap = "emacs";

    initExtra = ''
      export PATH=/Users/pepe/Library/Python/3.7/bin:$PATH
    '';

    shellAliases = {
      cat = "bat";
      du = "ncdu --color dark -rr -x";
      g = "git";
      gst = "git status";
      ls = "exa";
      ll = "ls -a";
      vin = "cd ~/.config/nixpkgs & nvim";
      vix = "cd ~/.config/nixpkgs & nvim applications/xmonad/xmonad.hs";
      ".." = "cd ..";
      ping = "prettyping";
    };

    plugins = [{
      name = "z";
      file = "z.sh";
      src = pkgs.fetchFromGitHub {
        owner = "rupa";
        repo = "z";
        rev = "v1.9";
        sha256 = "1h0yk0sbv9d571sfkg97wi5q06cpxnhnvh745dlpazpgqi1vb1a8";
      };
    }];
  };
}
