#!/bin/bash
YABAI=/run/current-system/sw/bin/yabai
JQ=/Users/pepe/.nix-profile/bin/jq

win=$($YABAI -m query --windows --window)
disp=$($YABAI -m query --displays --display)

win_w=$(echo "$win" | $JQ '.frame.w')
disp_w=$(echo "$disp" | $JQ '.frame.w')

ratio=$(echo "$win_w * 100 / $disp_w" | /usr/bin/bc)

if [ "$ratio" -ge 45 ] && [ "$ratio" -le 55 ]; then
  $YABAI -m window --grid 1:3:1:0:2:1
elif [ "$ratio" -ge 60 ] && [ "$ratio" -le 72 ]; then
  $YABAI -m window --grid 1:3:2:0:1:1
else
  $YABAI -m window --grid 1:2:1:0:1:1
fi
