{ pkgs, ... }:
let
  editor = {
    "editor.bracketPairColorization.enabled" = true;
    "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;
    "editor.cursorBlinking" = "smooth";
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.fontFamily" = "'PragmataPro'";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 14;
    "editor.fontWeight" = "500";
    "editor.formatOnSave" = true;
    "editor.guides.bracketPairs" = true;
    "editor.guides.indentation" = true;
    "editor.inlineSuggest.enabled" = true;
    "editor.linkedEditing" = true;
    "editor.lineHeight" = 22;
    "editor.minimap.enabled" = false;
    "editor.renderLineHighlight" = "all";
    "editor.scrollbar.horizontal" = "hidden";
    "editor.scrollbar.vertical" = "hidden";
    "editor.semanticHighlighting.enabled" = true;
    "editor.showUnused" = true;
    "editor.smoothScrolling" = true;
    "editor.tabCompletion" = "on";
    "editor.tabSize" = 4;
    "editor.codeLens" = false;
    "editor.trimAutoWhitespace" = true;
    "emmet.includeLanguages" = { "django-html" = "html"; };
  };

  explorer = {
    "explorer.confirmDelete" = false;
    "explorer.confirmDragAndDrop" = false;
  };

  files = {
    "files.insertFinalNewline" = true;
    "files.trimTrailingWhitespace" = true;
    "files.autosave" = "afterDelay";
  };

  terminal = {
    "terminal.integrated.fontSize" = 13;
    "terminal.integrated.smoothScrolling" = true;
    "terminal.integrated.inheritEnv" = false;
  };

  window = {
    "window.autoDetectColorScheme" = true;
    "window.dialogStyle" = "native";
    "window.titleBarStyle" = "custom";
  };

  defaultFormatter = {
    "[css]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[java]"."editor.defaultFormatter" = "redhat.java";
    "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
    "[python]"."editor.defaultFormatter" = "ms-python.black-formatter";
    "[scss]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
    "[haskell]"."editor.defaultFormatter" = "haskell.haskell";
  };

  git = {
    "git.autofetch" = true;
    "git.enableSmartCommit" = true;
  };

  github = {
    "github.copilot.enable" = {
      "*" = true;
      "markdown" = true;
    };
    "github.copilot.editor.enableAutoCompletions" = true;
  };

  path-intellisense = {
    "path-intellisense.autoSlashAfterDirectory" = true;
    "path-intellisense.autoTriggerNextSuggestion" = true;
    "path-intellisense.extensionOnImport" = true;
    "path-intellisense.showHiddenFiles" = true;
  };

  telemetry = {
    "redhat.telemetry.enabled" = false;
    "telemetry.telemetryLevel" = "off";
  };

  java = {
    "java.configuration.runtimes" = [{
      name = "JavaSE-17";
      path = "${pkgs.jdk17}/lib/openjdk";
      default = true;
    }];
    "java.format.settings.profile" = "GoogleStyle";
    "java.jdt.ls.java.home" = "${pkgs.jdk17}/lib/openjdk";
  };

  nix = {
    "nix.enableLanguageServer" = true;
    "nix.formatterPath" = "${pkgs.alejandra}/bin/alejandra";
    "nix.serverPath" = "${pkgs.nil}/bin/nil";
    "nix.serverSettings"."nil"."formatting"."command" =
      [ "${pkgs.alejandra}/bin/alejandra" ];
  };

  python = {
    "pylint.enabled" = true;
    "python.defaultInterpreterPath" = "${pkgs.python3}/bin/python";
    "python.languageServer" = "Pylance";
    #"python.analysis.typeCheckingMode" = "basic";
  };

  workbench = {
    "workbench.iconTheme" = "rose-pine-icons";
    "workbench.productIconTheme" = "icons-carbon";
    "workbench.colorTheme" = "Rosé Pine";
    "workbench.preferredDarkColorTheme" = "Rosé Pine";
    "workbench.preferredLightColorTheme" = "Rosé Pine Dawn";
  };

  vim = { "vim.smartRelativeLine" = true; };
in {
  programs.vscode.userSettings = {
    "extensions.autoCheckUpdates" = false;
    "extensions.ignoreRecommendations" = true;
    "update.mode" = "none";
  } // editor // explorer // files // terminal // window // workbench
    // defaultFormatter // git // github // path-intellisense // telemetry
    // java // nix // python // vim;
}
