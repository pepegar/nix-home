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
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval "$(acli completion zsh)"

      # Added by LM Studio CLI tool (lms)
      export PATH=$HOME/.cache/lm-studio/bin:$PATH
      export PATH=$HOME/.nix-profile/bin:$PATH
      export PATH=$HOME/Library/Python/3.7/bin:$PATH
      export PATH=$HOME/bin:$PATH
      export PATH=$HOME/go/bin:$PATH
      export PATH=/usr/local/bin:$PATH
      export PATH=/Library/TeX/texbin:$PATH
      export PATH=$HOME/.local/share/gem/ruby/2.7.0/bin:$PATH
      export PATH=$HOME/.local/bin:$PATH
      export PATH=$HOME/.ghcup/bin:$PATH
      export PATH=$HOME/.cargo/bin:$PATH
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
      gwt = "wt=$(git-wt) && zellij action new-tab --name $(basename $wt) --cwd $wt";
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
