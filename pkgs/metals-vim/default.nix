{ stdenv, makeWrapper, coursier, jdk, jre, ... }:

let
  baseName = "metals-vim";
  version = "0.7.6";
  deps = stdenv.mkDerivation {
    name = "${baseName}-deps-${version}";
    buildCommand = ''
    export COURSIER_CACHE=$(pwd)
    ${coursier}/bin/coursier fetch org.scalameta:metals_2.12:${version} > deps
    mkdir -p $out/share/java
    cp $(< deps) $out/share/java/
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash     = "02ra7lvwh4b3d3d56cypi066kgibz5m0pvv3lqa0rffah8h7pyqi";
  };
in
stdenv.mkDerivation {
  name = "${baseName}-${version}";

  buildInputs = [jdk makeWrapper deps];

  doCheck = true;

  phases = ["installPhase"];

  installPhase = ''
  makeWrapper ${jre}/bin/java $out/bin/${baseName} \
    --add-flags "-Xss4m -Xms100m -Dmetals.client=coc.nvim -cp $CLASSPATH scala.meta.metals.Main"
  '';
}
