{...}: {
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh.initContent = ''
    if [[ -x "$(command -v zellij)" ]];
    then
        eval "$(zellij setup --generate-completion zsh | grep "^function")"
    fi;
  '';
}
