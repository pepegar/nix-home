{ buildVimPlugin }:

{
  asyncrun-vim = buildVimPlugin {
    name = "asyncrun-vim";
    src = builtins.fetchTarball {
      name = "AsyncRun-Vim-v2.7.5";
      url = "https://github.com/skywind3000/asyncrun.vim/archive/2.7.5.tar.gz";
      sha256 = "02fiqf4rcrxbcgvj02mpd78wkxsrnbi54aciwh9fv5mnz5ka249m";
    };
  };

  ctrlsf-vim = buildVimPlugin {
    name = "ctrlsf-vim";
    src = builtins.fetchTarball {
      name = "CtrlSF-Vim-v2.1.2";
      url = "https://github.com/dyng/ctrlsf.vim/archive/v2.1.2.tar.gz";
      sha256 = "1cl0hkddx7i553lld23zmjbjcqpvyvyzh5gsd0rfpwj12xpdqpw7";
    };
  };

  fzf-hoogle = buildVimPlugin {
    name = "fzf-hoogle-vim";
    src = builtins.fetchTarball {
      name = "fzf-hoogle-vim-v2.3.0";
      url = "https://github.com/monkoose/fzf-hoogle.vim/archive/v2.3.0.tar.gz";
      sha256 = "00ay9250wdl8ym70dpv4zbs49g40dla6i48bk1zl95lp62kld4hr";
    };
  };

}
