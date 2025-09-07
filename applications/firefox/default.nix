{pkgs, ...}: {
  home = {
    sessionVariables.BROWSER = "firefox";
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      name = "Default";
      settings = {
        "browser.warnOnQuit" = true;
        "browser.tabs.loadInBackground" = true;
        "widget.gtk.rounded-bottom-corners.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
      };
      extensions.packages = with pkgs.nur.repos.rycee; [
        firefox-addons.duckduckgo-privacy-essentials
        firefox-addons.onepassword-password-manager
        firefox-addons.surfingkeys
        firefox-addons.tree-style-tab
        firefox-addons.multi-account-containers
        firefox-addons.privacy-badger
        firefox-addons.ublock-origin
        firefox-addons.greasemonkey
      ];
      userChrome = ''
        #TabsToolbar { visibility: collapse; }
      '';
      search = {
        force = true;
        default = "ddg";
        engines = {
          "Github (nix)" = {
            definedAliases = [
              "@ghnix"
              "@githubnix"
            ];
            urls = [
              {
                template = "https://github.com/search?q={searchTerms}+language%3ANix";
                params = [
                  {
                    name = "type";
                    value = "code";
                  }
                ];
              }
            ];
          };
          "Github" = {
            definedAliases = [
              "@gh"
              "@github"
            ];
            urls = [
              {
                template = "https://github.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                  {
                    name = "type";
                    value = "code";
                  }
                ];
              }
            ];
          };
          "Home Manager Options" = {
            definedAliases = [
              "@homemanager"
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                  {
                    name = "release";
                    value = "master";
                  }
                ];
              }
            ];
          };
          "wikipedia".metaData.alias = "@wiki";
          "google".metaData.hidden = true;
          "amazondotcom-us".metaData.hidden = true;
          "bing".metaData.hidden = true;
          "ebay".metaData.hidden = true;
        };
      };
    };
  };
}
