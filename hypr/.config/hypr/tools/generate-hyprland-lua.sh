#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hyprconf="$root/hyprconf"
out="$root/hyprland.lua"

files=(
  "$root/hyprland.conf"
  "$hyprconf/configs/Keybinds.conf"
  "$hyprconf/configs/Startup_Apps.conf"
  "$hyprconf/UserConfigs/Startup_Apps.conf"
  "$hyprconf/UserConfigs/ENVariables.conf"
  "$hyprconf/UserConfigs/Laptops.conf"
  "$hyprconf/UserConfigs/LaptopDisplay.conf"
  "$hyprconf/configs/WindowRules.conf"
  "$hyprconf/UserConfigs/WindowRules.conf"
  "$root/wallust/wallust-hyprland.conf"
  "$hyprconf/UserConfigs/UserDecorations.conf"
  "$hyprconf/UserConfigs/UserAnimations.conf"
  "$hyprconf/UserConfigs/01-UserDefaults.conf"
  "$hyprconf/UserConfigs/UserKeybinds.conf"
  "$hyprconf/UserConfigs/UserSettings.conf"
  "$root/monitors.conf"
  "$hyprconf/workspaces.conf"
  "$hyprconf/configs/plugins/hyprexpo.conf"
  "$root/hyprland-gui.conf"
)

awk -f "$root/tools/hyprconf_to_lua.awk" "${files[@]}" > "$out"
echo "Generated $out"
