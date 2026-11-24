-- User keybinds are split by purpose so each group can be edited independently.
local configDir = os.getenv("HOME") .. "/.config/caelestia"
package.path = configDir .. "/?.lua;" .. configDir .. "/?/init.lua;" .. package.path

require("keybinds.apps")
require("keybinds.navigation")
require("keybinds.system")
require("keybinds.layouts")
require("keybinds.wallpaper")
require("keybinds.clipboard")
require("keybinds.workspaces")
require("keybinds.systemExtras")
require("inputs.display")
require("inputs.keyboard")
require("inputs.environment")
