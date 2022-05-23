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
      export PATH=/usr/local/bin:$PATH
      export PATH=/Library/TeX/texbin:$PATH

      source ~/.nix-profile/etc/profile.d/nix.sh
      source "$HOME/.sdkman/bin/sdkman-init.sh"

      # Wasienv
      export WASIENV_DIR="/Users/pepegarcia/.wasienv"
      [ -s "$WASIENV_DIR/wasienv.sh" ] && source "$WASIENV_DIR/wasienv.sh"

      # Wasmer
      export WASMER_DIR="/Users/pepegarcia/.wasmer"
      [ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"
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
