---@class KCDUtilsAPI
KCDUtils.API = KCDUtils.API or {}

--- Initializes the KCDUtils utility modules (nur einmal)
function KCDUtils.API.Initialize()
    if not KCDUtils.API.initiated then
        KCDUtils.API.initiated = true
        System.LogAlways("KCDUtils.API: Initializing...")
        local entities = {
            "Core",
            "Game",
            "Math",
            "Player",
            "SafeCall",
            "Timer",
            "UI",
            "World",
        }
        for _, entity in ipairs(entities) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/API/" .. entity .. ".lua") end)
            if not status then
                System.LogAlways("Error loading API." .. entity .. ": " .. tostring(err))
            else
                System.LogAlways("API." .. entity .. " loaded successfully.")
            end
        end
    end
end

KCDUtils.API.Initialize()