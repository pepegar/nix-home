{ ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat -p";
      g = "git";
      gst = "git status";
      ls = "exa";
      ll = "ls -a";
      vin = "cd ~/.config/nixpkgs & nvim";
      vix = "cd ~/.config/nixpkgs & nvim applications/xmonad/xmonad.hs";
      ".." = "cd ..";
      ping = "prettyping";
    };
  };
}
