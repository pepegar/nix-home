{...}: {
  home.file."bin/coldturkey" = {
    # create an alias for coldutrkey and pass arguments at the end
    text = ''
      /Applications/Cold\ Turkey\ Blocker.app/Contents/MacOS/Cold\ Turkey\ Blocker $@
    '';
    executable = true;
  };
}
