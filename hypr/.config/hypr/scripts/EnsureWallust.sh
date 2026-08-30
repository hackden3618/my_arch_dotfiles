#!/usr/bin/env bash
# Ensure palette files exist before applications import them.

set -euo pipefail

wallpaper="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
rofi_wallpaper="$HOME/.config/rofi/.current_wallpaper"
readonly -a palette_files=(
    "$HOME/.config/hypr/wallust/wallust-hyprland.conf"
    "$HOME/.config/waybar/wallust/colors-waybar.css"
    "$HOME/.config/rofi/wallust/colors-rofi.rasi"
    "$HOME/.config/kitty/kitty-themes/01-Wallust.conf"
)

palette_is_ready() {
    local file
    for file in "${palette_files[@]}"; do
        [[ -s "$file" ]] || return 1
    done

    [[ -L "$rofi_wallpaper" && -e "$rofi_wallpaper" ]]
}

palette_is_ready && exit 0

if [[ ! -s "$wallpaper" ]]; then
    printf '%s\n' "Wallust palette is missing and no current wallpaper is available: $wallpaper" >&2
    exit 1
fi

command -v wallust >/dev/null 2>&1 || {
    printf '%s\n' 'Wallust is required to generate the missing palette files.' >&2
    exit 1
}

mkdir -p "$(dirname "$rofi_wallpaper")"
ln -sfn "$wallpaper" "$rofi_wallpaper"
wallust run -s "$wallpaper"

if ! palette_is_ready; then
    printf '%s\n' 'Wallust completed but one or more palette files are still missing.' >&2
    exit 1
fi
