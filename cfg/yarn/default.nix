{...}: let
  secrets = import ../../secrets.nix;
in {
  home.file.".yarnrc.yml".text = ''
    npmScopes:
        goodnotes:
            npmRegistryServer: 'https://npm.pkg.github.com'
            npmAlwaysAuth: true
            npmAuthToken: '${secrets.goodnotes_GITHUB_PACKAGES_MAVEN_PASS}'
  '';
}
