#!/usr/bin/env bash
set -u

temperature="${1:-3500}"
state_file="${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/night-light"
mkdir -p "$(dirname "$state_file")"

if command -v hyprsunset >/dev/null 2>&1; then
    if [[ -f "$state_file" ]] && [[ "$(<"$state_file")" == "on" ]]; then
        hyprctl hyprsunset identity
        printf 'off\n' > "$state_file"
    elif pgrep -x hyprsunset >/dev/null 2>&1; then
        hyprctl hyprsunset temperature "$temperature"
        printf 'on\n' > "$state_file"
    else
        nohup hyprsunset -t "$temperature" >/dev/null 2>&1 &
        printf 'on\n' > "$state_file"
    fi
    exit 0
fi

if command -v warm-screen >/dev/null 2>&1; then
    if pgrep -x warm-screen >/dev/null 2>&1; then
        pkill -x warm-screen
        printf 'off\n' > "$state_file"
    else
        nohup warm-screen >/dev/null 2>&1 &
        printf 'on\n' > "$state_file"
    fi
    exit 0
fi

notify-send "Night light" "Neither hyprsunset nor warm-screen is installed." 2>/dev/null || true
exit 1
