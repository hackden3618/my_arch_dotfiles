local vars = require("variables")

hl.monitor({
    output = vars.displayOutput or "",
    mode = "preferred",
    position = "auto",
    scale = vars.displayScale or 1,
})
