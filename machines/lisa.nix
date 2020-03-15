{ config, pkgs, ... }:

with pkgs;


let
  buildPythonPackage = python3Packages.buildPythonPackage;
  fetchPypi = python3Packages.fetchPypi;
  google-auth-1-10-0 = buildPythonPackage rec {
    pname = "google-auth";
    version = "1.10.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1xs8ch6bz57vs6j0p8061c7wj9ahkvrfpf1y9v7r009979507ckv";
    };

    checkInputs = with python3Packages; [ pytest mock oauth2client flask requests urllib3 pytest-localserver freezegun ];
    propagatedBuildInputs = with python3Packages; [ six pyasn1-modules cachetools rsa setuptools ];

    doCheck = false;
  };
  google-auth-oauthlib = python37Packages.google-auth-oauthlib.overridePythonAttrs(old: rec {
    propagatedBuildInputs = [google-auth-1-10-0 python37Packages.requests_oauthlib];
  });
  googleapis_common_protos = python37Packages.googleapis_common_protos.overridePythonAttrs(old: rec {
    version = "1.51.0";
    src =  fetchPypi {
      pname = "googleapis-common-protos";
      inherit version;
      sha256 = "0vi2kr0daivx2q1692lp3y61bfnvdw471xsfwi8924br89q92g01";
    };
    doCheck = false;
  });
  google_api_core = python37Packages.google_api_core.overridePythonAttrs(old: rec {
    version = "1.16.0";
    src =  fetchPypi {
      pname = "google-api-core";
      inherit version;
      sha256 = "1qh30ji399gngv2j1czzvi3h0mgx3lfdx2n8qp8vii7ihyh65scj";
    };
    propagatedBuildInputs = [
      googleapis_common_protos
      google-auth-1-10-0
      python3Packages.requests
    ];
    doCheck = false;
  });
  google_cloud_core = python37Packages.google_cloud_core.overridePythonAttrs(old: rec {
    version = "1.3.0";
    src =  fetchPypi {
      pname = "google-cloud-core";
      inherit version;
      sha256 = "1n19q57y4d89cjgmrg0f2a7yp7l1np2448mrhpndq354h389m3w7";
    };
    propagatedBuildInputs = [ google_api_core ];
    doCheck = false;
  });
  google_resumable_media = python37Packages.google_resumable_media.overridePythonAttrs(old: rec {
    version = "0.5.0";
    src =  fetchPypi {
      pname = "google-resumable-media";
      inherit version;
      sha256 = "0aldswz9lsw05a2gx26yjal6lcxhfqpn085zk1czvjz1my4d33ra";
    };
    doCheck = false;
  });
  google_cloud_bigquery = python37Packages.google_cloud_bigquery.overridePythonAttrs(old: rec {
    version = "1.22.0";
    src =  fetchPypi {
      pname = "google-cloud-bigquery";
      inherit version;
      sha256 = "0rhvxqb48pgzwibwzbk9qn4rpcr5ic1p97890vqxavahrsdq6bjr";
    };
    propagatedBuildInputs = [
      google-auth-1-10-0
      google_resumable_media
      google_cloud_core
    ];
    doCheck = false;
  });
  pydata-google-auth = buildPythonPackage rec {
    pname = "pydata-google-auth";

    version = "0.3.0";

    src = fetchurl {
      url = "https://github.com/pydata/pydata-google-auth/releases/download/0.3.0/pydata-google-auth-0.3.0.tar.gz";
      sha256 = "1fhrsr1v2rbzggkiyma5fjvaybd9w3iz7yf87ihkrpzc2izj59xh";
    };

    propagatedBuildInputs = [
      google-auth-1-10-0
      google-auth-oauthlib
      # python37Packages.google-auth-httplib2
      python3Packages.setuptools
    ];

    # No tests
    doCheck = false;
  };
  pandas-gbq = buildPythonPackage rec {
    pname = "pandas-gbq";

    version = "0.13.1";

    src = fetchurl {
      url = "https://github.com/pydata/pandas-gbq/archive/e177978227c9a42e3c63a864616c6ac7d98f2840.tar.gz";
      sha256 = "09hynng0gv2av6h8l1ii2nvv0ly7srvf4lr05v1ncvg4nqgpwm3m";
    };

    propagatedBuildInputs = with python3Packages; [
      pydata-google-auth
      google_cloud_bigquery
      pandas
      setuptools
    ];

    # No tests
    doCheck = false;
  };
  rescuetime-overlay = import ../overlays/rescuetime.nix;
  python-packages = python-packages: with python-packages; [
    pandas
    pandas-gbq
    vega
    tensorflow
    Keras
    numpy
    scipy
    scikitlearn
    spacy
    gensim
    xgboost
    nltk
    jupyter
    matplotlib
    seaborn
    altair

    flask
    dash
  ];
  python-with-packages = pkgs.python3.withPackages python-packages;
in rec {
  imports = [
    ../applications/fzf
    ../applications/zsh
    ../applications/neovim
    ../applications/emacs
    ../applications/tmux
    ../applications/direnv

    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/xresources.nix
    ../cfg/sbt
  ];

  nixpkgs.overlays =
    let path = ../overlays; in with builtins;
          map (n: import (path + ("/" + n)))
            (filter (n: match ".*\\.nix" n != null ||
                        pathExists (path + ("/" + n + "/default.nix")))
              (attrNames (readDir path)));

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.heroku
    pkgs.ag
    pkgs.clang
    pkgs.gnupg
    pkgs.pass
    pkgs.htop
    pkgs.jdk8
    pkgs.nix-prefetch-scripts
    pkgs.openvpn
    pkgs.dunst
    pkgs.sbt
    pkgs.libreoffice
    pkgs.slack
    pkgs.sqlite
    pkgs.metals-emacs
    pkgs.metals-vim
    pkgs.robo3t
    pkgs.spotify
    python-with-packages
  ];
}
