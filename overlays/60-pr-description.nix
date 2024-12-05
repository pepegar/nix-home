_: pkgs:
with pkgs; let
  pythonPackages = python3.pkgs;

  pr-description = pythonPackages.buildPythonApplication {
    pname = "pr-description";
    version = "1.0.0";

    src = ./pr-description;

    format = "setuptools";

    propagatedBuildInputs = with pythonPackages; [
      openai
      termcolor
    ];

    meta = with lib; {
      description = "Generate pull request descriptions from git commits";
      license = licenses.mit;
      maintainers = [maintainers.pepegar];
    };
  };

  wrapper = writeShellScriptBin "pr-description" ''
    #!/usr/bin/env bash

    # Forward all arguments to the Python script
    ${pr-description}/bin/pr_description "$@"
  '';
in {
  inherit pr-description;
  pr-description-wrapped = wrapper;
}
