#!/usr/bin/env bash
set -euo pipefail

device="$(hyprctl devices | awk 'tolower($0) ~ /touchpad/ { sub(/^[[:space:]]+/, ""); print; exit }')"

if [[ -z "$device" ]]; then
    notify-send "Touchpad" "No touchpad device found."
    exit 1
fi

state_file="${XDG_RUNTIME_DIR:-/tmp}/caelestia-touchpad-enabled-${HYPRLAND_INSTANCE_SIGNATURE:-$UID}"

current_state="$(cat "$state_file" 2>/dev/null || printf 'true')"

if [[ "$current_state" == "true" ]]; then
    next_state=false
else
    next_state=true
fi

if ! hyprctl keyword "device[$device]:enabled" "$next_state"; then
    notify-send "Touchpad" "Could not change touchpad state."
    exit 1
fi

printf '%s\n' "$next_state" > "$state_file"
if [[ "$next_state" == "true" ]]; then
    notify-send "Touchpad enabled"
else
    notify-send "Touchpad disabled"
fi
