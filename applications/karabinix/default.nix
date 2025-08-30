{inputs, ...}: {
  services.karabinix = {
    enable = true;
    configuration = with inputs.karabinix.lib; {
      profiles = [
        (mkProfile {
          name = "created with karabinix";
          selected = true;

          simple_modifications = [
            (mapKey keyCodes.caps_lock keyCodes.left_control)
          ];

          complex_modifications = mkComplexModification {
            rules = [
              (vimNavigation {layer_key = keyCodes.caps_lock;})
            ];
          };
        })
      ];
    };
  };
}
