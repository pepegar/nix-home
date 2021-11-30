self: super: {

  installApplication = { name, appName ? name, version, src, description
    , homepage, postInstall ? "", sourceRoot ? "", ... }:
    with super;
    stdenv.mkDerivation {
      name = "${name}-${version}";
      version = "${version}";
      src = src;
      buildInputs = [ undmg unzip ];
      sourceRoot = sourceRoot;
      phases = [ "unpackPhase" "installPhase" ];
      installPhase = ''
        mkdir -p "$out/Applications/${appName}.app"
        cp -pR * "$out/Applications/${appName}.app"
      '' + postInstall;
      meta = with lib; {
        description = description;
        homepage = homepage;
        maintainers = with maintainers; [ ];
        platforms = platforms.darwin;
      };
    };

  Anki = self.installApplication rec {
    name = "Anki";
    version = "2.1.14";
    sourceRoot = "Anki.app";
    src = super.fetchurl {
      url =
        "https://apps.ankiweb.net/downloads/current/anki-${version}-mac.dmg";
      sha256 = "0xizsq75dws08x6q7zss2rik9rd6365w1y2haa08hqnjzkf7yb8x";
      # date = 2019-01-23T15:42:49-0800;
    };
    description = "Anki is a program which makes remembering things easy";
    homepage = "https://apps.ankiweb.net";
  };

  LunaDisplay = self.installApplication rec {
    name = "LunaDisplay";
    version = "4.0.3";
    sourceRoot = "Luna Display.app";
    src = super.fetchurl {
      url = "https://s3.lunadisplay.com/downloads/LunaDisplay.dmg";
      sha256 = "1kyvhic9qzbv9z053qa3fbp2s04j6ij027fafvvadhw7hby2axbs";
    };
    description = "Turn any Mac or iPad into a second display";
    homepage = "https://lunadisplay.com/";
  };

  Dash = self.installApplication rec {
    name = "Dash";
    version = "4.6.7";
    sourceRoot = "Dash.app";
    src = super.fetchurl {
      url = "https://kapeli.com/downloads/v4/Dash.zip";
      sha256 = "1dizd4mmmr3vrqa5x4pdbyy0g00d3d5y45dfrh95zcj5cscypdg2";
    };
    description =
      "Dash is an API Documentation Browser and Code Snippet Manager";
    homepage = "https://kapeli.com/dash";
  };

  Rectangle = self.installApplication rec {
    name = "Rectangle";
    version = "0.46";
    sourceRoot = "Rectangle.app";
    src = super.fetchurl {
      url =
        "https://github.com/rxhanson/Rectangle/releases/download/v${version}/Rectangle${version}.dmg";
      sha256 = "1cjj5pnzf463z20h0h8bzfvpix5sn4bxf3k9xqhl2h6xlzi2qwyk";
    };
    description = "free software for OpenVPN on macOS";
    homepage = "https://tunnelblick.net";
  };
}
