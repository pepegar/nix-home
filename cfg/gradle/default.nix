{...}: let
  secrets = import ../../secrets.nix;
in {
  home.file.".gradle/gradle.properties".text = ''
    githubPackagesMavenUser=${secrets.goodnotes_GITHUB_PACKAGES_MAVEN_USER}
    githubPackagesMavenPass=${secrets.goodnotes_GITHUB_PACKAGES_MAVEN_PASS}
  '';
}
