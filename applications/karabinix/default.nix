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

              (mkRule "home row mods" [
                # S = Option/Alt when held, S when tapped
                (mkManipulator {
                  from = mkFromEvent {
                    key_code = keyCodes.s;
                  };
                  to_if_alone = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.s;
                    })
                  ];
                  to_if_held_down = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.left_option;
                    })
                  ];
                  to_delayed_action = {
                    to_if_canceled = [{key_code = keyCodes.s;}];
                    to_if_invoked = [{key_code = "vk_none";}];
                  };
                  description = "S: Option when held, S when tapped";
                })

                # D = Control when held, D when tapped
                (mkManipulator {
                  from = mkFromEvent {
                    key_code = keyCodes.d;
                  };
                  to_if_alone = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.d;
                    })
                  ];
                  to_if_held_down = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.left_control;
                    })
                  ];
                  to_delayed_action = {
                    to_if_canceled = [{key_code = keyCodes.d;}];
                    to_if_invoked = [{key_code = "vk_none";}];
                  };
                  description = "D: control when held, D when tapped";
                })

                # F = Command when held, F when tapped
                (mkManipulator {
                  from = mkFromEvent {
                    key_code = keyCodes.f;
                  };
                  to_if_alone = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.f;
                    })
                  ];
                  to_if_held_down = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.left_command;
                    })
                  ];
                  to_delayed_action = {
                    to_if_canceled = [{key_code = keyCodes.f;}];
                    to_if_invoked = [{key_code = "vk_none";}];
                  };
                  description = "F: Command when held, F when tapped";
                })

                # J = Command when held, J when tapped
                (mkManipulator {
                  from = mkFromEvent {
                    key_code = keyCodes.j;
                  };
                  to_if_alone = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.j;
                    })
                  ];
                  to_if_held_down = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.right_command;
                    })
                  ];
                  to_delayed_action = {
                    to_if_canceled = [{key_code = keyCodes.j;}];
                    to_if_invoked = [{key_code = "vk_none";}];
                  };
                  description = "J: Command when held, J when tapped";
                })

                # K = Control when held, K when tapped
                (mkManipulator {
                  from = mkFromEvent {
                    key_code = keyCodes.k;
                  };
                  to_if_alone = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.k;
                    })
                  ];
                  to_if_held_down = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.right_control;
                    })
                  ];
                  to_delayed_action = {
                    to_if_canceled = [{key_code = keyCodes.k;}];
                    to_if_invoked = [{key_code = "vk_none";}];
                  };
                  description = "K: Control when held, K when tapped";
                })

                # L = Option/Alt when held, L when tapped
                (mkManipulator {
                  from = mkFromEvent {
                    key_code = keyCodes.l;
                  };
                  to_if_alone = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.l;
                    })
                  ];
                  to_if_held_down = [
                    (mkToEvent {
                      halt = true;
                      key_code = keyCodes.right_option;
                    })
                  ];
                  to_delayed_action = {
                    to_if_canceled = [{key_code = keyCodes.l;}];
                    to_if_invoked = [{key_code = "vk_none";}];
                  };
                  description = "L: Option when held, L when tapped";
                })
              ])
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
