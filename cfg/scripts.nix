{...}: {
  home.file."bin/gswitch" = {
    source = ../scripts/bin/gswitch.sh;
    executable = true;
  };

  home.file."bin/ppg-jira-create" = {
    source = ../scripts/bin/jira-create.sh;
    executable = true;
  };

  home.file."bin/ppg-jira-branch" = {
    source = ../scripts/bin/jira-branch.sh;
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

  home.file."bin/git-wt" = {
    source = ../scripts/bin/git-wt.sh;
    executable = true;
  };

  home.file."bin/ppg-pr" = {
    source = ../scripts/bin/pr.sh;
    executable = true;
  };

  home.file."bin/autocommit.sh" = {
    source = ../scripts/bin/autocommit.sh;
    executable = true;
  };
}
