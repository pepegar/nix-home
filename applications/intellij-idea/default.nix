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
in {
  home.file = builtins.listToAttrs (map (version: {
      name = "Library/Application Support/JetBrains/${version}/idea.properties";
      value = {source = ./idea.properties;};
    })
    jetbrainsProducts);
}
