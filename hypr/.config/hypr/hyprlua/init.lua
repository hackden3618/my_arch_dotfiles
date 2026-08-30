HOME = os.getenv("HOME") or "/home/dennis"

mainMod = "SUPER"
scriptsDir = HOME .. "/.config/hypr/scripts"
UserScripts = HOME .. "/.config/hypr/UserScripts"
UserConfigs = HOME .. "/.config/hypr/hyprconf/UserConfigs"
hyprlua = HOME .. "/.config/hypr/hyprlua"

local function load(path)
    dofile(hyprlua .. "/" .. path)
end

hl.on("hyprland.start", function()
    hl.exec_cmd(HOME .. "/.config/hypr/initial-boot.sh")
    hl.exec_cmd("hyprpm reload -n")
end)

load("configs/Keybinds.lua")

load("configs/Startup_Apps.lua")
load("UserConfigs/Startup_Apps.lua")

load("UserConfigs/ENVariables.lua")

load("UserConfigs/Laptops.lua")
load("UserConfigs/LaptopDisplay.lua")

load("configs/WindowRules.lua")
load("UserConfigs/WindowRules.lua")

load("UserConfigs/UserDecorations.lua")
load("UserConfigs/UserAnimations.lua")
load("UserConfigs/01-UserDefaults.lua")
load("UserConfigs/UserKeybinds.lua")
load("UserConfigs/UserSettings.lua")

-- monitor.lua replaced by auto-sync from monitors.conf (nwg-displays compatible)
local mon = io.open(HOME .. "/.config/hypr/monitors.conf", "r")
if mon then
  for line in mon:lines() do
    local output, mode, pos, scale = line:match("monitor=%s*([^,]+),%s*([^,]+),%s*([^,]+),%s*([^,]+)")
    if output then
      hl.monitor({ output = output, mode = mode, position = pos, scale = scale })
    end
  end
  mon:close()
end

load("workspaces.lua")
load("configs/plugins/hyprexpo.lua")
