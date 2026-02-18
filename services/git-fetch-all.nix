{
  config,
  pkgs,
  ...
}: {
  launchd.user.agents = {
    "git-fetch-all" = {
      serviceConfig = {
        KeepAlive = false;
        RunAtLoad = false;
        StartInterval = 86400; # Run once per day
        StandardOutPath = "/tmp/git-fetch-all.out.log";
        StandardErrorPath = "/tmp/git-fetch-all.err.log";
      };
      script = ''
        source ${config.system.build.setEnvironment}

        # Pick up the macOS SSH agent so git can use SSH keys
        export SSH_AUTH_SOCK=$(launchctl getenv SSH_AUTH_SOCK)

        GHQ_ROOT=$(${pkgs.ghq}/bin/ghq root)

        echo "$(date): Starting git fetch for all GHQ repos..."

        for repo in $(${pkgs.ghq}/bin/ghq list); do
          dir="$GHQ_ROOT/$repo"

          # Skip if git lock files exist (operation in progress)
          if find "$dir/.git" -name "*.lock" 2>/dev/null | grep -q .; then
            echo "  [$repo] Skipping (lock file present)"
            continue
          fi

          ${pkgs.git}/bin/git -C "$dir" fetch --all --quiet 2>&1 && \
            echo "  [$repo] OK" || \
            echo "  [$repo] FAILED"
        done

        echo "$(date): Done."
      '';
    };
  };
}
