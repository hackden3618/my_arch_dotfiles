#!/usr/bin/env bash
# Cycle the active keyboard layout on every connected keyboard.
set -euo pipefail

notif_icon="$HOME/.config/swaync/images/ja.png"
mapfile -t keyboards < <(hyprctl devices -j | jq -r '.keyboards[].name')

if ((${#keyboards[@]} == 0)); then
    notify-send -u low -t 2000 'Keyboard layout' 'No keyboards found.'
    exit 1
fi

for keyboard in "${keyboards[@]}"; do
    hyprctl switchxkblayout "$keyboard" next
done

notify-send -u low -i "$notif_icon" 'Keyboard layout' 'Switched to the next layout.'
