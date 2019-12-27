self: super: {

  metals-emacs =
    let
      baseName = "metals-emacs";
      version = "0.7.6";
      deps = with super; stdenv.mkDerivation {
        name = "${baseName}-deps-${version}";
        buildCommand = ''
        export COURSIER_CACHE=$(pwd)
        ${coursier}/bin/coursier fetch org.scalameta:metals_2.12:${version} > deps
        mkdir -p $out/share/java
        cp $(< deps) $out/share/java/
        '';
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash     = "03vx8n77mndpqbvq14cy3k9r4jwgjacrv56v5n87da8rqiclx37j";
      };
    in
      with super; stdenv.mkDerivation {
        name = "${baseName}-${version}";
        buildInputs = [jdk makeWrapper deps];
        doCheck = true;
        phases = ["installPhase"];
        installPhase = ''
        makeWrapper ${jre}/bin/java $out/bin/${baseName} \
            --add-flags "-Xss4m -Xms100m -Dmetals.client=emacs -cp $CLASSPATH scala.meta.metals.Main"
        '';
      };

  metals-vim = let
    baseName = "metals-vim";
    version = "0.7.6";
    deps = with super; stdenv.mkDerivation {
      name = "${baseName}-deps-${version}";
      buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${coursier}/bin/coursier fetch org.scalameta:metals_2.12:${version} > deps
      mkdir -p $out/share/java
      cp $(< deps) $out/share/java/
      '';
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash     = "03vx8n77mndpqbvq14cy3k9r4jwgjacrv56v5n87da8rqiclx37j";
    };
  in
    with super; stdenv.mkDerivation {
      name = "${baseName}-${version}";
      buildInputs = [jdk makeWrapper deps];
      doCheck = true;
      phases = ["installPhase"];
      installPhase = ''
      makeWrapper ${jre}/bin/java $out/bin/${baseName} \
        --add-flags "-Xss4m -Xms100m -Dmetals.client=coc.nvim -cp $CLASSPATH scala.meta.metals.Main"
      '';
    };



}
