{pkgs, ...}: {
  programs.zellij = {
    enable = true;

    settings = {
      support_kitty_keyboard_protocol = false;
      keybinds = {
        unbind = ["Alt Left" "Alt Right"];
      };
    };

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
          tab name="Math" cwd="~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Math" {
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
    function zr () {
      if [ -n "$DIRENV_DIR" ]; then
        zellij run --name "$*" -- direnv exec . zsh -ic "$*";
      else
        zellij run --name "$*" -- zsh -ic "$*";
      fi
    }
    function zrf () {
      if [ -n "$DIRENV_DIR" ]; then
        zellij run --name "$*" --floating -- direnv exec . zsh -ic "$*";
      else
        zellij run --name "$*" --floating -- zsh -ic "$*";
      fi
    }
    function zri () {
      if [ -n "$DIRENV_DIR" ]; then
        zellij run --name "$*" --in-place -- direnv exec . zsh -ic "$*";
      else
        zellij run --name "$*" --in-place -- zsh -ic "$*";
      fi
    }
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

    #if [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then
      #eval "$(${pkgs.zellij}/bin/zellij setup --generate-auto-start zsh)"
    #fi
  '';
}
