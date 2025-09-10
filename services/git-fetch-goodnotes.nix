{
  config,
  pkgs,
  ...
}: let
  secrets = import ../secrets.nix;
  path = secrets.goodnotesRepoPath;
in {
  launchd.user.agents = {
    "git-fetch-goodnotes" = {
      serviceConfig = {
        WorkingDirectory = path;
        KeepAlive = false;
        RunAtLoad = false;
        StartInterval = 60 * 30; # Run every 30m
        StandardOutPath = "/tmp/git-fetch-goodnotes.out.log";
        StandardErrorPath = "/tmp/git-fetch-goodnotes.err.log";
      };
      script = ''
        source ${config.system.build.setEnvironment}

        # Check if git is already running by looking for lock files
        if find .git -name "*.lock" | grep -q .; then
          echo "Git operation in progress, skipping fetch"
          exit 0
        fi

        exec ${pkgs.git}/bin/git fetch
      '';
    };
  };
}
