self: pkgs:

with pkgs;

let
  buildPythonPackage = pkgs.python3Packages.buildPythonPackage;
  fetchPypi = pkgs.python3Packages.fetchPypi;
  google-auth-1-10-0 = buildPythonPackage rec {
    pname = "google-auth";
    version = "1.10.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1xs8ch6bz57vs6j0p8061c7wj9ahkvrfpf1y9v7r009979507ckv";
    };

    checkInputs = with pkgs.python3Packages; [ pytest mock oauth2client flask requests urllib3 pytest-localserver freezegun ];
    propagatedBuildInputs = with pkgs.python3Packages; [ six pyasn1-modules cachetools rsa setuptools ];

    doCheck = false;
  };
  google-auth-oauthlib = pkgs.python37Packages.google-auth-oauthlib.overridePythonAttrs(old: rec {
    propagatedBuildInputs = [google-auth-1-10-0 pkgs.python37Packages.requests_oauthlib];
  });
  googleapis_common_protos = pkgs.python37Packages.googleapis_common_protos.overridePythonAttrs(old: rec {
    version = "1.51.0";
    src =  fetchPypi {
      pname = "googleapis-common-protos";
      inherit version;
      sha256 = "0vi2kr0daivx2q1692lp3y61bfnvdw471xsfwi8924br89q92g01";
    };
    doCheck = false;
  });
  google_api_core = pkgs.python37Packages.google_api_core.overridePythonAttrs(old: rec {
    version = "1.16.0";
    src =  fetchPypi {
      pname = "google-api-core";
      inherit version;
      sha256 = "1qh30ji399gngv2j1czzvi3h0mgx3lfdx2n8qp8vii7ihyh65scj";
    };
    propagatedBuildInputs = [
      googleapis_common_protos
      google-auth-1-10-0
      pkgs.python3Packages.requests
    ];
    doCheck = false;
  });
  google_cloud_core = pkgs.python37Packages.google_cloud_core.overridePythonAttrs(old: rec {
    version = "1.3.0";
    src =  fetchPypi {
      pname = "google-cloud-core";
      inherit version;
      sha256 = "1n19q57y4d89cjgmrg0f2a7yp7l1np2448mrhpndq354h389m3w7";
    };
    propagatedBuildInputs = [ google_api_core ];
    doCheck = false;
  });
  google_resumable_media = pkgs.python37Packages.google_resumable_media.overridePythonAttrs(old: rec {
    version = "0.5.0";
    src =  fetchPypi {
      pname = "google-resumable-media";
      inherit version;
      sha256 = "0aldswz9lsw05a2gx26yjal6lcxhfqpn085zk1czvjz1my4d33ra";
    };
    doCheck = false;
  });
  google_cloud_bigquery = pkgs.python37Packages.google_cloud_bigquery.overridePythonAttrs(old: rec {
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

    src = pkgs.fetchurl {
      url = "https://github.com/pydata/pydata-google-auth/releases/download/0.3.0/pydata-google-auth-0.3.0.tar.gz";
      sha256 = "1fhrsr1v2rbzggkiyma5fjvaybd9w3iz7yf87ihkrpzc2izj59xh";
    };

    propagatedBuildInputs = [
      google-auth-1-10-0
      google-auth-oauthlib
      # python37Packages.google-auth-httplib2
      pkgs.python3Packages.setuptools
    ];

    # No tests
    doCheck = false;
  };
  pandas-gbq = buildPythonPackage rec {
    pname = "pandas-gbq";

    version = "0.13.1";

    src = pkgs.fetchurl {
      url = "https://github.com/pydata/pandas-gbq/archive/e177978227c9a42e3c63a864616c6ac7d98f2840.tar.gz";
      sha256 = "09hynng0gv2av6h8l1ii2nvv0ly7srvf4lr05v1ncvg4nqgpwm3m";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [
      pydata-google-auth
      google_cloud_bigquery
      pandas
      setuptools
    ];

    # No tests
    doCheck = false;
  };

  vaderSentiment = buildPythonPackage rec {
    pname = "vaderSentiment";

    version = "3.3.1";

    src =  fetchPypi {
      pname = "vaderSentiment";
      inherit version;
      sha256 = "1bviin2rn4331injdwnrn5m51ga0hwp8gffb4n8vp89m30zvb8vf";
    };

    # No tests
    doCheck = false;
  };
  tf-bin = pkgs.python3Packages.tensorflow-bin.overridePythonAttrs(old: rec {
    cudaSupport = true;
  });

  myPythonPackages = with python37Packages; [
    vaderSentiment
    pandas-gbq
    pydata-google-auth
    google_cloud_bigquery
    pandas
    tf-bin
    Keras
    vega
    numpy
    scipy
    scikitlearn
    spacy
    gensim
    xgboost
    nltk
    jupyter
    jupyterlab
    matplotlib
    seaborn
    altair
  ];

  myPythonEnv = python37.buildEnv.override {
    extraLibs = myPythonPackages;
    ignoreCollisions = true;
  };

  myJupyter = jupyter.override {
    definitions = {
      # This is the Python kernel we have defined above.
      python3 = {
        displayName = "Python 3";
        argv = [
          "${myPythonEnv.interpreter}"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
        language = "python";
        logo32 = "${myPythonEnv.sitePackages}/ipykernel/resources/logo-32x32.png";
        logo64 = "${myPythonEnv.sitePackages}/ipykernel/resources/logo-64x64.png";
      };
    };
  };

  # ipywidgets needs to have it's notebook argument overridden with
  # myJupyter.  This is so that we don't get collisions when creating
  # myJupyterEnv.
  myIpywidgets = python37.pkgs.ipywidgets.override {
    notebook = myJupyter;
    widgetsnbextension = myWidgetsnbextension;
  };

  # widgetsnbextension needs to have it's notebook argument overridden with
  # myJupyter.  This is so that we don't get collisions when creating
  # myJupyterEnv.
  myWidgetsnbextension = python37.pkgs.widgetsnbextension.override {
    notebook = myJupyter;
    ipywidgets = myIpywidgets;
  };

  # myJupyterEnv is an environment that contains Jupyter and some extensions
  # (like ipywidgets and widgetsnbextension).  Extensions have to be enabled
  # for some things in Jupyter to work.  Also, make sure you trust your
  # Jupyter notebooks, or some things may not work correctly.
  myJupyterEnv = python37.buildEnv.override {
    extraLibs = [
      myJupyter
      myIpywidgets
      myWidgetsnbextension
    ];
  };
in
{
  run-jupyter = writeShellScriptBin "run-jupyter" ''
  # Start the Jupyter notebook and listen on 0.0.0.0.  Delete the `--ip
  # 0.0.0.0` argument if you only want to listen on localhost.
  ${myJupyterEnv}/bin/jupyter-notebook --ip 0.0.0.0
  '';
}
