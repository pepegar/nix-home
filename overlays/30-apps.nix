self: super:
{

  installApplication =
    {name, appName ? name, version, src, description, homepage, postInstall ? "", sourceRoot ? "", ...}:
    with super; stdenv.mkDerivation {
      name = "${name}-${version}";
      version = "${version}";
      src = src;
      buildInputs = [undmg unzip];
      sourceRoot = sourceRoot;
      phases = ["unpackPhase" "installPhase"];
      installPhase = ''
      mkdir -p "$out/Applications/${appName}.app"
      cp -pR * "$out/Applications/${appName}.app"
    '' + postInstall;
      meta = with stdenv.lib; {
        description = description;
        homepage = homepage;
        maintainers = with maintainers; [];
        platforms = platforms.darwin;
      };
    };

  Anki = self.installApplication rec {
    name = "Anki";
    version = "2.1.14";
    sourceRoot = "Anki.app";
    src = super.fetchurl {
      url = "https://apps.ankiweb.net/downloads/current/anki-${version}-mac.dmg";
      sha256 = "0xizsq75dws08x6q7zss2rik9rd6365w1y2haa08hqnjzkf7yb8x";
      # date = 2019-01-23T15:42:49-0800;
    };
    description = "Anki is a program which makes remembering things easy";
    homepage = https://apps.ankiweb.net;
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
    homepage = https://lunadisplay.com/;
  };

  Docker = self.installApplication rec {
    name = "Docker";
    version = "2.1.0.4";
    sourceRoot = "Docker.app";
    src = super.fetchurl {
      url = https://download.docker.com/mac/stable/Docker.dmg;
      sha256 = "06g3s7igf0rxsybwas13df78cphqkg4kflnr53y6gcj10vq7jlsl";
    };
    description = ''
    Docker CE for Mac is an easy-to-install desktop app for building,
    debugging, and testing Dockerized apps on a Mac
  '';
    homepage = https://store.docker.com/editions/community/docker-ce-desktop-mac;
  };

  Dash = self.installApplication rec {
    name = "Dash";
    version = "4.6.7";
    sourceRoot = "Dash.app";
    src = super.fetchurl {
      url = https://kapeli.com/downloads/v4/Dash.zip;
      sha256 = "1dizd4mmmr3vrqa5x4pdbyy0g00d3d5y45dfrh95zcj5cscypdg2";
    };
    description = "Dash is an API Documentation Browser and Code Snippet Manager";
    homepage = https://kapeli.com/dash;
  };

  iTerm2 = self.installApplication rec {
    name = "iTerm2";
    appname = "iTerm";
    version = "3.3.6";
    sourceRoot = "iTerm.app";
    src = super.fetchurl {
      url = "https://iterm2.com/downloads/stable/iTerm2-3_3_6.zip";
      sha256 = "0wsklsq0gasi58blzk4da3iii92rdhj4sz0jilcilxklk5961zii";
    };
    description = "iTerm2 is a replacement for Terminal and the successor to iTerm";
    homepage = https://www.iterm2.com;
  };

  Tunnelblick = self.installApplication rec {
    name = "Tunnelblick";
    version = "3.8.1";
    sourceRoot = "Tunnelblick.app";
    src = super.fetchurl {
      url = https://tunnelblick.net/release/Tunnelblick_3.8.1_build_5400.dmg;
      sha256 = "a619a1c01a33a8618fc2489a43241e95c828dcdb7f7c56cfc883dcbb22644693";
    };
    description = "free software for OpenVPN on macOS";
    homepage = https://tunnelblick.net;
  };
}
