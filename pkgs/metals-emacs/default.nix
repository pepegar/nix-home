{ stdenv, pkgs, ... }:

let
  baseName = "metals-emacs";
  version = "0.7.6";
in
stdenv.mkDerivation {
    name = "${baseName}-${version}";
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)

      ${pkgs.coursier}/bin/coursier bootstrap \
        --java-opt -Xss4m \
        --java-opt -Xms100m \
        --java-opt -Dmetals.client=emacs \
        org.scalameta:metals_2.12:${version} \
        -r bintray:scalacenter/releases \
        -r sonatype:snapshots \
        -o ${baseName} -f

      mkdir -p $out/bin
      mv ${baseName} $out/bin
    '';
}
