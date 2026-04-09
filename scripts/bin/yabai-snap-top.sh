#!/bin/bash
YABAI=/run/current-system/sw/bin/yabai
JQ=/Users/pepe/.nix-profile/bin/jq

win=$($YABAI -m query --windows --window)
disp=$($YABAI -m query --displays --display)

win_h=$(echo "$win" | $JQ '.frame.h')
disp_h=$(echo "$disp" | $JQ '.frame.h')

ratio=$(echo "$win_h * 100 / $disp_h" | /usr/bin/bc)

if [ "$ratio" -ge 45 ] && [ "$ratio" -le 55 ]; then
  $YABAI -m window --grid 3:1:0:0:1:2
elif [ "$ratio" -ge 60 ] && [ "$ratio" -le 72 ]; then
  $YABAI -m window --grid 3:1:0:0:1:1
else
  $YABAI -m window --grid 2:1:0:0:1:1
fi
