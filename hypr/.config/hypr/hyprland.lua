HOME = os.getenv("HOME") or "/home/" .. (os.getenv("USER") or "user")

dofile(HOME .. "/.config/hypr/hyprlua/init.lua")
