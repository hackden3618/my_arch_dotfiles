#!/usr/bin/env bash
set -euo pipefail

rofi_theme="$HOME/.config/rofi/config-keybinds.rasi"
bind_data=$(hyprctl binds -j)
menu=''

while IFS=$'\t' read -r mask key description dispatcher argument; do
    [[ -n "$description" ]] || continue
    mask=$((mask))
    modifiers=()
    ((mask & 64)) && modifiers+=(SUPER)
    ((mask & 8)) && modifiers+=(ALT)
    ((mask & 4)) && modifiers+=(CTRL)
    ((mask & 1)) && modifiers+=(SHIFT)
    combo=$(IFS=+; printf '%s' "${modifiers[*]}")
    [[ -z "$combo" ]] || combo+="+"
    detail="$combo$key — $description"
    [[ -z "$dispatcher" ]] || detail+=" — $dispatcher"
    [[ -z "$argument" ]] || detail+=" $argument"
    menu+="$detail"$'\n'
done < <(jq -r '.[] | select((.description // "") != "") |
    [.modmask // 0, .key // .keycode // "?", .description, .dispatcher // "", .arg // ""] | @tsv' <<<"$bind_data")

if [[ -z "$menu" ]]; then
    notify-send 'Keybinds' 'Hyprland did not return any described keybinds.'
    exit 1
fi

printf '%s' "$menu" | rofi -i -dmenu -config "$rofi_theme" \
    -mesg 'Search configured Hyprland keybinds' >/dev/null
