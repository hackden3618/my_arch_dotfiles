local vars = require("variables")

hl.bind(
    vars.kbClipboardHistory,
    hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/caelestia/scripts/clipboard-history.sh")
)
