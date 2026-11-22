#!/usr/bin/env bash
set -euo pipefail

terminal="${DEFAULT_TERMINAL:-kitty}"
file_manager="${DEFAULT_FILE_MANAGER:-thunar}"

case "${1:-}" in
    --btop) "$terminal" --title btop sh -c 'btop' ;;
    --nvtop) "$terminal" --title nvtop sh -c 'nvtop' ;;
    --nmtui) "$terminal" -e nmtui ;;
    --term) "$terminal" & ;;
    --files) "$file_manager" & ;;
    *)
        printf 'Usage: %s [--btop | --nvtop | --nmtui | --term | --files]\n' "$0" >&2
        exit 2
        ;;
esac
