#!/usr/bin/env bash

# Toggle a centered Kitty terminal on the focused monitor.
set -euo pipefail

readonly terminal_class="dotfiles-drop-terminal"
readonly workspace_name="dropterm"
readonly width_percent=65
readonly height_percent=65
command -v hyprctl >/dev/null
command -v jq >/dev/null

get_terminal_address() {
    hyprctl clients -j | jq -r --arg class "$terminal_class" \
        '[.[] | select(.class == $class)] | first | .address // empty'
}

center_terminal() {
    local address="$1" monitor
    monitor=$(hyprctl monitors -j | jq -cer '.[] | select(.focused)')

    local mon_x mon_y logical_width logical_height width height x y scale
    mon_x=$(jq -r '.x' <<<"$monitor")
    mon_y=$(jq -r '.y' <<<"$monitor")
    scale=$(jq -r '.scale' <<<"$monitor")
    logical_width=$(jq -r --argjson scale "$scale" '(.width / $scale) | floor' <<<"$monitor")
    logical_height=$(jq -r --argjson scale "$scale" '(.height / $scale) | floor' <<<"$monitor")
    width=$((logical_width * width_percent / 100))
    height=$((logical_height * height_percent / 100))
    x=$((mon_x + (logical_width - width) / 2))
    y=$((mon_y + (logical_height - height) / 2))

    hyprctl dispatch resizewindowpixel "exact $width $height,address:$address" >/dev/null
    hyprctl dispatch movewindowpixel "exact $x $y,address:$address" >/dev/null
}

address=$(get_terminal_address)

if [[ -z "$address" ]]; then
    # Kitty's class gives us a stable handle even if other Kitty windows exist.
    hyprctl dispatch exec "[float; workspace special:$workspace_name silent] kitty --class $terminal_class" >/dev/null

    for _ in {1..40}; do
        sleep 0.1
        address=$(get_terminal_address)
        [[ -n "$address" ]] && break
    done

    if [[ -z "$address" ]]; then
        notify-send "Drop terminal" "Kitty did not open. Check that Kitty is installed."
        exit 1
    fi

    center_terminal "$address"
    hyprctl dispatch togglespecialworkspace "$workspace_name" >/dev/null
    hyprctl dispatch focuswindow "address:$address" >/dev/null
    exit 0
fi

# A special workspace's name in the focused monitor tells us if it is visible.
visible_workspace=$(hyprctl monitors -j | jq -r \
    '.[] | select(.focused) | .specialWorkspace.name // empty')

if [[ "$visible_workspace" == "special:$workspace_name" ]]; then
    hyprctl dispatch togglespecialworkspace "$workspace_name" >/dev/null
else
    center_terminal "$address"
    hyprctl dispatch togglespecialworkspace "$workspace_name" >/dev/null
    hyprctl dispatch focuswindow "address:$address" >/dev/null
fi
