# 💫 Hyprland Dotfiles (Lua Edition)

A modern, highly customizable, and robust **Hyprland** desktop environment powered by a **Lua-first architecture** (`hyprlua`), integrated with **HyprExpo** overview capabilities, dynamic **Wallust** theming, rich multimedia controls, and touchpad gesture workflows.

---

## 📑 Table of Contents

- [Architecture & Layout](#-architecture--layout)
- [Directory Structure](#-directory-structure)
- [Key Features](#-key-features)
- [Keybindings Cheatsheet](#-keybindings-cheatsheet)
  - [Essential & System](#essential--system)
  - [Window Management](#window-management)
  - [Workspaces & Silent Moving](#workspaces--silent-moving)
  - [Special Workspace (Scratchpad)](#special-workspace-scratchpad)
  - [HyprExpo (Workspace Overview)](#hyprexpo-workspace-overview)
  - [Apps, Menus & Launchers](#apps-menus--launchers)
  - [Screenshots & Multimedia](#screenshots--multimedia)
- [HyprExpo Plugin Setup](#-hyprexpo-plugin-setup)
- [Touchpad & Gesture Controls](#-touchpad--gesture-controls)
- [Customization & Tuning](#-customization--tuning)
  - [Default Applications](#default-applications)
  - [Monitors & Displays](#monitors--displays)
  - [Keyboard Layouts](#keyboard-layouts)
  - [Theming & Wallpapers](#theming--wallpapers)
- [Troubleshooting & Maintenance](#-troubleshooting--maintenance)

---

## 🏗️ Architecture & Layout

This configuration uses Hyprland's native Lua configuration engine. 
- **Entry point**: [`hyprland.lua`](hyprland.lua) loads [`hyprlua/init.lua`](hyprlua/init.lua).
- **Modularity**: Configurations are cleanly partitioned into base/vendor defaults (`hyprlua/configs/`) and user configurations (`hyprlua/UserConfigs/`).
- **Safety**: User edits in `hyprlua/UserConfigs/` persist safely across dotfile upgrades.

---

## 📂 Directory Structure

```text
~/.config/hypr/
├── hyprland.lua                 # Main entry point (loads hyprlua/init.lua)
├── monitors.conf / monitors.lua # Monitor configurations (nwg-displays sync)
├── workspaces.conf / .lua       # Workspace rules
├── initial-boot.sh              # First-boot setup & wallpaper initializer
├── hypridle.conf / hyprlock.conf# Idle daemon & lockscreen styles
│
├── hyprlua/                     # 🌟 Active Lua Configuration Engine
│   ├── init.lua                 # Loads all modular components & start hooks
│   ├── configs/                 # Base presets (Keybinds, Startup, Rules, Plugins)
│   │   ├── Keybinds.lua         # Core navigation, workspace & layout binds
│   │   ├── Startup_Apps.lua     # System daemons (SwayNC, Waybar, Polkit, Cliphist)
│   │   ├── WindowRules.lua      # Default floating & dialog rules
│   │   └── plugins/
│   │       └── hyprexpo.lua     # HyprExpo plugin layout, borders, & styles
│   └── UserConfigs/             # 🛠️ User Override Directory
│       ├── 01-UserDefaults.lua  # Default terminal, file manager, editor
│       ├── UserKeybinds.lua     # Custom hotkeys, app triggers, & plugins
│       ├── UserSettings.lua     # Input, mouse, touchpad, layout settings
│       ├── UserDecorations.lua  # Rounded corners, blur, shadows, Wallust colors
│       ├── UserAnimations.lua   # Animation beziers and transition speeds
│       ├── ENVariables.lua      # Wayland, Qt, GTK, and NVIDIA env vars
│       ├── Laptops.lua          # Clamshell lid and power rules
│       └── WindowRules.lua      # Custom per-app window & layer rules
│
├── scripts/                     # Helper utilities (bar refresh, screenshot, audio, layout)
├── UserScripts/                 # User utilities (wallpaper select/effects, music, calc)
└── wallust/                     # Dynamic color templates and palette configs
```

---

## ✨ Key Features

- **HyprExpo Overview (`sandwichfarm` fork)**: Full workspace grid overview (<kbd>Super</kbd> + <kbd>O</kbd> or 4-finger swipe up) with workspace badges, keyboard navigation, and custom highlight borders.
- **Silent Workspace Dispatch**: Move windows to numbered workspaces, adjacent workspaces, or scratchpad without losing your current focus (<kbd>Super</kbd> + <kbd>Ctrl</kbd> modifiers).
- **Special Workspace (Scratchpad)**: Instant access to a toggleable floating scratchpad (<kbd>Super</kbd> + <kbd>U</kbd>).
- **Dynamic Wallust Palette**: Wallpapers automatically generate color schemes applied to borders, Waybar, Rofi, and terminal.
- **Multi-Layout Support**: Quickly toggle between **Master** and **Dwindle** layouts (<kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd>).
- **Drop-Down Terminal**: Floating Quake-style drop-down terminal (<kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Return</kbd>).
- **Hardware & Desktop Zoom**: Smooth desktop magnifier zoom using touchpad gestures or mouse scroll.

---

## ⌨️ Keybindings Cheatsheet

> Modifier key **`SUPER`** = <kbd>Windows</kbd> / <kbd>Command</kbd>

### Essential & System

| Shortcut | Description |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>Q</kbd> | Close active window |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Q</kbd> | Force kill active process |
| <kbd>Super</kbd> + <kbd>L</kbd> | Lock screen (`hyprlock`) |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>P</kbd> | Power menu (`wlogout`) |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Delete</kbd> | Exit Hyprland |
| <kbd>Super</kbd> + <kbd>H</kbd> | View keybind cheatsheet helper |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>K</kbd> | Search keybinds via Rofi |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>R</kbd> | Refresh Waybar, SwayNC, and desktop components |
| <kbd>Super</kbd> + <kbd>N</kbd> | Toggle night light (Hyprsunset) |

---

### Window Management

| Shortcut | Description |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>Space</kbd> | Toggle floating mode for active window |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>Space</kbd> | Float all windows on active workspace |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd> | Fullscreen toggle |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>F</kbd> | Maximize window |
| <kbd>Super</kbd> + <kbd>G</kbd> | Toggle tabbed window grouping |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Tab</kbd> | Cycle through grouped windows |
| <kbd>Super</kbd> + <kbd>Left / Right / Up / Down</kbd> | Move focus to adjacent window |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>H / L</kbd> | Move focus left / right (Vim style) |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Arrows</kbd> | Move window position |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>Arrows</kbd> | Swap window with neighbor |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Arrows</kbd> | Resize window (-50px / +50px) |
| <kbd>Super</kbd> + <kbd>LMB Drag</kbd> | Move floating window |
| <kbd>Super</kbd> + <kbd>RMB Drag</kbd> | Resize floating window |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd> | Toggle between Master & Dwindle layout |

---

### Workspaces & Silent Moving

| Shortcut | Description |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>1</kbd> .. <kbd>0</kbd> | Switch to workspace 1–10 |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> .. <kbd>0</kbd> | Move window to workspace 1–10 and **follow** focus |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>1</kbd> .. <kbd>0</kbd> | **Move window silently** to workspace 1–10 (stay on current workspace) |
| <kbd>Super</kbd> + <kbd>Tab</kbd> / <kbd>Shift</kbd> + <kbd>Tab</kbd> | Switch to next / previous workspace |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>[</kbd> / <kbd>]</kbd> | Move window to previous / next workspace and follow |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>[</kbd> / <kbd>]</kbd> | **Move window silently** to previous / next workspace |
| <kbd>Super</kbd> + <kbd>Scroll Up / Down</kbd> | Scroll through active workspaces |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>F9 - F12</kbd> | Move workspace to Left / Right / Up / Down monitor |

---

### Special Workspace (Scratchpad)

| Shortcut | Description |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>U</kbd> | **Toggle** Special / Scratchpad workspace overlay |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>U</kbd> | **Move window silently** into the Special workspace (stashes it in background) |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>U</kbd> | Move window to Special workspace and open/focus it |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>U</kbd> | Move focused scratchpad window **out to current workspace** |

---

### HyprExpo (Workspace Overview)

| Shortcut / Trigger | Description |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>O</kbd> | **Toggle 3x3 Workspace Overview grid** |
| **4-Finger Swipe Up** | Open / toggle overview via Touchpad gesture |
| <kbd>Arrow Keys</kbd> | Navigate between workspace tiles in overview |
| <kbd>Escape</kbd> | Close overview without switching |
| <kbd>Left Click Tile</kbd> | Switch directly to the clicked workspace |

---

### Apps, Menus & Launchers

| Shortcut | Description |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>Return</kbd> | Open default terminal (`kitty`) |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Return</kbd> | Drop-down terminal (`Dropterminal.sh`) |
| <kbd>Super</kbd> + <kbd>A</kbd> | Rofi Application Launcher |
| <kbd>Super</kbd> + <kbd>D</kbd> | Anyrun Quick Launcher |
| <kbd>Super</kbd> + <kbd>E</kbd> | File Manager (`nautilus`) |
| <kbd>Super</kbd> + <kbd>B</kbd> | Default Web Browser |
| <kbd>Super</kbd> + <kbd>S</kbd> | Web Search menu |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>S</kbd> | Window switcher menu |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>V</kbd> | Clipboard Manager (`cliphist`) |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>E</kbd> | Emoji picker menu |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>C</kbd> | Quick Calculator |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | KooL Quick Settings menu |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>N</kbd> | SwayNC Notification Panel |

---

### Screenshots & Multimedia

| Shortcut | Description |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>Print</kbd> | Fullscreen screenshot (`hyprshot`) |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Print</kbd> | Area selection screenshot |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>S</kbd> | Screenshot with Swappy editor |
| <kbd>Alt</kbd> + <kbd>Print</kbd> | Active window screenshot |
| <kbd>XF86AudioRaiseVolume / Lower</kbd> | Volume Up / Down (5%) |
| <kbd>XF86AudioMute / MicMute</kbd> | Toggle Speaker / Microphone mute |
| <kbd>XF86AudioPlay / Next / Prev</kbd> | Media Controls (Play/Pause, Next, Prev) |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd> | Rofi Beats (Online Lo-Fi & Radio Streams) |

---

## 🧩 HyprExpo Plugin Setup

The HyprExpo plugin is managed using `hyprpm` and configured via [`hyprlua/configs/plugins/hyprexpo.lua`](hyprlua/configs/plugins/hyprexpo.lua).

### Managing HyprExpo
If you update Hyprland or plugins, run:
```bash
# Update headers & rebuild plugins
hyprpm update

# Enable hyprexpo (if not already enabled)
hyprpm enable hyprexpo

# Reload plugins into Hyprland
hyprpm reload -n
```

### Config Options in `hyprexpo.lua`
```lua
hl.config({
    plugin = {
        hyprexpo = {
            columns = 3,                      -- Number of workspace columns
            gaps_in = 5,                      -- Gaps between preview tiles
            gaps_out = 0,                     -- Outer padding
            bg_col = "rgb(111111)",           -- Grid background color
            workspace_method = "center current",
            gesture_fingers = 4,              -- 4-finger touchpad swipe
            gesture_direction = "up",
            gesture_distance = 200,
            cancel_key = "escape",            -- Close on Escape
            show_cursor = 1,
            keynav_enable = 1,                -- Keyboard arrow selection
            tile_rounding = 8,                -- Corner radius of preview tiles
            border_width = 2,
            border_color_current = "rgb(66ccff)", -- Highlight for active workspace
            border_color_focus   = "rgb(ffcc66)", -- Highlight for keyboard focus
            border_color_hover   = "rgb(aabbcc)", -- Highlight on hover
            label_enable = 1,                 -- Show workspace badges
            label_text_mode = "index",        -- Numbering mode
            label_position = "center",
        },
    },
})
```

---

## 🖐️ Touchpad & Gesture Controls

| Gesture | Action |
| :--- | :--- |
| **3-Finger Swipe Horizontal** | Switch workspaces |
| **3-Finger Swipe Up** | Magnifier Zoom In |
| **3-Finger Swipe Down** | Magnifier Zoom Out |
| **4-Finger Swipe Up** | Toggle **HyprExpo Overview** |
| <kbd>Alt</kbd> + <kbd>T</kbd> | Toggle touchpad On / Off |

---

## 🎨 Customization & Tuning

### Default Applications
Edit [`hyprlua/UserConfigs/01-UserDefaults.lua`](hyprlua/UserConfigs/01-UserDefaults.lua):
```lua
term = "kitty"          -- Terminal emulator
files = "nautilus"      -- File manager
edit = "nvim"           -- Text editor
Search_Engine = "https://www.google.com/search?q={}"
```

### Monitors & Displays
Configured via `nwg-displays` or manually in [`monitors.conf`](monitors.conf) / [`monitors.lua`](monitors.lua):
```lua
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60.01",
    position = "0x0",
    scale = 1.25
})
```

### Keyboard Layouts
Set your layouts in [`hyprlua/UserConfigs/UserSettings.lua`](hyprlua/UserConfigs/UserSettings.lua):
```lua
input = {
    kb_layout = "gb, us",
    repeat_rate = 50,
    repeat_delay = 300,
}
```
- **Switch Globally**: <kbd>Left Alt</kbd> + <kbd>Left Shift</kbd>
- **Switch Per-Window**: <kbd>Left Shift</kbd> + <kbd>Left Alt</kbd>

### Theming & Wallpapers
| Shortcut | Action |
| :--- | :--- |
| <kbd>Super</kbd> + <kbd>W</kbd> | Select Wallpaper from `~/Pictures/wallpapers` |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd> | Apply Wallpaper Effects |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>W</kbd> | Set a Random Wallpaper |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>B</kbd> | Choose Waybar Styles |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>B</kbd> | Choose Waybar Layouts |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>R</kbd> | Rofi Theme Selector |

---

## 🛠️ Troubleshooting & Maintenance

- **Reload Hyprland Config**:
  ```bash
  hyprctl reload
  ```
- **Check Hyprland Runtime Logs**:
  ```bash
  cat $XDG_RUNTIME_DIR/hypr/$(ls $XDG_RUNTIME_DIR/hypr/ | head -1)/hyprland.log | tail -50
  ```
- **Verify Loaded Plugins**:
  ```bash
  hyprctl plugins list
  ```
- **Verify Active Keybinds**:
  ```bash
  hyprctl binds
  ```
- **Update Dots / Components**:
  ```bash
  ~/.config/hypr/scripts/KooLsDotsUpdate.sh
  ```

---

<p align=center>Made with ❤️ for a sleek, efficient, and powerful Hyprland workflow.</p>
