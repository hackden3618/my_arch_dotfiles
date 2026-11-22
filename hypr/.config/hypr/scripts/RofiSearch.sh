#!/usr/bin/env bash
# Search the configured provider from Rofi and open the result in the browser.
set -euo pipefail

search_engine="${SEARCH_ENGINE:-https://www.google.com/search?q={}}"
rofi_theme="$HOME/.config/rofi/config-search.rasi"
msg='Search the web with your default browser'

if pgrep -x rofi >/dev/null; then
    pkill rofi
fi

query=$(printf '' | rofi -dmenu -config "$rofi_theme" -mesg "$msg")
[[ -z "$query" ]] && exit 0

encoded=$(jq -rn --arg query "$query" '$query | @uri')
url="${search_engine/\{\}/$encoded}"
xdg-open "$url"
