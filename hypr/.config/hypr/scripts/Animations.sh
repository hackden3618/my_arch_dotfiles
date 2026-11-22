#!/usr/bin/env bash
#!/usr/bin/env bash
set -euo pipefail

animations_dir="$HOME/.config/hypr/hyprlua/animations"
target="$HOME/.config/hypr/hyprlua/UserConfigs/UserAnimations.lua"
rofi_theme="$HOME/.config/rofi/config-Animations.rasi"

chosen=$(find "$animations_dir" -maxdepth 1 -type f -name '*.lua' -printf '%f\n' \
    | sed 's/\.lua$//' | sort -V | rofi -i -dmenu -config "$rofi_theme" \
        -mesg 'Choose a Lua animation profile')
[[ -n "$chosen" ]] || exit 0

cp -- "$animations_dir/$chosen.lua" "$target"
hyprctl reload
notify-send -u low "$chosen" 'Hyprland animation profile loaded'
