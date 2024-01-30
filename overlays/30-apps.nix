super: {

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
}
