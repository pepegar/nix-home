self: super:

{
  rescuetime = super.rescuetime.overrideAttrs (oldAttrs: {
    version = "2.14.5.2";
    src = super.fetchurl {
      url = "https://www.rescuetime.com/installers/rescuetime_current_amd64.deb";
    };
  });
}
