#!/usr/bin/env bash
set -euo pipefail

vars_file="$HOME/.config/caelestia/hypr-vars.lua"
devices="$(hyprctl -j devices)"
configured_device="$(sed -nE 's/^[[:space:]]*touchpadDevice[[:space:]]*=[[:space:]]*"([^"]*)".*/\1/p' "$vars_file" | head -n1)"

if [[ -n "$configured_device" ]] && jq -e --arg name "$configured_device" \
    '.mice[]? | select(.name == $name)' >/dev/null <<< "$devices"; then
    device="$configured_device"
else
    device="$(jq -r '[.mice[]? | select((.name // "") | test("touchpad"; "i")) | .name] | first // empty' <<< "$devices")"
fi

if [[ -z "$device" ]]; then
    notify-send "Touchpad" "No touchpad device found."
    exit 1
fi

current_state="$(sed -nE 's/^[[:space:]]*touchpadEnabled[[:space:]]*=[[:space:]]*(true|false).*/\1/p' "$vars_file" | head -n1)"
if [[ "$current_state" != "true" && "$current_state" != "false" ]]; then
    notify-send "Touchpad" "touchpadEnabled is missing from hypr-vars.lua."
    exit 1
fi

if [[ "$current_state" == "true" ]]; then
    next_state=false
else
    next_state=true
fi

python3 - "$vars_file" "$device" "$next_state" <<'PY'
import json
import os
import re
import sys
from pathlib import Path

path = Path(sys.argv[1]).resolve()
device = sys.argv[2]
enabled = sys.argv[3]
text = path.read_text()
text, device_count = re.subn(
    r'(?m)^(\s*touchpadDevice\s*=\s*)"[^"]*"(\s*,?)$',
    lambda match: f"{match.group(1)}{json.dumps(device)}{match.group(2)}",
    text,
    count=1,
)
text, enabled_count = re.subn(
    r'(?m)^(\s*touchpadEnabled\s*=\s*)(?:true|false)(\s*,?)$',
    lambda match: f"{match.group(1)}{enabled}{match.group(2)}",
    text,
    count=1,
)
if device_count != 1 or enabled_count != 1:
    raise SystemExit("touchpadDevice/touchpadEnabled entries were not found in hypr-vars.lua")

temporary = path.with_suffix(path.suffix + ".tmp")
temporary.write_text(text)
temporary.chmod(path.stat().st_mode & 0o777)
os.replace(temporary, path)
PY

if ! hyprctl reload; then
    notify-send "Touchpad" "State saved, but Hyprland reload failed."
    exit 1
fi

if [[ "$next_state" == "true" ]]; then
    notify-send "Touchpad enabled"
else
    notify-send "Touchpad disabled"
fi
