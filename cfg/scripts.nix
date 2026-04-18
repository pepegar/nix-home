{pkgs, ...}: let
  userBin = pkgs.runCommand "user-bin" {} ''
    mkdir -p $out/bin
    install -m755 ${../scripts/bin/gswitch.sh}        $out/bin/gswitch
    install -m755 ${../scripts/bin/jira-create.sh}    $out/bin/ppg-jira-create
    install -m755 ${../scripts/bin/jira-branch.sh}    $out/bin/ppg-jira-branch
    install -m755 ${../scripts/bin/gh_create_pr.sh}   $out/bin/gh_create_pr
    install -m755 ${../scripts/bin/gh_merge_pr.sh}    $out/bin/gh_merge_pr
    install -m755 ${../scripts/bin/ppg.sh}            $out/bin/ppg
    install -m755 ${../scripts/bin/git-wt.sh}         $out/bin/git-wt
    install -m755 ${../scripts/bin/wt.sh}             $out/bin/wt
    install -m755 ${../scripts/bin/pr.sh}             $out/bin/ppg-pr
    install -m755 ${../scripts/bin/autocommit.sh}     $out/bin/autocommit.sh
    install -m755 ${../scripts/bin/mouse-center.sh}   $out/bin/mouse-center.sh
    install -m755 ${../scripts/bin/ghqj.sh}           $out/bin/ghqj
    install -m755 ${../scripts/bin/yabai-snap-left.sh}   $out/bin/yabai-snap-left
    install -m755 ${../scripts/bin/yabai-snap-right.sh}  $out/bin/yabai-snap-right
    install -m755 ${../scripts/bin/yabai-snap-top.sh}    $out/bin/yabai-snap-top
    install -m755 ${../scripts/bin/yabai-snap-bottom.sh} $out/bin/yabai-snap-bottom
    cat > $out/bin/kotlin-ls <<'EOF'
    #!/bin/sh
    exec /Users/pepe/kotlin-lsp/kotlin-lsp.sh "$@"
    EOF
    chmod 755 $out/bin/kotlin-ls
  '';
in {
  home.file."bin".source = "${userBin}/bin";
}
