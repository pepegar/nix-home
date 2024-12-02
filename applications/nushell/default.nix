{...}: {
  programs.nushell = {
    enable = true;

    shellAliases = {
      cat = "bat -p";
      g = "git";
      gc = "git commit";
      gst = "git status";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      ping = "prettyping";
      k = "kubectl";
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      vf = "fd --type f | fzf --preview 'bat --style=numbers --color=always {}' | xargs -r vi";
    };

    extraEnv = ''
      use std "path add"

      path add ~/.nix-profile/bin
      path add /pepe/Library/Python/3.7/bin
      path add /Users/pepe/bin
      path add /Users/pepe/go/bin
      path add /usr/local/bin
      path add /Library/TeX/texbin
      path add /opt/homebrew/bin
      path add /Users/pepegarcia/.local/share/gem/ruby/2.7.0/bin
      path add ~/.ghcup/bin
      path add ~/.cargo/bin

      $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
      mkdir ~/.cache/carapace
      carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
    '';

    extraConfig = ''
      source ~/.cache/carapace/init.nu
    '';
  };
}
