{inputs, ...}: {
  services.karabinix = {
    enable = true;
    configuration = with inputs.karabinix.lib; {
      profiles = [
        (mkProfile {
          name = "created with karabinix";
          selected = true;

          complex_modifications = mkComplexModification {
            rules = [
              (hyperKey {
                key = keyCodes.caps_lock;
                alone_key = keyCodes.escape;
                mappings = {
                  t = mkToEvent {shell_command = "open -a 'Ghostty'";};
                  b = mkToEvent {shell_command = "open -a 'Arc'";};
                };
              })

              # IntelliJ IDEA layer
              (layerKey {
                key = keyCodes.i;
                variable_name = "intellij_layer";
                conditions = [
                  (appCondition ["com.jetbrains.intellij" "com.jetbrains.intellij.ce"] "frontmost_application_if")
                ];
                mappings = {
                  # Navigation: Previous shortcuts (i+p m, i+p e)
                  p = {
                    m = mkToEvent {
                      key_code = keyCodes.up_arrow;
                      modifiers = ["left_option" "left_command"];
                    };
                    e = mkToEvent {
                      key_code = keyCodes.f2;
                      modifiers = ["left_shift"];
                    };
                  };

                  # Navigation: Next shortcuts (i+n m, i+n e)
                  n = {
                    m = mkToEvent {
                      key_code = keyCodes.down_arrow;
                      modifiers = ["left_option" "left_command"];
                    };
                    e = mkToEvent {
                      key_code = keyCodes.f2;
                    };
                  };

                  # Debugging shortcuts with mnemonics
                  b = mkToEvent {
                    # Toggle Breakpoint
                    key_code = keyCodes.f8;
                    modifiers = ["left_command"];
                  };
                  r = mkToEvent {
                    # Debug Run
                    key_code = keyCodes.f9;
                    modifiers = ["left_shift" "left_command"];
                  };
                  s = mkToEvent {
                    # Step Over
                    key_code = keyCodes.f8;
                  };
                  i = mkToEvent {
                    # Step Into
                    key_code = keyCodes.f7;
                  };
                  o = mkToEvent {
                    # Step Out
                    key_code = keyCodes.f8;
                    modifiers = ["left_shift"];
                  };
                  c = mkToEvent {
                    # Continue/Resume
                    key_code = keyCodes.f9;
                    modifiers = ["left_command"];
                  };

                  # Additional navigation shortcuts
                  g = mkToEvent {
                    # Go to Line
                    key_code = keyCodes.g;
                    modifiers = ["left_command"];
                  };
                  f = mkToEvent {
                    # Find File
                    key_code = keyCodes.o;
                    modifiers = ["left_command" "left_shift"];
                  };
                  t = mkToEvent {
                    # Go to Test
                    key_code = keyCodes.n;
                    modifiers = ["left_command" "left_shift"];
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
