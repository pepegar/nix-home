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

        MAX_JOBS=8
        GHQ_ROOT=$(${pkgs.ghq}/bin/ghq root)

        echo "$(date): Starting git fetch for all GHQ repos (max $MAX_JOBS parallel)..."

        job_count=0

        fetch_repo() {
          local repo="$1"
          local dir="$GHQ_ROOT/$repo"

          if find "$dir/.git" -name "*.lock" 2>/dev/null | grep -q .; then
            echo "  [$repo] Skipping (lock file present)"
            return
          fi

          ${pkgs.git}/bin/git -C "$dir" fetch --all --quiet 2>&1 && \
            echo "  [$repo] OK" || \
            echo "  [$repo] FAILED"

          # Update submodules if any exist
          if [ -f "$dir/.gitmodules" ]; then
            ${pkgs.git}/bin/git -C "$dir" submodule update --init --recursive --quiet 2>&1 && \
              echo "  [$repo] submodules OK" || \
              echo "  [$repo] submodules FAILED"
          fi
        }

        for repo in $(${pkgs.ghq}/bin/ghq list); do
          fetch_repo "$repo" &
          job_count=$((job_count + 1))

          if [ "$job_count" -ge "$MAX_JOBS" ]; then
            wait -n
            job_count=$((job_count - 1))
          fi
        done

        wait
        echo "$(date): Done."
      '';
    };
  };
}
