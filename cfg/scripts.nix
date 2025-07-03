{...}: {
  home.file."bin/gswitch" = {
    source = ../scripts/bin/gswitch.sh;
    executable = true;
  };

  home.file."bin/jira-create" = {
    source = ../scripts/bin/jira-create.sh;
    executable = true;
  };

  home.file."bin/gh_create_pr" = {
    source = ../scripts/bin/gh_create_pr.sh;
    executable = true;
  };

  home.file."bin/ppg" = {
    source = ../scripts/bin/ppg.sh;
    executable = true;
  };

  home.file."bin/kotlin-ls" = {
    text = ''
      #!/bin/sh
      exec /Users/pepe/kotlin-lsp/kotlin-lsp.sh "$@"
    '';
    executable = true;
  };
}
