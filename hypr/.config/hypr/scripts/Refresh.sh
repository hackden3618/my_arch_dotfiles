#!/usr/bin/env bash
# Refresh helper. Called by wallpaper, dark/light and game-mode scripts.
#
# Quickshell does NOT need restarting for a new wallpaper or palette: it watches
# ~/.config/quickshell/qml_color.json and recolours live. So by default this
# only relaunches rainbow borders. Pass --restart (SUPER+ALT+R) to also restart
# the shell, e.g. after editing the QML.

UserScripts=$HOME/.config/hypr/UserScripts

if [ "${1:-}" = "--restart" ]; then
  qs kill >/dev/null 2>&1 || pkill -x qs >/dev/null 2>&1 || pkill -x quickshell >/dev/null 2>&1
  sleep 0.3
  setsid -f qs >/dev/null 2>&1
  sleep 1
fi

# Relaunching rainbow borders if the script exists
if [ -e "${UserScripts}/RainbowBorders.sh" ]; then
  "${UserScripts}/RainbowBorders.sh" &
fi

exit 0
