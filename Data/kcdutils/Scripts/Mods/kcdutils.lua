--- Represents the KCDUtils library
KCDUtils = KCDUtils or {}
KCDUtils.Mods = KCDUtils.Mods or {}

local mods = KCDUtils.Mods

--- Initializes the KCDUtils utility modules (nur einmal)
function KCDUtils.Initialize()
    if not KCDUtils.initiated then
        KCDUtils.initiated = true
        System.LogAlways("KCDUtils: Initializing...")
        local utils = {
            "Command",
            "Config",
            "DB",
            "Debug",
            "Entities",
            "Event",
            "Input",
            "Logger",
            "Math",
            "Path",
            "Resources",
            "Safe",
            "Script",
            "String",
            "System",
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
end

--- Registers a mod with KCDUtils
---@param modname string
function KCDUtils.RegisterMod(modname)
    mods[modname] = mods[modname] or {}
    System.LogAlways("KCDUtils: Mod registered: " .. tostring(modname))
end

KCDUtils.Initialize()