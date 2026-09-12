#!/usr/bin/env bash
# Generate a local Wallust palette when needed before Waybar loads its CSS.

set -euo pipefail

"$HOME/.config/hypr/scripts/EnsureWallust.sh"

# Start the Hyprland Lua IPC bridge for Waybar if not already active
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  bridge_dir="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}_waybar"
  bridge_pid="${bridge_dir}/bridge.pid"
  is_running=0
  if [ -f "$bridge_pid" ] && kill -0 "$(cat "$bridge_pid" 2>/dev/null)" 2>/dev/null; then
    is_running=1
  fi
  if [ "$is_running" -eq 0 ]; then
    python3 "$HOME/.config/hypr/scripts/HyprIpcBridge.py" --daemon
    for _ in {1..15}; do
      if [ -S "${bridge_dir}/.socket.sock" ]; then
        break
      fi
      sleep 0.1
    done
  fi
  export HYPRLAND_INSTANCE_SIGNATURE="${HYPRLAND_INSTANCE_SIGNATURE}_waybar"
fi

exec waybar "$@"
