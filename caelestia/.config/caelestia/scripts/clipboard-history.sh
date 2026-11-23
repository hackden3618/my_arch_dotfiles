#!/usr/bin/env bash
# Rofi interface for the cliphist history captured by Caelestia's collectors.
set -u

rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"
message='CTRL+Delete: delete entry    ALT+Delete: wipe history'

if ! command -v cliphist >/dev/null || ! command -v rofi >/dev/null || ! command -v wl-copy >/dev/null; then
    notify-send "Clipboard" "Install cliphist, rofi, and wl-clipboard to use clipboard history."
    exit 1
fi

if pgrep -x rofi >/dev/null 2>&1; then
    pkill -x rofi
    exit 0
fi

while true; do
    result=$(rofi -i -dmenu \
        -kb-custom-1 "Control-Delete" \
        -kb-custom-2 "Alt-Delete" \
        -config "$rofi_theme" \
        -mesg "$message" < <(cliphist list))
    status=$?

    case "$status" in
        1) exit 0 ;;
        0)
            [[ -z "$result" ]] && continue
            cliphist decode <<< "$result" | wl-copy
            exit 0
            ;;
        10) cliphist delete <<< "$result" ;;
        11) cliphist wipe ;;
        *) exit "$status" ;;
    esac
done
