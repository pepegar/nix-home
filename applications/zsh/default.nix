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
      export PATH=~/.nix-profile/bin:$PATH
      export PATH=/Users/pepegarcia/Library/Python/3.7/bin:$PATH
      export PATH=/Users/pepegarcia/bin:$PATH
      export PATH=/Users/pepegarcia/go/bin:$PATH
      export PATH=/usr/local/bin:$PATH
      export PATH=/Library/TeX/texbin:$PATH
      export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:$PATH
      export PATH=/opt/homebrew/bin:$PATH
      export PATH=/opt/homebrew/opt/postgresql@12/bin:$PATH

      source ~/.nix-profile/etc/profile.d/nix.sh
      source "$HOME/.sdkman/bin/sdkman-init.sh"
    '';

    shellAliases = {
      cat = "bat";
      du = "ncdu --color dark -rr -x";
      g = "git";
      gc = "git commit";
      gst = "git status";
      ls = "exa";
      ll = "ls -a";
      vin = "cd ~/.config/nixpkgs & nvim";
      vix = "cd ~/.config/nixpkgs & nvim applications/xmonad/xmonad.hs";
      ".." = "cd ..";
      ping = "prettyping";
      bazel = "bazelisk";
      k = "kubectl";
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
