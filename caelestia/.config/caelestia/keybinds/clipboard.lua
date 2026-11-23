local vars = require("variables")

hl.bind(
    vars.kbClipboardHistory,
    hl.dsp.exec_cmd("caelestia clipboard")
)

hl.bind(vars.kbClipboardDelete, hl.dsp.exec_cmd("caelestia clipboard --delete"))
hl.bind(vars.kbClipboardClear, hl.dsp.exec_cmd("cliphist wipe"))
