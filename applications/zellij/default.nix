{...}: {
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    exitShellOnExit = true;

    layouts = {
      default = ''
        layout {
          default_tab_template {
              children
              pane size=1 borderless=true {
                  plugin location="zellij:compact-bar"
              }
          }
          tab name="Home Manager" cwd="~/.config/home-manager" {
            pane
          }
          tab name="Goodnotes" cwd="~/projects/github.com/GoodNotes/GoodNotes-5" {
            pane
          }
        }
      '';
    };
  };

  programs.zsh.initContent = ''
    function zr () { zellij run --name "$*" -- zsh -ic "$*";}
    function zrf () { zellij run --name "$*" --floating -- zsh -ic "$*";}
    function zri () { zellij run --name "$*" --in-place -- zsh -ic "$*";}
    function ze () { zellij edit "$*";}
    function zef () { zellij edit --floating "$*";}
    function zei () { zellij edit --in-place "$*";}
    function zpipe () {
      if [ -z "$1" ]; then
        zellij pipe;
      else
        zellij pipe -p $1;
      fi
    }
  '';
}
