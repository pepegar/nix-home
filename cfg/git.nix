{pkgs, ...}: {
  home.packages = with pkgs; [gh ghq git-absorb];

  programs.git = {
    enable = true;
    userEmail = "pepe@pepegar.com";
    #delta.enable = true;

    extraConfig = {
      github = {user = "pepegar";};
      user.name = "Pepe Garcia";

      alias = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
        br = "branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate";
        co = "checkout";

        wt = "!sh -c 'worktree=$(git worktree list --porcelain | grep worktree | cut -d\" \" -f2 | fzf --height 40% --reverse) && [ -n \"$worktree\" ] && cd \"$worktree\" && exec $SHELL'";

        addm = "!git ls-files --deleted --modified --other --exclude-standard | fzf -0 -m --preview 'git diff --color=always {-1}' | xargs -r git add";
        addmp = "!git ls-files --deleted --modified --exclude-standard | fzf -0 -m --preview 'git diff --color=always {-1}' | xargs -r -o git add -p";
        sb = "!bash ~/bin/gswitch";
        bd = "!git config branch.$(git rev-parse --abbrev-ref HEAD).description";
        cb = "!git branch --all | grep -v '^[*+]' | awk '{print $1}' | fzf -0 --preview 'git show --color=always {-1}' | sed 's/remotes\\/origin\\///g' | xargs -r git checkout";
        cs = "!git stash list | fzf -0 --preview 'git show --pretty=oneline --color=always --patch \"$(echo {} | cut -d: -f1)\"' | cut -d: -f1 | xargs -r git stash pop";
        db = "!git branch | grep -v '^[*+]' | awk '{print $1}' | fzf -0 --multi --preview 'git show --color=always {-1}' | xargs -r git branch --delete";
        Db = "!git branch | grep -v '^[*+]' | awk '{print $1}' | fzf -0 --multi --preview 'git show --color=always {-1}' | xargs -r git branch --delete --force";
        ds = "!git stash list | fzf -0 --preview 'git show --pretty=oneline --color=always --patch \"$(echo {} | cut -d: -f1)\"' | cut -d: -f1 | xargs -r git stash drop";
        edit = "!git ls-files --modified --other --exclude-standard | sort -u | fzf -0 --multi --preview 'git diff --color {}' | xargs -r $EDITOR -p";
        fixup = "!git log --oneline --no-decorate --no-merges | fzf -0 --preview 'git show --color=always --format=oneline {1}' | awk '{print $1}' | xargs -r git commit --fixup";
        resetm = "!git diff --name-only --cached | fzf -0 -m --preview 'git diff --color=always {-1}' | xargs -r git reset";
        autocommit = "!bash ~/bin/autocommit.sh";
        ac = "autocommit";
      };

      diff.external = "difft";

      ghq.root = "~/projects";

      init.defaultBranch = "main";

      rerere.enabled = true;
      rebase.updateRefsa = true;
      push.autoSetupRemote = true;
    };

    signing = {
      key = "BC10F5DA684B5E5978B836CCB32204E4B8C00747";
      signByDefault = true;
    };
  };

  home.file.".config/gh/config.yml" = {
    source = ./gh/config.yml;
  };
}
