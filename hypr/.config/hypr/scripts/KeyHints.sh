#!/usr/bin/env bash
# The everyday map of this Hyprland setup. Keep this in step with active binds.

set -u

if pgrep -f 'Hyprland guide — Super + H' >/dev/null; then
    pkill -f 'Hyprland guide — Super + H'
    exit 0
fi

exec yad --center --title="Hyprland guide — Super + H" --window-icon=preferences-desktop \
    --width=1040 --height=760 --no-buttons --list --search-column=2 \
    --column="Area" --column="Shortcut" --column="What it does" --column="Notes" \
    "Start here" "Super + H or Ctrl + H" "Open or close this guide" "Super is the Windows / Command key" \
    "Start here" "Super + Shift + K" "Search every configured keybinding" "Best when you know the action but not the key" \
    "Start here" "Super + A" "Open the app launcher" "Search apps, files, commands, and windows" \
    "Start here" "Super + Return" "Open terminal" "Default: kitty" \
    "Start here" "Super + E" "Open file manager" "Default: Nautilus" \
    "Start here" "Super + O" "Open workspace overview" "Also: four-finger swipe up" \
    "Windows" "Super + Q" "Close the focused window" "Normal close request" \
    "Windows" "Super + Shift + Q" "Force-close the focused process" "Use only when an app will not close" \
    "Windows" "Super + arrows" "Focus the window in that direction" "Super + Shift + H/L also focuses left/right" \
    "Windows" "Super + Ctrl + arrows" "Move the focused window" "Moves the window position" \
    "Windows" "Super + Alt + arrows" "Swap with neighbouring window" "" \
    "Windows" "Super + Shift + arrows" "Resize focused window" "50 px per press" \
    "Windows" "Super + Space" "Toggle floating for focused window" "" \
    "Windows" "Super + Alt + Space" "Float every window on this workspace" "" \
    "Windows" "Super + Shift + F / Ctrl + F" "Fullscreen / maximize focused window" "" \
    "Windows" "Super + G / Ctrl + Tab" "Toggle tabbed group / cycle group" "" \
    "Windows" "Super + mouse drag" "Move or resize a floating window" "Left drag moves; right drag resizes" \
    "Windows" "Alt + Tab" "Cycle windows" "" \
    "Windows" "Super + Alt + L" "Switch Master / Dwindle layout" "" \
    "Windows" "Super + I / Ctrl + D" "Add / remove master window" "Master layout" \
    "Windows" "Super + Ctrl + Return" "Swap focused window with master" "Master layout" \
    "Windows" "Super + P" "Toggle pseudo tiling" "Dwindle layout" \
    "Windows" "Super + M" "Set split ratio to 0.3" "" \
    "Workspaces" "Super + 1 … 0" "Go to workspace 1 … 10" "Number-row keys work across keyboard layouts" \
    "Workspaces" "Super + Shift + 1 … 0" "Move window to workspace and follow it" "" \
    "Workspaces" "Super + Ctrl + 1 … 0" "Move window silently to workspace" "You stay where you are" \
    "Workspaces" "Super + Tab / Shift + Tab" "Next / previous workspace" "" \
    "Workspaces" "Super + [ / Shift + ]" "Move window to previous / next workspace" "Follows the window" \
    "Workspaces" "Super + Ctrl + [ / ]" "Move window silently to previous / next workspace" "" \
    "Workspaces" "Super + scroll / . / ," "Next / previous workspace" "" \
    "Workspaces" "Super + U / Shift + U" "Show scratchpad / send window to scratchpad" "" \
    "Workspaces" "Super + Ctrl + F9 … F12" "Move current workspace to another monitor" "Left, right, up, down" \
    "Launch & search" "Super + D" "Open Anyrun quick launcher" "" \
    "Launch & search" "Super + B / S / Ctrl + S" "Browser / web search / window switcher" "" \
    "Launch & search" "Super + Shift + Return" "Open drop-down terminal" "" \
    "Launch & search" "Super + Alt + V / E / C" "Clipboard / emoji / calculator" "" \
    "Launch & search" "Super + Shift + M" "Open online music / radio menu" "" \
    "Desktop" "Super + Shift + E / N" "Quick settings / notification centre" "" \
    "Desktop" "Super + N" "Toggle night light" "" \
    "Desktop" "Super + Alt + R" "Refresh Waybar and desktop menus" "" \
    "Desktop" "Super + Ctrl + Alt + B" "Hide or show Waybar" "" \
    "Desktop" "Super + Ctrl + B / Alt + B" "Choose Waybar style / layout" "" \
    "Desktop" "Super + Alt + O / Ctrl + O" "Toggle blur / focused-window opacity" "" \
    "Desktop" "Super + Shift + G / A" "Toggle game mode / choose animations" "" \
    "Desktop" "Super + Ctrl + R / Ctrl + Shift + R" "Choose Rofi theme / modified theme" "" \
    "Wallpapers" "Super + W" "Choose wallpaper" "Updates the Wallust palette" \
    "Wallpapers" "Super + Shift + W / Ctrl + Alt + W" "Wallpaper effects / random wallpaper" "" \
    "Screenshots" "Super + Print" "Capture current monitor" "Saves to Pictures/Screenshots" \
    "Screenshots" "Super + Shift + Print" "Capture a selected area" "" \
    "Screenshots" "Super + Ctrl + Print / Ctrl + Shift + Print" "Capture after 5 / 10 seconds" "" \
    "Screenshots" "Alt + Print / Super + Shift + S" "Focused window / capture with Swappy editor" "" \
    "Laptop & media" "Volume, mute, and media keys" "Audio and playback controls" "" \
    "Laptop & media" "Brightness keys" "Adjust display or keyboard brightness" "Laptop-specific; needs matching hardware" \
    "Laptop & media" "Alt + T" "Toggle touchpad" "" \
    "Laptop & media" "Alt + Shift" "Switch keyboard layout" "Global or per-window depending on key order" \
    "Laptop & media" "Super + Alt + scroll" "Zoom desktop in or out" "" \
    "System" "Super + L" "Lock screen" "" \
    "System" "Ctrl + Alt + P" "Open power menu" "" \
    "System" "Ctrl + Alt + Delete" "Exit Hyprland" "Ends the current session immediately" \
    "System" "Power / sleep / airplane media keys" "Power, suspend, and airplane mode" "If your keyboard exposes those keys" \
    "Touchpad" "Three-finger horizontal swipe" "Change workspace" "" \
    "Touchpad" "Three-finger up / down" "Zoom desktop in / out" "" \
    "Touchpad" "Four-finger swipe up" "Open workspace overview" ""
