local vars = require("hypr-vars")
local editor = vars.editor or "nvim"

-- Keep terminal file managers and other child processes on the configured editor.
hl.env("EDITOR", editor)
hl.env("VISUAL", editor)
