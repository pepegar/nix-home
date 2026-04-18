{
  pkgs,
  inputs,
  system,
  ...
}: let
  zellij-cmd-k = inputs.zellij-cmd-k.packages.${system}.zellij-cmd-k;
  zellaude = pkgs.fetchurl {
    url = "https://github.com/ishefi/zellaude/releases/download/v0.5.0/zellaude.wasm";
    sha256 = "1d6b4792550a2d0833a6bf2777184ecf9bab416c178b49c317b5e1b0cd842c24";
  };
in {
  home.file.".config/zellij/plugins/zellij-cmd-k.wasm".source = "${zellij-cmd-k}/zellij-cmd-k.wasm";
  home.file.".config/zellij/plugins/zellaude.wasm".source = zellaude;

  programs.zellij = {
    enable = true;

    settings = {
      pane_frames = false;
      support_kitty_keyboard_protocol = true;
      session_serialization = true;
      serialize_pane_viewport = true;
      scrollback_lines_to_serialize = 10000;
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
        unbind = ["Alt Left" "Alt Right" "Ctrl q"];
        shared = {
          "bind \"Ctrl l\"" = {NextSwapLayout = {};};
          "bind \"Ctrl h\"" = {PreviousSwapLayout = {};};
        };
        "shared_except \"locked\"" = {
          "bind \"Super k\"" = {
            "LaunchOrFocusPlugin \"file:~/.config/zellij/plugins/zellij-cmd-k.wasm\"" = {
              floating = true;
            };
          };
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
                  plugin location="file:~/.config/zellij/plugins/zellaude.wasm"
              }
          }

          tab_template name="ui" {
              children
              pane size=1 borderless=true {
                  plugin location="file:~/.config/zellij/plugins/zellaude.wasm"
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
