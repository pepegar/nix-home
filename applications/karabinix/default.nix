{inputs, ...}:
with inputs.karabinix.lib; {
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
              "basic.to_if_held_down_threshold_milliseconds" = 200;
              "mouse_motion_to_scroll.speed" = 100;
            };
            rules = [
              (sublayerKey {
                key = keyCodes.caps_lock;
                alone_key = keyCodes.escape;
                variable_name = "hyper_layer";
                sublayers = {
                  # apps
                  o = {
                    a = mkToEvent {shell_command = "open -a raycast://extensions/raycast/raycast-ai/ai-chat";};
                    t = mkToEvent {shell_command = "open -a 'Ghostty'";};
                    b = mkToEvent {shell_command = "open -a 'Arc'";};
                    i = mkToEvent {shell_command = "open -a 'IntelliJ IDEA'";};
                    s = mkToEvent {shell_command = "open -a 'Slack'";};
                    c = mkToEvent {shell_command = "open -a 'Calendar'";};
                  };

                  # window management
                  w = {
                    f = raycastWindow "maximize";
                    h = raycastWindow "left-half";
                    l = raycastWindow "right-half";
                    k = raycastWindow "top-half";
                    j = raycastWindow "bottom-half";
                  };
                };
              })

              (appLayerKey {
                key = keyCodes.backslash;
                variable_name = "per_app_layer";
                alone_key = keyCodes.backslash;
                app_mappings = {
                  "com.jetbrains.intellij" = {
                    m = mkToEvent {
                      key_code = keyCodes.down_arrow;
                      modifiers = ["left_control" "left_shift"];
                    };

                    "shift+m" = mkToEvent {
                      key_code = keyCodes.up_arrow;
                      modifiers = ["left_control" "left_shift"];
                    };

                    n = mkToEvent {
                      key_code = keyCodes.f2;
                      modifiers = ["fn"];
                    };

                    "shift+n" = mkToEvent {
                      key_code = keyCodes.f2;
                      modifiers = ["fn" "left_shift"];
                    };

                    # Debugging shortcuts with mnemonics
                    b = mkToEvent {
                      # Toggle Breakpoint
                      key_code = keyCodes.f8;
                      modifiers = ["fn" "left_command"];
                    };

                    e = mkToEvent {
                      # file structure
                      key_code = keyCodes.f12;
                      modifiers = ["fn" "left_command"];
                    };
                  };
                  "company.thebrowser.Browser" = {
                    i = mkToEvent {
                      # dev tools
                      key_code = keyCodes.i;
                      modifiers = ["left_command" "left_option"];
                    };
                  };
                };
              })

              (homeRowMods
                {
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
