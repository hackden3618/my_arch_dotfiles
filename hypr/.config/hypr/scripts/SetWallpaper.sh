#!/usr/bin/env bash
# Set the desktop wallpaper and synchronize every local consumer of it.
# Usage: SetWallpaper.sh /absolute/path/to/image [awww transition options...]

set -euo pipefail

wallpaper_path="${1:-}"
shift || true

wallpaper_current="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
rofi_link="$HOME/.config/rofi/.current_wallpaper"

if [[ -z "$wallpaper_path" || ! -f "$wallpaper_path" ]]; then
    printf 'Usage: %s /absolute/path/to/image [awww options...]\n' "$0" >&2
    exit 2
fi

command -v awww >/dev/null 2>&1 || {
    printf '%s\n' 'awww is required to set wallpapers.' >&2
    exit 1
}

if ! pgrep -x awww-daemon >/dev/null; then
    awww-daemon --format xrgb >/dev/null 2>&1 &
    for _ in {1..20}; do
        pgrep -x awww-daemon >/dev/null && break
        sleep 0.05
    done
fi

# Keep Awww options before the image path, matching its documented CLI form.
awww img "$@" "$wallpaper_path"

mkdir -p "$(dirname "$wallpaper_current")" "$(dirname "$rofi_link")"
cp -f "$wallpaper_path" "$wallpaper_current"
ln -sfn "$wallpaper_current" "$rofi_link"
wallust run -s "$wallpaper_current"
hyprctl reload >/dev/null 2>&1 || true
