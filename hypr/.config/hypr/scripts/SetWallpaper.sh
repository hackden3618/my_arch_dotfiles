#!/usr/bin/env bash
# Set the desktop wallpaper and synchronize every local consumer of it.
# Set WALLPAPER_BACKEND to "awww" or "swww" to override auto-detection.
# Usage: SetWallpaper.sh [--start-daemon|--stop-daemon]
#        SetWallpaper.sh /absolute/path/to/image [transition options...]

set -euo pipefail

wallpaper_current="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
rofi_link="$HOME/.config/rofi/.current_wallpaper"

select_backend() {
    case "${WALLPAPER_BACKEND:-}" in
        awww)
            command -v awww >/dev/null && command -v awww-daemon >/dev/null || return 1
            backend="awww"
            ;;
        swww)
            command -v swww >/dev/null && command -v swww-daemon >/dev/null || return 1
            backend="swww"
            ;;
        "")
            if command -v awww >/dev/null && command -v awww-daemon >/dev/null; then
                backend="awww"
            elif command -v swww >/dev/null && command -v swww-daemon >/dev/null; then
                backend="swww"
            else
                return 1
            fi
            ;;
        *) return 1 ;;
    esac
}

start_daemon() {
    local daemon="${backend}-daemon"
    if ! pgrep -x "$daemon" >/dev/null; then
        "$daemon" --format xrgb >/dev/null 2>&1 &
        for _ in {1..20}; do
            pgrep -x "$daemon" >/dev/null && break
            sleep 0.05
        done
    fi
}

select_backend || {
    printf '%s\n' 'No supported wallpaper backend found. Install awww or swww.' >&2
    exit 1
}

case "${1:-}" in
    --start-daemon)
        start_daemon
        exit 0
        ;;
    --stop-daemon)
        "$backend" kill
        exit 0
        ;;
esac

wallpaper_path="${1:-}"
shift || true
if [[ -z "$wallpaper_path" || ! -f "$wallpaper_path" ]]; then
    printf 'Usage: %s /absolute/path/to/image [transition options...]\n' "$0" >&2
    exit 2
fi

start_daemon
"$backend" img "$@" "$wallpaper_path"

mkdir -p "$(dirname "$wallpaper_current")" "$(dirname "$rofi_link")"
cp -f "$wallpaper_path" "$wallpaper_current"
ln -sfn "$wallpaper_current" "$rofi_link"
wallust run -s "$wallpaper_current"
hyprctl reload >/dev/null 2>&1 || true
