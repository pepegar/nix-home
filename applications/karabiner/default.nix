{...}: let
  remapHold = from: to: {
    type = "basic";
    from = {
      key_code = from;
      modifiers = {};
    };
    parameters = {
      "basic.to_if_alone_timeout_milliseconds" = 250;
      "basic.to_if_held_down_threshold_milliseconds" = 250;
    };
    to_if_alone = [
      {
        key_code = from;
      }
    ];
    to_if_held_down = [
      {
        key_code = to;
      }
    ];
  };

  sysdiagnoseRemap = key: {
    description = "Avoid starting sysdiagnose with the built-in macOS shortcut cmd+shift+option+ctrl+" + key + ".";
    from = {
      key_code = key;
      modifiers = {
        mandatory = [
          "command"
          "shift"
          "option"
          "control"
        ];
      };
    };
    to = [];
    type = "basic";
  };

  hyperOnHoldKeyOtherwise = from: to: {
    from = {
      key_code = from;
    };
    to = [
      {
        key_code = "left_shift";
        modifiers = [
          "left_command"
          "left_control"
          "left_option"
        ];
      }
    ];
    to_if_alone = [
      {
        key_code = to;
      }
    ];
    type = "basic";
  };
in {
  home.file.karabiner = {
    target = ".config/karabiner/assets/complex_modifications/nix.json";
    text = builtins.toJSON {
      title = "managed by Nix (.config/home-manager/applications/karabiner/default.nix)";
      rules = [
        {
          description = "managed by Nix (.config/home-manager/applications/karabiner/default.nix)";
          manipulators = [
            (hyperOnHoldKeyOtherwise "caps_lock" "escape")
            (hyperOnHoldKeyOtherwise "h" "h")
            (hyperOnHoldKeyOtherwise "g" "g")
            (sysdiagnoseRemap "comma")
            (sysdiagnoseRemap "period")
            (sysdiagnoseRemap "slash")
            (remapHold "s" "left_option")
            (remapHold "d" "left_control")
            (remapHold "f" "left_command")
            (remapHold "l" "right_option")
            (remapHold "k" "right_control")
            (remapHold "j" "right_command")
          ];
        }
      ];
    };
  };
}
