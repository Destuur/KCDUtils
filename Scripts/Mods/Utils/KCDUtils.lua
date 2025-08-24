KCDUtils = KCDUtils or {}
KCDUtils.Mods = KCDUtils.Mods or {}

local mods = KCDUtils.Mods

function KCDUtils.Init(modname)

    mods[modname] = mods[modname] or {}

    local utils = {
        "Buff",
        "Config",
        "DB",
        "Debug",
        "Events",
        "Input",
        "Logger",
        "Math",
        "Path",
        "Perk",
        "Player",
        "Quest",
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
