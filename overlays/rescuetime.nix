self: super:

{
  rescuetime = super.rescuetime.overrideAttrs (oldAttrs: {
    version = "2.14.5.2";
    src = super.fetchurl {
      url = "https://www.rescuetime.com/installers/rescuetime_current_amd64.deb";
      sha256 = "1a6pc8vi2ab721kzyhvg6bmw24dr85dgmx2m9j9vbf3jyr85fv10";
    };
  });
}
