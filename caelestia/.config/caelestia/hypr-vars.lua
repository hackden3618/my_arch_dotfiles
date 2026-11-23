-- Caelestia user preferences.
-- Keep local app choices and key assignments here; Caelestia's defaults live
-- in its own config and remain available when an override is removed.
return {
    -- Match the applications used by the previous Hyprland setup.
    terminal     = "kitty",
    browser      = "brave",
    editor       = "nvim",
    fileExplorer = "thunar",

    -- Familiar JaKooLit-style shortcuts.
    kbTerminal             = "SUPER + Return",
    kbBrowser              = "SUPER + B",
    kbLauncher             = "SUPER + A",
    kbEmoji                = "SUPER + ALT + E",
    kbClipboardHistory     = "SUPER + ALT + V",
    kbScreenshot           = "SUPER + Print",
    kbScreenshotFreeze     = "SUPER + SHIFT + S",
    kbToggleLayout         = "SUPER + ALT + L",
    kbRestoreLock          = "CTRL + SUPER + ALT + L",
    kbToggleWindowFloating = "SUPER + Space",
    kbWindowFullscreen     = "SUPER + SHIFT + F",
    kbWindowBorderedFullscreen = "SUPER + CTRL + F",

    -- JaKooLit used U for the special workspace.
    kbSpecialWs        = "SUPER + U",
    kbMoveWinToWsSpecial = "SUPER + SHIFT + U",
    -- Keep Super+D free while retaining a communication workspace shortcut.
    kbCommunicationWs  = "CTRL + ALT + D",

    -- Layout order used by the Super+Alt+L cycle.
    defaultLayout = "master",
    layoutCycle   = { "master", "dwindle", "scrolling" },
    masterNewStatus = "master",
    masterOrientation = "left",

    -- Populated with the matching hardware name by the Alt+T toggle.
    touchpadDevice  = "",
    touchpadEnabled = true,
}
