#!/usr/bin/env bash
# Restarts Quickshell (bar, Control Center, notifications, OSD, power menu).
# Colours do NOT need this: the shell watches ~/.config/quickshell/qml_color.json
# and recolours live whenever wallust rewrites it. Use this only after editing
# the QML or if the shell gets stuck.

UserScripts=$HOME/.config/hypr/UserScripts

# ask the running instance to exit; fall back to a plain kill
qs kill >/dev/null 2>&1 || pkill -x qs >/dev/null 2>&1 || pkill -x quickshell >/dev/null 2>&1
sleep 0.3
setsid -f qs >/dev/null 2>&1

# Relaunching rainbow borders if the script exists
sleep 1
if [ -e "${UserScripts}/RainbowBorders.sh" ]; then
  "${UserScripts}/RainbowBorders.sh" &
fi

exit 0
