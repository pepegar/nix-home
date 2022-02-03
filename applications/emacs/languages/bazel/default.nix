{ ... }: {
  programs.emacs.init.usePackage = {
    bazel-mode = {
      enable = true;
      mode = [
        ''("WORKSPACE\\(\\.bazel\\)?\\'" . bazel-mode)''
        ''("BUILD\\(\\.bazel\\)?\\'" . bazel-mode)''
        ''("\\.bazel\\'" . bazel-mode)''
        ''("\\.bzl\\'" . bazel-mode)''
      ];
    };
  };

}
