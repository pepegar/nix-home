{ ... }:

{
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
          {
            type = "basic";
            from = { key_code = "s"; };
            to_if_alone = [{
              halt = true;
              key_code = "s";
            }];
            to_delayed_action = {
              to_if_invoked = [{ key_code = "vk_none"; }];
              to_if_canceled = [{ key_code = "s"; }];
            };
            to_if_held_down = [{
              halt = true;
              key_code = "left_option";
            }];
          }
          {
            type = "basic";
            from = { key_code = "d"; };
            to_if_alone = [{
              halt = true;
              key_code = "d";
            }];
            to_delayed_action = {
              to_if_invoked = [{ key_code = "vk_none"; }];
              to_if_canceled = [{ key_code = "d"; }];
            };
            to_if_held_down = [{
              halt = true;
              key_code = "left_control";
            }];
          }
          {
            type = "basic";
            from = { key_code = "f"; };
            to_if_alone = [{
              halt = true;
              key_code = "f";
            }];
            to_delayed_action = {
              to_if_invoked = [{ key_code = "vk_none"; }];
              to_if_canceled = [{
                halt = true;
                key_code = "f";
              }];
            };
            to_if_held_down = [{
              halt = true;
              key_code = "right_option";
            }];
          }
          {
            type = "basic";
            from = { key_code = "l"; };
            to_if_alone = [{
              halt = true;
              key_code = "l";
            }];
            to_delayed_action = {
              to_if_invoked = [{ key_code = "vk_none"; }];
              to_if_canceled = [{ key_code = "l"; }];
            };
            to_if_held_down = [{
              halt = true;
              key_code = "right_option";
            }];
          }
          {
            type = "basic";
            from = { key_code = "k"; };
            to_if_alone = [{
              halt = true;
              key_code = "k";
            }];
            to_delayed_action = {
              to_if_invoked = [{ key_code = "vk_none"; }];
              to_if_canceled = [{ key_code = "k"; }];
            };
            to_if_held_down = [{
              halt = true;
              key_code = "left_control";
            }];
          }
          {
            type = "basic";
            from = { key_code = "j"; };
            to_if_alone = [{
              halt = true;
              key_code = "j";
            }];
            to_delayed_action = {
              to_if_invoked = [{ key_code = "vk_none"; }];
              to_if_canceled = [{
                halt = true;
                key_code = "j";
              }];
            };
            to_if_held_down = [{
              halt = true;
              key_code = "right_command";
            }];
          }
        ];
      }];
    };
  };
}
