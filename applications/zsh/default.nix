{pkgs, ...}: let
  secrets = import ../../secrets.nix;
in {
  programs.zsh = {
    enable = true;

    enableCompletion = true;

    sessionVariables = secrets.claude;

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      save = 100000;
      size = 100000;
    };

    defaultKeymap = "emacs";

    initExtra = ''
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

      vterm_printf(){
          if [ -n "$TMUX" ] && ([ "$\{TERM%%-*\}" = "tmux" ] || [ "$\{TERM%%-*\}" = "screen" ] ); then
              # Tell tmux to pass the escape sequences through
              printf "\ePtmux;\e\e]%s\007\e\\" "$1"
          elif [ "$\{TERM%%-*\}" = "screen" ]; then
              # GNU screen (screen, screen-256color, screen-256color-bce)
              printf "\eP\e]%s\007\e\\" "$1"
          else
              printf "\e]%s\e\\" "$1"
          fi
        }

      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

      bindkey "^[[3~" delete-char
      bindkey "^[3;5~" delete-char
      bindkey "\e[3~" delete-char
      bindkey "^[[3;3~" delete-word
    '';

    shellAliases = {
      cat = "bat -p";
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
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      vf = "fd --type f | fzf --preview 'bat --style=numbers --color=always {}' | xargs -r vi";
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
