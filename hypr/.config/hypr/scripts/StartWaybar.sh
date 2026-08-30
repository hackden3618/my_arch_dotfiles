#!/usr/bin/env bash
# Generate a local Wallust palette when needed before Waybar loads its CSS.

set -euo pipefail

"$HOME/.config/hypr/scripts/EnsureWallust.sh"
exec waybar "$@"
