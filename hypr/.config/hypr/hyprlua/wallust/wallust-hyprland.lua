local colors = {
    background = "rgb(171515)",
    foreground = "rgb(FEF3DC)",
    color0 = "rgb(3E3C3C)",
    color1 = "rgb(140F0D)",
    color2 = "rgb(432313)",
    color3 = "rgb(283047)",
    color4 = "rgb(6C454C)",
    color5 = "rgb(A34D3E)",
    color6 = "rgb(BCA774)",
    color7 = "rgb(F5E6C4)",
    color8 = "rgb(ABA189)",
    color9 = "rgb(1B1412)",
    color10 = "rgb(5A2E19)",
    color11 = "rgb(35405F)",
    color12 = "rgb(905C66)",
    color13 = "rgb(D96752)",
    color14 = "rgb(FBDE9A)",
    color15 = "rgb(F5E6C4)",
}

-- Ensure HOME is defined, e.g., local HOME = os.getenv("HOME")
local path = HOME .. "/.config/hypr/wallust/wallust-hyprland.conf"
local file = io.open(path, "r")

if file then
    for line in file:lines() do
        -- Pattern explanation:
        -- ^%s*      : Start of line, optional whitespace
        -- %$        : Literal dollar sign
        -- ([%w_]+)  : Capture group 1: The key (alphanumeric + underscore)
        -- %s*=%s*   : Equals sign with optional surrounding whitespace
        -- (rgb%([^%)]+%) : Capture group 2: The value 'rgb(...)'
        local key, value = line:match("^%s*%$([%w_]+)%s*=%s*(rgb%([^%)]+%))")

        if key and value then
            colors[key] = value
        end
    end
    file:close()
else
    print("Error: Could not open file at " .. path)
end

return colors
