#!/usr/bin/env bash
set -u

pid="$(hyprctl -j activewindow | jq -r '.pid // empty')"
if [[ ! "$pid" =~ ^[1-9][0-9]*$ || ! -r "/proc/$pid/cmdline" ]]; then
    notify-send "Close application" "No active application process was found." 2>/dev/null || true
    exit 1
fi

IFS= read -r -d '' executable < "/proc/$pid/cmdline" || true
if [[ -z "$executable" ]]; then
    notify-send "Close application" "Could not identify the active application." 2>/dev/null || true
    exit 1
fi

# Escape the argv[0] path for pkill's extended regular expression, then match
# only commands beginning with this exact executable to avoid substring kills.
pattern="$(printf '%s' "$executable" | sed 's/[][\\.^$*+?{}|()]/\\&/g')"
pkill -f -- "^${pattern}([[:space:]]|$)"
