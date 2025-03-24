{...}: let
  remapHold = from: to: {
    type = "basic";
    from = {key_code = from;};
    to_if_alone = [
      {
        halt = true;
        key_code = from;
      }
    ];
    to_delayed_action = {
      to_if_invoked = [{key_code = "vk_none";}];
      to_if_canceled = [{key_code = from;}];
    };
    to_if_held_down = [
      {
        halt = true;
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

  capsLockRemap = {
    from = {
      key_code = "caps_lock";
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
        key_code = "escape";
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
            capsLockRemap
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
