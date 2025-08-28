--- Represents the KCDUtils library
KCDUtils.API = KCDUtils.API or {}

--- Initializes the KCDUtils utility modules (nur einmal)
function KCDUtils.API.Initialize()
    if not KCDUtils.API.initiated then
        KCDUtils.API.initiated = true
        System.LogAlways("KCDUtils: Initializing...")
        local entities = {
            "Player",
        }
        for _, entity in ipairs(entities) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/Utils/API/" .. entity .. ".lua") end)
            if not status then
                System.LogAlways("Error loading KCDUtils." .. entity .. ": " .. tostring(err))
            else
                System.LogAlways("KCDUtils." .. entity .. " loaded successfully.")
            end
        end
    end
end

KCDUtils.API.Initialize()