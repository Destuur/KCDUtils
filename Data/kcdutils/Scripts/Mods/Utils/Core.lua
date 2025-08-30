--- Represents the KCDUtils library
KCDUtils.Core = KCDUtils.Core or {}

--- Initializes the KCDUtils utility modules (nur einmal)
function KCDUtils.Core.Initialize()
    if not KCDUtils.Core.initiated then
        KCDUtils.Core.initiated = true
        System.LogAlways("Core: Initializing...")
        local entities = {
            "Command",
            "Config",
            "DB",
            "Event",
            "Logger",
            "Script",
            "System",
            "UI",
        }
        for _, entity in ipairs(entities) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/Utils/Core/" .. entity .. ".lua") end)
            if not status then
                System.LogAlways("Error loading KCDUtils." .. entity .. ": " .. tostring(err))
            else
                System.LogAlways("KCDUtils." .. entity .. " loaded successfully.")
            end
        end
    end
end

KCDUtils.Core.Initialize()