{pkgs, ...}: {
  programs.zellij = {
    enable = true;

    settings = {
      env = {
        TMUX = "1";
      };
      support_kitty_keyboard_protocol = false;
      theme = "custom";
      themes.custom = {
        fg = [171 178 191]; # light gray text
        bg = [40 44 52]; # dark background
        black = [40 44 52];
        red = [224 108 117];
        green = [152 195 121];
        yellow = [229 192 123];
        blue = [97 175 239];
        magenta = [198 120 221];
        cyan = [86 182 194];
        white = [171 178 191];
        orange = [209 154 102];
      };
      keybinds = {
        unbind = ["Alt Left" "Alt Right"];
        shared = {
          "bind \"Ctrl l\"" = {NextSwapLayout = {};};
          "bind \"Ctrl h\"" = {PreviousSwapLayout = {};};
        };
        normal = {
          unbind = ["Ctrl g"];
          "bind \"Ctrl b\"" = {SwitchToMode = "Locked";};
        };
        locked = {
          unbind = ["Ctrl g"];
          "bind \"Ctrl b\"" = {SwitchToMode = "Normal";};
        };
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

          tab_template name="ui" {
              children
              pane size=1 borderless=true {
                  plugin location="zellij:compact-bar"
              }
          }

          swap_tiled_layout name="vertical" {
              ui max_panes=5 {
                  pane split_direction="vertical" {
                      pane
                      pane { children; }
                  }
              }
              ui max_panes=8 {
                  pane split_direction="vertical" {
                      pane { children; }
                      pane { pane; pane; pane; pane; }
                  }
              }
              ui max_panes=12 {
                  pane split_direction="vertical" {
                      pane { children; }
                      pane { pane; pane; pane; pane; }
                      pane { pane; pane; pane; pane; }
                  }
              }
          }

          swap_tiled_layout name="horizontal" {
              ui max_panes=4 {
                  pane split_direction="horizontal" {
                      pane
                      pane { children; }
                  }
              }
              ui max_panes=8 {
                  pane split_direction="horizontal" {
                      pane { children; }
                      pane { pane; pane; pane; pane; }
                  }
              }
              ui max_panes=12 {
                  pane split_direction="horizontal" {
                      pane { children; }
                      pane { pane; pane; pane; pane; }
                      pane { pane; pane; pane; pane; }
                  }
              }
          }

          swap_tiled_layout name="stacked" {
              ui min_panes=2 {
                  pane stacked=true { children; }
              }
          }

          swap_tiled_layout name="grid" {
              ui exact_panes=2 {
                  pane split_direction="vertical" {
                      pane
                      pane
                  }
              }
              ui exact_panes=3 {
                  pane split_direction="vertical" {
                      pane split_direction="horizontal" {
                          pane
                          pane
                      }
                      pane
                  }
              }
              ui exact_panes=4 {
                  pane split_direction="vertical" {
                      pane split_direction="horizontal" {
                          pane
                          pane
                      }
                      pane split_direction="horizontal" {
                          pane
                          pane
                      }
                  }
              }
              ui min_panes=5 {
                  pane split_direction="vertical" {
                      pane split_direction="horizontal" {
                          pane
                          pane
                          pane { children; }
                      }
                      pane split_direction="horizontal" {
                          pane
                          pane
                          pane
                      }
                  }
              }
          }

          swap_tiled_layout name="main-vertical" {
              ui exact_panes=2 {
                  pane split_direction="vertical" {
                      pane size="60%"
                      pane size="40%"
                  }
              }
              ui exact_panes=3 {
                  pane split_direction="vertical" {
                      pane size="60%"
                      pane size="40%" split_direction="horizontal" {
                          pane
                          pane
                      }
                  }
              }
              ui exact_panes=4 {
                  pane split_direction="vertical" {
                      pane size="60%"
                      pane size="40%" split_direction="horizontal" {
                          pane
                          pane
                          pane
                      }
                  }
              }
              ui min_panes=5 {
                  pane split_direction="vertical" {
                      pane size="60%"
                      pane size="40%" split_direction="horizontal" {
                          pane
                          pane
                          pane { children; }
                      }
                  }
              }
          }

          swap_floating_layout name="staggered" {
              floating_panes max_panes=1 {
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
              }
              floating_panes max_panes=2 {
                  pane { x "5%"; y "5%"; width "45%"; height "90%"; }
                  pane { x "50%"; y "5%"; width "45%"; height "90%"; }
              }
              floating_panes max_panes=3 {
                  pane { x "2%"; y "2%"; width "45%"; height "45%"; }
                  pane { x "53%"; y "2%"; width "45%"; height "45%"; }
                  pane { x "27%"; y "52%"; width "45%"; height "45%"; }
              }
          }

          swap_floating_layout name="enlarged" {
              floating_panes max_panes=10 {
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
                  pane { x "5%"; y "5%"; width "90%"; height "90%"; }
              }
          }

          swap_floating_layout name="spread" {
              floating_panes max_panes=1 {
                  pane { x "10%"; y "10%"; width "80%"; height "80%"; }
              }
              floating_panes max_panes=2 {
                  pane { x "2%"; y "10%"; width "45%"; height "80%"; }
                  pane { x "53%"; y "10%"; width "45%"; height "80%"; }
              }
              floating_panes max_panes=3 {
                  pane { x "2%"; y "2%"; width "30%"; height "90%"; }
                  pane { x "35%"; y "2%"; width "30%"; height "90%"; }
                  pane { x "68%"; y "2%"; width "30%"; height "90%"; }
              }
          }

          tab name="Home Manager" cwd="~/.config/home-manager" {
            pane
          }
          tab name="Math (vault)" cwd="~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Math" {
            pane
          }
          tab name="Goodnotes (vault)" cwd="~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Goodnotes" {
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
