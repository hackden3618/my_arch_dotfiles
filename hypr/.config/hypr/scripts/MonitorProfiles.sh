#!/usr/bin/env bash
#!/usr/bin/env bash
set -euo pipefail

profiles="$HOME/.config/hypr/hyprlua/Monitor_Profiles"
target="$HOME/.config/hypr/monitors.lua"
rofi_theme="$HOME/.config/rofi/config-Monitors.rasi"

chosen=$(find "$profiles" -maxdepth 1 -type f -name '*.lua' -printf '%f\n' \
    | sed 's/\.lua$//' | sort -V | rofi -i -dmenu -config "$rofi_theme" \
        -mesg 'Choose a Lua monitor profile')
[[ -n "$chosen" ]] || exit 0

cp -- "$profiles/$chosen.lua" "$target"
hyprctl reload
notify-send -u low "$chosen" 'Hyprland monitor profile loaded'
