{inputs, ...}:
with inputs.karabinix.lib; let
  debug = true;

  # Toggle app: if frontmost, hide it; otherwise activate it
  # processName is the name as shown in "System Events" (usually same as app name)
  mkToggleApp = appName: processName:
    mkToEvent {
      shell_command = ''osascript -e 'tell application "System Events" to set frontApp to name of first application process whose frontmost is true' -e 'if frontApp is "${processName}" then' -e 'tell application "System Events" to set visible of process "${processName}" to false' -e 'else' -e 'tell application "${appName}" to activate' -e 'end if' '';
      description = appName;
    };

  mkLatex = latex: description:
    mkToEvent {
      shell_command = "printf '%s' '${latex}' | pbcopy && osascript -e 'tell application \"System Events\" to keystroke \"v\" using command down'";
      inherit description;
    };

  # Creates \begin{env}\end{env} and moves cursor between them
  # arrows = number of left arrow presses to position cursor (length of "\end{env}" + 1)
  mkLatexEnv = env: description: let
    endTag = "\\end{${env}}";
    arrows = builtins.stringLength endTag;
    arrowPresses = builtins.concatStringsSep " & " (builtins.genList (_: "key code 123") arrows);
  in
    mkToEvent {
      shell_command = "printf '%s' '\\begin{${env}}\\end{${env}}' | pbcopy && osascript -e 'tell application \"System Events\" to keystroke \"v\" using command down' -e 'delay 0.05' -e 'tell application \"System Events\" to ${arrowPresses}'";
      inherit description;
    };

  mkAppLayer = key: variable_name:
    appLayerKey {
      enable_debug = debug;
      key = key;
      variable_name = variable_name;
      alone_key = key;
      app_mappings = {
        "com.jetbrains.intellij" = {
          # move line up
          w = mkToEvent {
            key_code = keyCodes.up_arrow;
            modifiers = [keyCodes.left_option keyCodes.left_shift];
            description = "move line up";
          };
          # move line down
          s = mkToEvent {
            key_code = keyCodes.down_arrow;
            modifiers = [keyCodes.left_option keyCodes.left_shift];
            description = "move line down";
          };
          # all commands
          a = mkToEvent {
            key_code = keyCodes.a;
            modifiers = [keyCodes.left_command keyCodes.left_shift];
            description = "all commands";
          };
          # go to interface
          u = mkToEvent {
            key_code = keyCodes.u;
            modifiers = [keyCodes.left_command];
            description = "go to interface";
          };
          # go to implementations
          i = mkToEvent {
            key_code = keyCodes.b;
            modifiers = [keyCodes.left_command keyCodes.left_option];
            description = "go to impl";
          };
          h = mkToEvent {
            key_code = keyCodes.left_arrow;
            modifiers = [keyCodes.left_command keyCodes.left_option];
            description = "navigate back";
          };
          j = mkToEvent {
            key_code = keyCodes.down_arrow;
            modifiers = [keyCodes.left_option];
            description = "next occurrence";
          };
          k = mkToEvent {
            key_code = keyCodes.up_arrow;
            modifiers = [keyCodes.left_option];
            description = "prev occurrence";
          };
          l = mkToEvent {
            key_code = keyCodes.right_arrow;
            modifiers = [keyCodes.left_command keyCodes.left_option];
            description = "navigate forward";
          };
          m = mkToEvent {
            key_code = keyCodes.down_arrow;
            modifiers = [keyCodes.left_control keyCodes.left_shift];
            description = "next method";
          };

          "shift+m" = mkToEvent {
            key_code = keyCodes.up_arrow;
            modifiers = [keyCodes.left_control keyCodes.left_shift];
            description = "prev method";
          };

          g = mkToEvent {
            key_code = keyCodes.down_arrow;
            modifiers = [keyCodes.left_control keyCodes.left_option keyCodes.left_shift];
            description = "next git change";
          };

          "shift+g" = mkToEvent {
            key_code = keyCodes.up_arrow;
            modifiers = [keyCodes.left_control keyCodes.left_option keyCodes.left_shift];
            description = "prev git change";
          };

          n = mkToEvent {
            key_code = keyCodes.f2;
            modifiers = [keyCodes.fn];
            description = "next error";
          };

          "shift+n" = mkToEvent {
            key_code = keyCodes.f2;
            modifiers = [keyCodes.fn keyCodes.left_shift];
            description = "prev error";
          };

          # Debugging shortcuts with mnemonics
          b = mkToEvent {
            # Toggle Breakpoint
            key_code = keyCodes.f8;
            modifiers = [keyCodes.fn keyCodes.left_command];
            description = "toggle breakpoint";
          };
          e = mkToEvent {
            # file structure
            key_code = keyCodes.f12;
            modifiers = [keyCodes.fn keyCodes.left_command];
            description = "file structure";
          };
          p = mkToEvent {
            key_code = keyCodes.r;
            modifiers = [keyCodes.left_command keyCodes.left_option];
            description = "debug run";
          };
        };
        "org.nixos.firefox" = {
          h = mkToEvent {
            key_code = keyCodes.left_arrow;
            modifiers = [keyCodes.left_command];
            description = "navigate back";
          };
          l = mkToEvent {
            key_code = keyCodes.right_arrow;
            modifiers = [keyCodes.left_command];
            description = "navigate forward";
          };
          i = mkToEvent {
            # dev tools
            key_code = keyCodes.i;
            modifiers = [keyCodes.left_command keyCodes.left_option];
            description = "dev tools";
          };
          t = mkToEvent {
            key_code = keyCodes.f1;
            modifiers = [keyCodes.fn];
            description = "sidebar";
          };
        };
        "com.tinyspeck.slackmacgap" = {
          h = mkToEvent {
            key_code = keyCodes."1";
            modifiers = [keyCodes.left_control];
            description = "home";
          };
          d = mkToEvent {
            key_code = keyCodes."2";
            modifiers = [keyCodes.left_control];
            description = "dms";
          };
          a = mkToEvent {
            key_code = keyCodes."3";
            modifiers = [keyCodes.left_control];
            description = "activity";
          };
        };
        "net.whatsapp.WhatsApp" = {
          k = mkToEvent {
            key_code = keyCodes.f;
            modifiers = [keyCodes.left_command];
            description = "search";
          };
        };
        "com.google.Chrome" = {
          h = mkToEvent {
            key_code = keyCodes.open_bracket;
            modifiers = [keyCodes.left_command];
            description = "navigate back";
          };
          l = mkToEvent {
            key_code = keyCodes.close_bracket;
            modifiers = [keyCodes.left_command];
            description = "navigate forward";
          };
        };
      };
    };
