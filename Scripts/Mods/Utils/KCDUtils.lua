--- Represents the KCDUtils library
KCDUtils = KCDUtils or {}
KCDUtils.Mods = KCDUtils.Mods or {}

local mods = KCDUtils.Mods

--- Initializes the KCDUtils library by loading all utility modules.
--- @param modname string The name of the mod
function KCDUtils.Init(modname)

    mods[modname] = mods[modname] or {}

    local utils = {
        "Config",
        "DB",
        "Debug",
        "Events",
        "Input",
        "Logger",
        "Math",
        "Path",
        "Player",
        "Safe",
        "String",
        "Table",
        "Time",
        "UI",
        "Version",
    }

    for _, util in ipairs(utils) do
        local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/Utils/" .. util .. ".lua") end)
        if not status then
            System.LogAlways("Error loading KCDUtils." .. util .. ": " .. tostring(err))
        else
            System.LogAlways("KCDUtils." .. util .. " loaded successfully.")
        end
    end
end