{ ... }:
let
  remapHold = from: to: {
    type = "basic";
    from = { key_code = from; };
    to_if_alone = [{
      halt = true;
      key_code = from;
    }];
    to_delayed_action = {
      to_if_invoked = [{ key_code = "vk_none"; }];
      to_if_canceled = [{ key_code = from; }];
    };
    to_if_held_down = [{
      halt = true;
      key_code = to;
    }];
  };
in {
  home.file.karabiner = {
    target = ".config/karabiner/assets/complex_modifications/nix.json";
    text = builtins.toJSON {
      title =
        "managed by Nix (.config/home-manager/applications/karabiner/default.nix)";
      rules = [{
        description =
          "managed by Nix (.config/home-manager/applications/karabiner/default.nix)";
        manipulators = [
          {
            type = "basic";
            from = { key_code = "caps_lock"; };
            to = [{
              lazy = true;
              key_code = "left_control";
            }];
            to_if_alone = [{ key_code = "escape"; }];
          }
          (remapHold "s" "left_option")
          (remapHold "d" "left_control")
          (remapHold "f" "left_command")
          (remapHold "l" "right_option")
          (remapHold "k" "rigth_control")
          (remapHold "j" "right_command")
        ];
      }];
    };
  };
}
