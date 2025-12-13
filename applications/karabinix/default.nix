{inputs, ...}:
with inputs.karabinix.lib; let
  debug = true;

  mkLatex = latex: description:
    mkToEvent {
      shell_command = "printf '%s' '${latex}' | pbcopy && osascript -e 'tell application \"System Events\" to keystroke \"v\" using command down'";
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
            description = "⬆️―";
          };
          # move line down
          s = mkToEvent {
            key_code = keyCodes.down_arrow;
            modifiers = [keyCodes.left_option keyCodes.left_shift];
            description = "⬇️―";
          };
          # all commands
          a = mkToEvent {
            key_code = keyCodes.a;
            modifiers = [keyCodes.left_command keyCodes.left_shift];
            description = "all";
          };
          # go to interface
          u = mkToEvent {
            key_code = keyCodes.u;
            modifiers = [keyCodes.left_command];
            description = "⤴️";
          };
          # go to implementations
          i = mkToEvent {
            key_code = keyCodes.b;
            modifiers = [keyCodes.left_command keyCodes.left_option];
            description = "⤵️";
          };
          h = mkToEvent {
            key_code = keyCodes.left_arrow;
            modifiers = [keyCodes.left_command keyCodes.left_option];
            description = "↩️";
          };
          j = mkToEvent {
            key_code = keyCodes.down_arrow;
            modifiers = [keyCodes.left_option];
          };
          k = mkToEvent {
            key_code = keyCodes.up_arrow;
            modifiers = [keyCodes.left_option];
          };
          l = mkToEvent {
            key_code = keyCodes.right_arrow;
            modifiers = [keyCodes.left_command keyCodes.left_option];
            description = "↪️";
          };
          m = mkToEvent {
            key_code = keyCodes.down_arrow;
            modifiers = [keyCodes.left_control keyCodes.left_shift];
            description = "⬇️method";
          };

          "shift+m" = mkToEvent {
            key_code = keyCodes.up_arrow;
            modifiers = [keyCodes.left_control keyCodes.left_shift];
            description = "⬆️method";
          };

          n = mkToEvent {
            key_code = keyCodes.f2;
            modifiers = [keyCodes.fn];
            description = "⬇️💥";
          };

          "shift+n" = mkToEvent {
            key_code = keyCodes.f2;
            modifiers = [keyCodes.fn keyCodes.left_shift];
            description = "⬆️💥";
          };

          # Debugging shortcuts with mnemonics
          b = mkToEvent {
            # Toggle Breakpoint
            key_code = keyCodes.f8;
            modifiers = [keyCodes.fn keyCodes.left_command];
            description = "🐞🔴";
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
            description = "🐞▶️";
          };
        };
        "org.nixos.firefox" = {
          h = mkToEvent {
            key_code = keyCodes.left_arrow;
            modifiers = [keyCodes.left_command];
            description = "↩️";
          };
          l = mkToEvent {
            key_code = keyCodes.right_arrow;
            modifiers = [keyCodes.left_command];
            description = "↪️";
          };
          i = mkToEvent {
            # dev tools
            key_code = keyCodes.i;
            modifiers = [keyCodes.left_command keyCodes.left_option];
            description = "🔍";
          };
          t = mkToEvent {
            # dev tools
            key_code = keyCodes.f1;
            modifiers = [keyCodes.fn];
          };
        };
        "com.tinyspeck.slackmacgap" = {
          # home
          h = mkToEvent {
            key_code = keyCodes."1";
            modifiers = [keyCodes.left_control];
          };
          # dms
          d = mkToEvent {
            key_code = keyCodes."2";
            modifiers = [keyCodes.left_control];
          };
          # activity
          a = mkToEvent {
            key_code = keyCodes."3";
            modifiers = [keyCodes.left_control];
          };
        };
        "net.whatsapp.WhatsApp" = {
          k = mkToEvent {
            key_code = keyCodes.f;
            modifiers = [keyCodes.left_command];
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
                  o = mkToEvent {
                    shell_command = "open -a 'Obsidian'";
                    description = "Obsidian";
                  };
                  n = mkToEvent {
                    shell_command = "open -a 'Notion'";
                    description = "Notion";
                  };
                  a = mkToEvent {
                    shell_command = "open -a 'ChatGPT'";
                    description = "ChatGPT";
                  };
                  w = mkToEvent {
                    shell_command = "open -a 'WhatsApp'";
                    description = "Whatsapp";
                  };
                  t = mkToEvent {
                    shell_command = "open -a 'Kitty'";
                    description = "Kitty";
                  };
                  b = mkToEvent {
                    shell_command = "open -a 'Chrome'";
                    description = "Chrome";
                  };
                  i = mkToEvent {
                    shell_command = "open -a 'IntelliJ IDEA'";
                    description = "Idea";
                  };
                  s = mkToEvent {
                    shell_command = "open -a 'Slack'";
                    description = "Slack";
                  };
                  c = mkToEvent {
                    shell_command = "open -a 'Calendar'";
                    description = "Calendar";
                  };
                  m = mkToEvent {
                    shell_command = "open -a 'Mail'";
                    description = "Mail";
                  };
                  p = mkToEvent {
                    shell_command = "open -a 'Perplexity'";
                    description = "perplexity";
                  };
                  "1" = mkToEvent {
                    shell_command = "open -a '1Password'";
                    description = "1Password";
                  };
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

              (layerKey {
                enable_debug = debug;
                key = keyCodes.slash;
                variable_name = "latex_layer";
                alone_key = keyCodes.slash;
                mappings = {
                  # Number sets (blackboard bold)
                  n = mkLatex ''\mathbb{N}'' "ℕ";
                  z = mkLatex ''\mathbb{Z}'' "ℤ";
                  q = mkLatex ''\mathbb{Q}'' "ℚ";
                  r = mkLatex ''\mathbb{R}'' "ℝ";
                  c = mkLatex ''\mathbb{C}'' "ℂ";
                  # Greek letters
                  a = mkLatex ''\alpha'' "α";
                  b = mkLatex ''\beta'' "β";
                  g = mkLatex ''\gamma'' "γ";
                  d = mkLatex ''\delta'' "δ";
                  e = mkLatex ''\epsilon'' "ε";
                  l = mkLatex ''\lambda'' "λ";
                  m = mkLatex ''\mu'' "μ";
                  p = mkLatex ''\pi'' "π";
                  s = mkLatex ''\sigma'' "σ";
                  t = mkLatex ''\theta'' "θ";
                  o = mkLatex ''\omega'' "ω";
                  # Common operators/symbols
                  i = mkLatex ''\in'' "∈";
                  f = mkLatex ''\forall'' "∀";
                  x = mkLatex ''\exists'' "∃";
                };
              })

              (layerKey {
                enable_debug = debug;
                key = keyCodes.backslash;
                variable_name = "mouse_layer";
                alone_key = keyCodes.backslash;
                mappings = {
                  a = mkToEvent {
                    description = "⬅️";
                    mouse_key = {
                      x = -1400;
                      speed_multiplier = 1.0;
                    };
                  };
                  s = mkToEvent {
                    description = "⬇️";
                    mouse_key = {
                      y = 1300;
                      speed_multiplier = 1.0;
                    };
                  };
                  w = mkToEvent {
                    description = "⬆️";
                    mouse_key = {
                      y = -1300;
                      speed_multiplier = 1.0;
                    };
                  };
                  d = mkToEvent {
                    description = "➡️";
                    mouse_key = {
                      x = 1300;
                      speed_multiplier = 1.0;
                    };
                  };
                  q = mkToEvent {
                    description = "⬅️🖱️";
                    pointing_button = "button1";
                  };
                  e = mkToEvent {
                    description = "➡️🖱️";
                    pointing_button = "button2";
                  };
                  r = mkToEvent {
                    description = "⬇️⚙️";
                    mouse_key = {
                      vertical_wheel = 32;
                      speed_multiplier = 1.0;
                    };
                  };
                  f = mkToEvent {
                    description = "⬆️⚙️";
                    mouse_key = {
                      vertical_wheel = -32;
                      speed_multiplier = 1.0;
                    };
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
