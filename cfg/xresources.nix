{ pkgs, ... }:

{
  home.file.".xprofile".source = ./xresources/xprofile;
  xresources = {
    properties = {
      "URxvt.modifier" = "mod1";
      "URxvt*loginShell" = "true";
      "URxvt*depth" = "32";
      "URxvt.borderless" = "true";
      "URxvt*dynamicColors" = "on";
      "URxvt.geometry" = "90x20";
      "URxvt.internalBorder" = "20";
      "URxvt.lineSpace" = "1";
      "URxvt.saveLines" = "20000";
      "URxvt*termName" = "xterm-256color";
      "URxvt.transparent" = "false";
      "URxvt.visualBell" = "false";
      "URxvt.iso14755" = "false";
      "URxvt.iso14755_52" =          "false";
      "URxvt.font" = "xft:PragmataPro Mono:size=12,xft:Symbola,xft:EmojiOne Color,xft:Noto Color Emoji";
      "URxvt*boldFont" = "xft:PragmataPro Mono:size=12,xft:Symbola,xft:EmojiOne Color,xft:Noto Color Emoji";
      "URxvt.allow_bold" =           "true";
      "URxvt*boldMode" = "true";
      "URxvt*letterSpace" = "1";
      "URxvt.scrollStyle" = "rxvt";
      "URxvt.scrollBar" = "false";
      "URxvt.cursorBlink" = "false";
      "URxvt.cursorUnderline" = "false";
      "URxvt.pointerBlank" = "false";
    };

    extraConfig = builtins.readFile (
      pkgs.fetchFromGitHub {
        owner = "solarized";
        repo = "xresources";
        rev = "025ceddbddf55f2eb4ab40b05889148aab9699fc";
        sha256 = "0lxv37gmh38y9d3l8nbnsm1mskcv10g3i83j0kac0a2qmypv1k9f";
      } + "/Xresources.dark"
    );

  };
}
