{ pkgs, ... }:

{
  xresources.properties = {
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
    "URxvt.font" = "xft:PragmataPro Mono Liga:size=12,xft:Symbola,xft:EmojiOne Color,xft:Noto Color Emoji";
    "URxvt*boldFont" = "xft:PragmataPro Mono Liga:size=12,xft:Symbola,xft:EmojiOne Color,xft:Noto Color Emoji";
    "URxvt.allow_bold" =           "true";
    "URxvt*boldMode" = "true";
    "URxvt*letterSpace" = "1";
    "URxvt.scrollStyle" = "rxvt";
    "URxvt.scrollBar" = "false";
    "URxvt.cursorBlink" = "false";
    "URxvt.cursorUnderline" = "false";
    "URxvt.pointerBlank" = "false";
    "urxvt*foreground" = "#F8F8F2";
    "urxvt*background" = "rgba:0040/0042/0054/f0ff";
    "urxvt*color0" = "#000000";
    "urxvt*color8" = "#4D4D4D";
    "urxvt*color1" = "#FF5555";
    "urxvt*color9" = "#FF6E67";
    "urxvt*color2" = "#50FA7B";
    "urxvt*color10" = "#5AF78E";
    "urxvt*color3" = "#F1FA8C";
    "urxvt*color11" = "#F4F99D";
    "urxvt*color4" = "#BD93F9";
    "urxvt*color12" = "#CAA9FA";
    "urxvt*color5" = "#FF79C6";
    "urxvt*color13" = "#FF92D0";
    "urxvt*color6" = "#8BE9FD";
    "urxvt*color14" = "#9AEDFE";
    "urxvt*color7" = "#BFBFBF";
    "urxvt*color15" = "#E6E6E6";
  };
}
