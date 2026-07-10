#!/usr/bin/env bash

set -euo pipefail

GENERATED="$HOME/.config/hypr/hyprlua/Generated/Touchpad.lua"

mkdir -p "$(dirname "$GENERATED")"

DEVICE=$(
    hyprctl -j devices \
    | jq -r '.mice[]
        | select(.name | test("touchpad"; "i"))
        | .name' \
    | head -n1
)

if [[ -z "$DEVICE" ]]; then
    notify-send "Touchpad" "No touchpad found."
    exit 1
fi

CURRENT=true

if [[ -f "$GENERATED" ]]; then
    CURRENT=$(
        grep 'enabled =' "$GENERATED" \
        | grep -oE 'true|false'
    )
fi

if [[ "$CURRENT" == "true" ]]; then
    NEW=false
else
    NEW=true
fi

cat > "$GENERATED" <<EOF
hl.device({
    name = "$DEVICE",
    enabled = $NEW,
})
EOF

hyprctl reload

notify-send "Touchpad" "$([[ $NEW == true ]] && echo Enabled || echo Disabled)"
