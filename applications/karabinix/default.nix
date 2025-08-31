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
              "basic.to_if_alone_timeout_milliseconds" = 1000;
              "basic.to_if_held_down_threshold_milliseconds" = 500;
              "basic.to_delayed_action_delay_milliseconds" = 500;
            };
            rules = [
              (hyperKey {
                key = keyCodes.caps_lock;
                alone_key = keyCodes.escape;
                mappings = {
                  # apps
                  t = mkToEvent {shell_command = "open -a 'Ghostty'";};
                  b = mkToEvent {shell_command = "open -a 'Arc'";};
                  i = mkToEvent {shell_command = "open -a 'IntelliJ IDEA'";};

                  # window management
                  f = raycastWindow "maximize";
                  h = raycastWindow "left-half";
                  l = raycastWindow "right-half";
                  k = raycastWindow "top-half";
                  j = raycastWindow "bottom-half";
                };
              })

              (appLayerKey {
                key = keyCodes.spacebar;
                variable_name = "per_app_layer";
                alone_key = keyCodes.spacebar;
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
                };
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
