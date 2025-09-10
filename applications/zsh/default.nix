{pkgs, ...}: {
  programs.zsh = {
    enable = true;

    enableCompletion = true;

    autosuggestion = {
      enable = true;
    };

    syntaxHighlighting = {
      enable = true;
    };

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      save = 100000;
      size = 100000;
    };

    defaultKeymap = "emacs";

    initContent = ''
      # Added by LM Studio CLI tool (lms)
      export PATH="$PATH:/Users/pepe/.cache/lm-studio/bin"
      export PATH=~/.nix-profile/bin:$PATH
      export PATH=/Users/pepe/Library/Python/3.7/bin:$PATH
      export PATH=/Users/pepe/bin:$PATH
      export PATH=/Users/pepe/go/bin:$PATH
      export PATH=/usr/local/bin:$PATH
      export PATH=/Library/TeX/texbin:$PATH
      export PATH=/opt/homebrew/bin:$PATH
      export PATH=/Users/pepegarcia/.local/share/gem/ruby/2.7.0/bin:$PATH
      export PATH=~/.ghcup/bin:$PATH
      export PATH=~/.cargo/bin:$PATH
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

      bindkey "^[[3~" delete-char
      bindkey "^[3;5~" delete-char
      bindkey "\e[3~" delete-char
      bindkey "^[[3;3~" delete-word
    '';

    shellAliases = {
      cat = "bat --theme auto:system --theme-dark default --theme-light GitHub -p";
      g = "git";
      gc = "git commit";
      gst = "git status";
      ls = "exa";
      ll = "ls -a";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      ping = "prettyping";
      k = "kubectl";
      vf = "fd --type f | fzf --preview 'bat --style=numbers --color=always {}' | xargs -r vi";
      gwt = "cd $(git-wt)";
    };

    plugins = [
      {
        name = "z";
        file = "z.sh";
        src = pkgs.fetchFromGitHub {
          owner = "rupa";
          repo = "z";
          rev = "v1.9";
          sha256 = "1h0yk0sbv9d571sfkg97wi5q06cpxnhnvh745dlpazpgqi1vb1a8";
        };
      }
    ];
  };
}
