{
  config,
  lib,
  ...
}: let
  safeReadDir = path:
    if builtins.pathExists path
    then builtins.readDir path
    else {};

  jetbrainsDir = "${config.home.homeDirectory}/Library/Application Support/JetBrains";

  jetbrainsProducts = let
    dirContents = safeReadDir jetbrainsDir;
    # Filter to only include directories
    dirNames = builtins.attrNames (lib.filterAttrs (_name: type: type == "directory") dirContents);
  in
    dirNames;

  # Create a flat list of name/value pairs for both files
  jetbrainsFiles = builtins.concatLists (map (version: [
      {
        name = "Library/Application Support/JetBrains/${version}/idea.properties";
        value = {source = ./idea.properties;};
      }
      {
        name = "Library/Application Support/JetBrains/${version}/idea.vmoptions";
        value = {source = ./idea.vmoptions;};
      }
      {
        name = "Library/Application Support/JetBrains/${version}/keymaps/macOS copy.xml";
        value = {source = ./keymap.xml;};
      }
    ])
    jetbrainsProducts);
in {
  home.file = builtins.listToAttrs jetbrainsFiles;
}
