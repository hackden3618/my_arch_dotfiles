#!/usr/bin/env bash
set -euo pipefail

hypr="$HOME/.config/hypr"
lua="$hypr/hyprlua"
rofi_theme="$HOME/.config/rofi/config-edit.rasi"
terminal="${DEFAULT_TERMINAL:-kitty}"
editor="${DEFAULT_EDITOR:-${EDITOR:-nvim}}"

declare -A files=(
    ["User defaults"]="$lua/UserConfigs/01-UserDefaults.lua"
    ["Environment"]="$lua/UserConfigs/ENVariables.lua"
    ["Window rules"]="$lua/UserConfigs/WindowRules.lua"
    ["User keybinds"]="$lua/UserConfigs/UserKeybinds.lua"
    ["User settings"]="$lua/UserConfigs/UserSettings.lua"
    ["Startup apps"]="$lua/UserConfigs/Startup_Apps.lua"
    ["Decorations"]="$lua/UserConfigs/UserDecorations.lua"
    ["Animations"]="$lua/UserConfigs/UserAnimations.lua"
    ["Laptop controls"]="$lua/UserConfigs/Laptops.lua"
    ["Core keybinds"]="$lua/configs/Keybinds.lua"
    ["Monitor layout"]="$hypr/monitors.lua"
    ["Workspace rules"]="$lua/workspaces.lua"
)

actions=$(printf '%s\n' \
    'User defaults' 'Environment' 'Window rules' 'User keybinds' \
    'User settings' 'Startup apps' 'Decorations' 'Animations' \
    'Laptop controls' 'Core keybinds' 'Monitor layout' 'Workspace rules' \
    'Choose Kitty theme' 'Choose Hyprland animations' 'Choose monitor profile' \
    'Choose Rofi theme' 'Search keybinds' 'GTK settings' 'Qt settings' \
    'Toggle game mode' 'Switch dark/light theme')

choice=$(printf '%s\n' "$actions" | rofi -i -dmenu -config "$rofi_theme" \
    -mesg 'Edit Lua configuration or open a desktop setting')
[[ -n "$choice" ]] || exit 0

if [[ -n "${files[$choice]:-}" ]]; then
    "$terminal" -e "$editor" "${files[$choice]}"
    exit 0
fi

case "$choice" in
    'Choose Kitty theme') "$hypr/scripts/Kitty_themes.sh" ;;
    'Choose Hyprland animations') "$hypr/scripts/Animations.sh" ;;
    'Choose monitor profile') "$hypr/scripts/MonitorProfiles.sh" ;;
    'Choose Rofi theme') "$hypr/scripts/RofiThemeSelector.sh" ;;
    'Search keybinds') "$hypr/scripts/KeyBinds.sh" ;;
    'GTK settings') command -v nwg-look >/dev/null && nwg-look || notify-send 'Settings' 'Install nwg-look to edit GTK settings.' ;;
    'Qt settings') command -v qt6ct >/dev/null && qt6ct || notify-send 'Settings' 'Install qt6ct to edit Qt settings.' ;;
    'Toggle game mode') "$hypr/scripts/GameMode.sh" ;;
    'Switch dark/light theme') "$hypr/scripts/DarkLight.sh" ;;
esac
