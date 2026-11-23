-- Caelestia user preferences.
-- Keep local app choices and key assignments here; Caelestia's defaults live
-- in its own config and remain available when an override is removed.
return {
    -- Match the applications used by the previous Hyprland setup.
    terminal                   = "kitty",
    browser                    = "brave",
    editor                     = "nvim",
    fileExplorer               = "thunar",

    -- Familiar JaKooLit-style shortcuts.
    kbTerminal                 = "SUPER + Return",
    kbBrowser                  = "SUPER + B",
    kbLauncher                 = "SUPER + A",
    kbEmoji                    = "SUPER + ALT + E",
    kbClipboardHistory         = "SUPER + ALT + V",
    kbClipboardDelete          = "SUPER + SHIFT + ALT + V",
    kbClipboardClear           = "SUPER + CTRL + ALT + V",
    kbNightLight               = "SUPER + N",
    kbKillApplication          = "SUPER + SHIFT + Q",
    kbKeyboardLayout           = "SUPER + CTRL + ALT + SPACE",
    kbScreenshot               = "SUPER + Print",
    kbScreenshotFreeze         = "SUPER + SHIFT + S",
    kbScreenshotRegion         = "SUPER + SHIFT + Print",
    kbToggleLayout             = "SUPER + ALT + L",
    kbRestoreLock              = "CTRL + SUPER + ALT + L",
    kbToggleWindowFloating     = "SUPER + Space",
    kbWindowFullscreen         = "SUPER + SHIFT + F",
    kbWindowBorderedFullscreen = "SUPER + CTRL + F",

    -- JaKooLit used U for the special workspace.
    kbSpecialWs                = "SUPER + U",
    kbMoveWinToWsSpecial       = "SUPER + SHIFT + U",
    -- Keep Super+D free while retaining a communication workspace shortcut.
    kbCommunicationWs          = "CTRL + ALT + D",
    kbShowSidebar              = "SUPER + SHIFT + N",

    -- Workspace number bindings are implemented by keybinds/workspaces.lua.
    -- Empty these Caelestia defaults so their built-in bindings do not overlap.
    kbGoToWs                   = "",
    kbMoveWinToWs              = "",
    kbMoveWinToWsSilent        = "",
    kbWorkspace                = "SUPER",
    kbMoveWindowToWorkspace    = "SUPER + SHIFT",
    kbMoveWindowSilent         = "SUPER + CTRL",

    -- Monitor output scaling. Set displayOutput to a monitor name to target one;
    -- empty string applies to the default output rule.
    displayOutput              = "",
    displayScale               = 1.25,
    nightLightTemperature      = 3500,

    -- Layout order used by the Super+Alt+L cycle.
    defaultLayout              = "master",
    layoutCycle                = { "master", "dwindle", "scrolling" },
    masterNewStatus            = "master",
    masterOrientation          = "left",

    -- Decorations
    blurSpecialWs              = true,
    singleWindowGapsOut        = 10,

    -- Populated with the matching hardware name by the Alt+T toggle.
    touchpadDevice             = "",
    touchpadEnabled            = true,
}