in {
  services.karabinix = {
    enable = true;
    configuration = {
      profiles = [
        (mkProfile {
          name = "created with karabinix";
          selected = true;

          complex_modifications = mkComplexModification {
            parameters = {
              "basic.simultaneous_threshold_milliseconds" = 50;
              "basic.to_delayed_action_delay_milliseconds" = 500;
              "basic.to_if_alone_timeout_milliseconds" = 120;
              "basic.to_if_held_down_threshold_milliseconds" = 100;
              "mouse_motion_to_scroll.speed" = 100;
            };
            rules = [
              (vimNavigation {
                enable_debug = debug;
                layer_key = keyCodes.tab;
              })

              (layerKey {
                enable_debug = debug;
                key = keyCodes.caps_lock;
                alone_key = keyCodes.escape;
                variable_name = "apps_layer";
                mappings = {
                  o = mkToggleApp "Obsidian" "Obsidian";
                  n = mkToggleApp "Notion" "Notion";
                  a = mkToggleApp "Claude" "Claude";
                  w = mkToggleApp "WhatsApp" "WhatsApp";
                  t = mkToggleApp "Ghostty" "Ghostty";
                  b = mkToggleApp "Google Chrome" "Google Chrome";
                  i = mkToggleApp "IntelliJ IDEA" "IntelliJ IDEA";
                  s = mkToggleApp "Slack" "Slack";
                  c = mkToggleApp "Calendar" "Calendar";
                  m = mkToggleApp "Mail" "Mail";
                  p = mkToggleApp "Perplexity" "Perplexity";
                  "1" = mkToggleApp "1Password" "1Password";
                };
              })

              (layerKey {
                enable_debug = debug;
                key = keyCodes.quote;
                alone_key = keyCodes.quote;
                variable_name = "window_management";
                mappings = {
                  f = raycastWindow "maximize";
                  h = raycastWindow "left-half";
                  l = raycastWindow "right-half";
                  k = raycastWindow "top-half";
                  j = raycastWindow "bottom-half";
                  y = raycastWindow "previous-display";
                  p = raycastWindow "next-display";
                };
              })

              (layerKey {
                enable_debug = debug;
                key = keyCodes.semicolon;
                variable_name = "symbols_layer";
                alone_key = keyCodes.semicolon; # Still types semicolon when pressed alone
                mappings = {
                  q = mkToEvent {
                    key_code = keyCodes."1";
                    modifiers = [keyCodes.left_shift];
                    description = "!";
                  };
                  w = mkToEvent {
                    key_code = keyCodes."2";
                    modifiers = [keyCodes.left_shift]; # @
                    description = "@";
                  };
                  e = mkToEvent {
                    key_code = keyCodes.open_bracket;
                    modifiers = [keyCodes.left_shift]; # {
                    description = "{";
                  };
                  r = mkToEvent {
                    key_code = keyCodes.close_bracket;
                    modifiers = [keyCodes.left_shift]; # }
                    description = "}";
                  };
                  t = mkToEvent {
                    key_code = keyCodes.backslash;
                    modifiers = [keyCodes.left_shift]; # |
                    description = "|";
                  };
                  s = mkToEvent {
                    key_code = keyCodes."4";
                    modifiers = [keyCodes.left_shift]; # $
                    description = "$";
                  };
                  d = mkToEvent {
                    key_code = keyCodes."9";
                    modifiers = [keyCodes.left_shift]; # (
                    description = "(";
                  };
                  f = mkToEvent {
                    key_code = keyCodes."0";
                    modifiers = [keyCodes.left_shift]; # )
                    description = ")";
                  };
                  g = mkToEvent {
                    key_code = keyCodes.grave_accent_and_tilde;
                    description = "`";
                  };
                  c = mkToEvent {
                    key_code = keyCodes.open_bracket;
                    description = "[";
                  };
                  v = mkToEvent {
                    key_code = keyCodes.close_bracket;
                    description = "]";
                  };
                  b = mkToEvent {
                    key_code = keyCodes.grave_accent_and_tilde;
                    modifiers = [keyCodes.left_shift]; # ?
                    description = "~";
                  };
                };
              })

              (mkAppLayer keyCodes.hyphen "per_app_layer")
              (mkAppLayer keyCodes.equal_sign "per_app_layer")

              (sublayerKey {
                enable_debug = debug;
                key = keyCodes.slash;
                alone_key = keyCodes.slash;
                variable_name = "latex";

                mappings = {
                  "n" = mkLatex ''\mathbb{N}'' "ℕ";
                  "z" = mkLatex ''\mathbb{Z}'' "ℤ";
                  "q" = mkLatex ''\mathbb{Q}'' "ℚ";
                  "r" = mkLatex ''\mathbb{R}'' "ℝ";
                  "c" = mkLatex ''\mathbb{C}'' "ℂ";
                  "i" = mkLatex ''\in'' "∈";
                  "f" = mkLatex ''\forall'' "∀";
                  "x" = mkLatex ''\exists'' "∃";
                  "a" = mkLatex ''\land'' "∧";
                  "o" = mkLatex ''\lor'' "∨";
                  "e" = mkLatex ''\equiv'' "≡";
                };
                sublayers = {
                  "g" = {
                    "a" = mkLatex ''\alpha'' "α";
                    "b" = mkLatex ''\beta'' "β";
                    "g" = mkLatex ''\gamma'' "γ";
                    "d" = mkLatex ''\delta'' "δ";
                    "e" = mkLatex ''\epsilon'' "ε";
                    "l" = mkLatex ''\lambda'' "λ";
                    "m" = mkLatex ''\mu'' "μ";
                    "p" = mkLatex ''\pi'' "π";
                    "s" = mkLatex ''\sigma'' "σ";
                    "t" = mkLatex ''\theta'' "θ";
                    "o" = mkLatex ''\omega'' "ω";
                  };
                  "b" = {
                    # Matrices
                    "m" = mkLatexEnv "matrix" "matrix";
                    "p" = mkLatexEnv "pmatrix" "(matrix)";
                    "b" = mkLatexEnv "bmatrix" "[matrix]";
                    "v" = mkLatexEnv "vmatrix" "|matrix|";
                    "shift+v" = mkLatexEnv "Vmatrix" "‖matrix‖";
                    # Equations & alignment
                    "a" = mkLatexEnv "align" "align";
                    "e" = mkLatexEnv "equation" "equation";
                    "c" = mkLatexEnv "cases" "cases";
                    # Theorems & proofs (analysis)
                    "t" = mkLatexEnv "theorem" "theorem";
                    "d" = mkLatexEnv "definition" "definition";
                    "l" = mkLatexEnv "lemma" "lemma";
                    "r" = mkLatexEnv "proof" "proof";
                    "shift+p" = mkLatexEnv "proposition" "proposition";
                    "shift+c" = mkLatexEnv "corollary" "corollary";
                  };
                };
              })

              (layerKey {
                enable_debug = debug;
                key = keyCodes.backslash;
                variable_name = "mouse_layer";
                alone_key = keyCodes.backslash;
                mappings = {
                  a = mkToEvent {
                    description = "mouse left";
                    mouse_key = {
                      x = -1400;
                      speed_multiplier = 1.0;
                    };
                  };
                  s = mkToEvent {
                    description = "mouse down";
                    mouse_key = {
                      y = 1300;
                      speed_multiplier = 1.0;
                    };
                  };
                  w = mkToEvent {
                    description = "mouse up";
                    mouse_key = {
                      y = -1300;
                      speed_multiplier = 1.0;
                    };
                  };
                  d = mkToEvent {
                    description = "mouse right";
                    mouse_key = {
                      x = 1300;
                      speed_multiplier = 1.0;
                    };
                  };
                  q = mkToEvent {
                    description = "left click";
                    pointing_button = "button1";
                  };
                  e = mkToEvent {
                    description = "right click";
                    pointing_button = "button2";
                  };
                  r = mkToEvent {
                    description = "scroll down";
                    mouse_key = {
                      vertical_wheel = -32;
                      speed_multiplier = 1.0;
                    };
                  };
                  f = mkToEvent {
                    description = "scroll up";
                    mouse_key = {
                      vertical_wheel = 32;
                      speed_multiplier = 1.0;
                    };
                  };
                  c = mkToEvent {
                    description = "center mouse";
                    shell_command = "~/bin/mouse-center.sh";
                  };
                };
              })

              (homeRowModsWithCombinations {
                s = keyCodes.left_option; # S = Option when held, S when tapped
                d = keyCodes.left_control; # D = Control when held, D when tapped
                f = keyCodes.left_command; # F = Command when held, F when tapped
                j = keyCodes.right_command; # J = Command when held, J when tapped
                k = keyCodes.right_control; # K = Control when held, K when tapped
                l = keyCodes.right_option; # L = Option when held, L when tapped
              })
            ];
          };

          virtual_hid_keyboard = {
            country_code = 0;
            keyboard_type_v2 = "ansi";
          };
        })
      ];
    };
  };
}
