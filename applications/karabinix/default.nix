{inputs, ...}:
with inputs.karabinix.lib; let
  debug = true;
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
                  a = mkToEvent {
                    description = "🤖";
                    shell_command = "open https://gemini.google.com/app";
                  };
                  w = mkToEvent {
                    description = "💬";
                    shell_command = "open -a 'WhatsApp'";
                  };
                  t = mkToEvent {
                    description = "🖥️";
                    shell_command = "open -a 'Ghostty'";
                  };
                  b = mkToEvent {
                    description = "🌐";
                    shell_command = "open -a 'Firefox'";
                  };
                  i = mkToEvent {
                    description = "☕";
                    shell_command = "open -a 'IntelliJ IDEA'";
                  };
                  s = mkToEvent {
                    description = "🤝";
                    shell_command = "open -a 'Slack'";
                  };
                  c = mkToEvent {
                    description = "📅";
                    shell_command = "open -a 'Calendar'";
                  };
                  m = mkToEvent {
                    description = "✉︎";
                    shell_command = "open -a 'Mail'";
                  };
                  p = mkToEvent {
                    description = "✉︎";
                    shell_command = "open -a 'Perplexity'";
                  };
                  "1" = mkToEvent {
                    description = "🔑";
                    shell_command = "open -a '1Password'";
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
                    modifiers = [keyCodes.left_shift]; # !
                  };
                  w = mkToEvent {
                    key_code = keyCodes."2";
                    modifiers = [keyCodes.left_shift]; # @
                  };
                  e = mkToEvent {
                    key_code = keyCodes.open_bracket;
                    modifiers = [keyCodes.left_shift]; # {
                  };
                  r = mkToEvent {
                    key_code = keyCodes.close_bracket;
                    modifiers = [keyCodes.left_shift]; # }
                  };
                  t = mkToEvent {
                    key_code = keyCodes.backslash;
                    modifiers = [keyCodes.left_shift]; # |
                  };
                  s = mkToEvent {
                    key_code = keyCodes."4";
                    modifiers = [keyCodes.left_shift]; # $
                  };
                  d = mkToEvent {
                    key_code = keyCodes."9";
                    modifiers = [keyCodes.left_shift]; # (
                  };
                  f = mkToEvent {
                    key_code = keyCodes."0";
                    modifiers = [keyCodes.left_shift]; # )
                  };
                  g = mkToEvent {
                    key_code = keyCodes.grave_accent_and_tilde;
                  };
                  c = mkToEvent {
                    key_code = keyCodes.open_bracket;
                  };
                  v = mkToEvent {
                    key_code = keyCodes.close_bracket;
                  };
                  b = mkToEvent {
                    key_code = keyCodes.grave_accent_and_tilde;
                    modifiers = [keyCodes.left_shift]; # ?
                  };
                };
              })

              (appLayerKey {
                enable_debug = debug;
                key = keyCodes.backslash;
                variable_name = "per_app_layer";
                alone_key = keyCodes.backslash;
                app_mappings = {
                  "com.jetbrains.intellij" = {
                    h = mkToEvent {
                      key_code = keyCodes.left_arrow;
                      modifiers = [keyCodes.left_command keyCodes.left_option];
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
                    };
                    m = mkToEvent {
                      key_code = keyCodes.down_arrow;
                      modifiers = [keyCodes.left_control keyCodes.left_shift];
                    };

                    "shift+m" = mkToEvent {
                      key_code = keyCodes.up_arrow;
                      modifiers = [keyCodes.left_control keyCodes.left_shift];
                    };

                    n = mkToEvent {
                      key_code = keyCodes.f2;
                      modifiers = [keyCodes.fn];
                    };

                    "shift+n" = mkToEvent {
                      key_code = keyCodes.f2;
                      modifiers = [keyCodes.fn keyCodes.left_shift];
                    };

                    # Debugging shortcuts with mnemonics
                    b = mkToEvent {
                      # Toggle Breakpoint
                      key_code = keyCodes.f8;
                      modifiers = [keyCodes.fn keyCodes.left_command];
                    };

                    e = mkToEvent {
                      # file structure
                      key_code = keyCodes.f12;
                      modifiers = [keyCodes.fn keyCodes.left_command];
                    };
                  };
                  "org.nixos.firefox" = {
                    h = mkToEvent {
                      key_code = keyCodes.left_arrow;
                      modifiers = [keyCodes.left_command];
                    };
                    l = mkToEvent {
                      key_code = keyCodes.right_arrow;
                      modifiers = [keyCodes.left_command];
                    };
                    i = mkToEvent {
                      # dev tools
                      key_code = keyCodes.i;
                      modifiers = [keyCodes.left_command keyCodes.left_option];
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
