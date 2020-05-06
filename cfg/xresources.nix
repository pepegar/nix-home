{ pkgs, ... }:

{
  xresources = {
    properties = {
      "URxvt.font" = "xft:PragmataPro Mono:size=12,xft:Symbola,xft:EmojiOne Color,xft:Noto Color Emoji";
      "URxvt*boldFont" = "xft:PragmataPro Mono:size=12,xft:Symbola,xft:EmojiOne Color,xft:Noto Color Emoji";
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
      "URxvt.allow_bold" =           "true";
      "URxvt*boldMode" = "true";
      "URxvt*letterSpace" = "1";
      "URxvt.scrollStyle" = "rxvt";
      "URxvt.scrollBar" = "false";
      "URxvt.cursorBlink" = "false";
      "URxvt.cursorUnderline" = "false";
      "URxvt.pointerBlank" = "false";
      "URxvt*urlLauncher" = "${pkgs.firefox}/bin/firefox";
      "URxvt*matcher.button" = "1";
      "URxvt*matcher.pattern.1" = "\\bwww\\.[\\w-]+\\.[\\w./?&@#-]*[\\w/-]";
    };

    extraConfig = builtins.readFile (
      pkgs.fetchFromGitHub {
        owner = "logico-dev";
        repo = "Xresources-themes";
        rev = "83ac62c07d7acaf8f67bb046a42f35a553a502fd";
        sha256 = "0izcc2frpn2ymnzxzghnl8yza73vkald27al6cpq6agh10ypdkp2";
      } + "/iterm-Molokai.Xresources"
    );

  };

  home.file.".xprofile".text = ''
#!/usr/bin/env sh

${pkgs.rescuetime}/bin/rescuetime &
'';
}
