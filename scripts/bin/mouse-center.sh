#!/bin/bash
# Move mouse cursor to the center of the next display (cycles through displays)

osascript -e "
use framework \"AppKit\"
use framework \"CoreGraphics\"

set screens to current application's NSScreen's screens()
set screenCount to count of screens

-- Get current mouse position
set mouseLocation to current application's NSEvent's mouseLocation()
set mouseX to (mouseLocation's x) as real
set mouseY to (mouseLocation's y) as real

-- Get main screen height for coordinate conversion
set mainScreen to item 1 of screens
set mainFrame to mainScreen's frame()
set mainHeight to (item 2 of item 2 of mainFrame) as real

-- Find which screen the mouse is currently on
set currentScreenIndex to 1
repeat with i from 1 to screenCount
    set screen to item i of screens
    set frame to screen's frame()
    set originX to (item 1 of item 1 of frame) as real
    set originY to (item 2 of item 1 of frame) as real
    set screenWidth to (item 1 of item 2 of frame) as real
    set screenHeight to (item 2 of item 2 of frame) as real

    if mouseX >= originX and mouseX < (originX + screenWidth) and mouseY >= originY and mouseY < (originY + screenHeight) then
        set currentScreenIndex to i
        exit repeat
    end if
end repeat

-- Calculate next screen index (wrap around)
set nextScreenIndex to currentScreenIndex + 1
if nextScreenIndex > screenCount then
    set nextScreenIndex to 1
end if

-- Get the next screen and calculate its center
set targetScreen to item nextScreenIndex of screens
set frame to targetScreen's frame()
set originX to (item 1 of item 1 of frame) as real
set originY to (item 2 of item 1 of frame) as real
set screenWidth to (item 1 of item 2 of frame) as real
set screenHeight to (item 2 of item 2 of frame) as real

set centerX to originX + (screenWidth / 2)
-- Flip Y coordinate: convert from bottom-left origin to top-left origin
set centerY to mainHeight - originY - screenHeight + (screenHeight / 2)

current application's CGWarpMouseCursorPosition({centerX, centerY})
"
