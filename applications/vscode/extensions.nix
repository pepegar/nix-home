{ pkgs, ... }: {
  programs.vscode = {
    mutableExtensionsDir = true;
    extensions = (with pkgs.vscode-extensions; [
      vscodevim.vim
      mvllow.rose-pine
      alefragnani.project-manager
      github.vscode-github-actions
      github.vscode-pull-request-github
      mkhl.direnv
      haskell.haskell
      antfu.icons-carbon
      bradlc.vscode-tailwindcss
      catppuccin.catppuccin-vsc-icons
      christian-kohler.path-intellisense
      dbaeumer.vscode-eslint
      denoland.vscode-deno
      editorconfig.editorconfig
      esbenp.prettier-vscode
      github.copilot
      github.copilot-chat
      jnoortheen.nix-ide
      llvm-vs-code-extensions.vscode-clangd
      mikestead.dotenv
      mkhl.direnv
      ms-python.black-formatter
      ms-python.isort
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode.cmake-tools
      ms-vscode.makefile-tools
      ms-toolsai.jupyter
      ms-toolsai.jupyter-renderers
      ms-toolsai.jupyter-keymap
      ms-toolsai.vscode-jupyter-cell-tags
      ms-toolsai.vscode-jupyter-slideshow
      naumovs.color-highlight
      oderwat.indent-rainbow
      redhat.java
      redhat.vscode-yaml
      usernamehw.errorlens
      yzhang.markdown-all-in-one
    ]);
  };
}
