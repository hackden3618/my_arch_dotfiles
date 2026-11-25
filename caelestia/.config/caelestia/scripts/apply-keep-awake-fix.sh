#!/usr/bin/env bash
set -euo pipefail

TARGET="/etc/xdg/quickshell/caelestia/modules/IdleMonitors.qml"
[[ -f "$TARGET" ]] || { echo "Missing Caelestia file: $TARGET" >&2; exit 1; }

if [[ "$EUID" -ne 0 ]]; then
    echo "Run this reviewed script with sudo to patch the root-owned Caelestia file:" >&2
    echo "  sudo $0" >&2
    exit 1
fi

python - "$TARGET" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
if "Services.IdleInhibitor.enabled" in text:
    print("Keep-awake idle fix is already applied.")
    raise SystemExit(0)

replacements = [
    ("import qs.services\n", "import qs.services as Services\n"),
    ("readonly property bool hasPlayer: Players.list.some(p => p.isPlaying)",
     "readonly property bool hasPlayer: Services.Players.list.some(p => p.isPlaying)"),
    ("    readonly property bool enabled: {\n        if (GlobalConfig.general.idle.inhibitWhenAudio && hasPlayer)",
     "    readonly property bool enabled: {\n        if (Services.IdleInhibitor.enabled)\n            return false;\n        if (GlobalConfig.general.idle.inhibitWhenAudio && hasPlayer)"),
    ("Hypr.dispatch(Hypr.usingLua && [\"dpms off\", \"dpms on\"].includes(action)",
     "Services.Hypr.dispatch(Services.Hypr.usingLua && [\"dpms off\", \"dpms on\"].includes(action)"),
]
for old, new in replacements:
    if text.count(old) != 1:
        raise SystemExit(f"Expected exactly one source match, found {text.count(old)}: {old!r}")
    text = text.replace(old, new, 1)

backup = path.with_suffix(path.suffix + ".caelestia-backup")
if not backup.exists():
    backup.write_text(path.read_text())
path.write_text(text)
print("Applied Caelestia keep-awake idle monitor fix.")
PY
