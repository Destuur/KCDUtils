--- Represents the KCDUtils library
KCDUtils.Entities = KCDUtils.Entities or {}

--- Initializes the KCDUtils utility modules (nur einmal)
function KCDUtils.Entities.Initialize()
    if not KCDUtils.Entities.initiated then
        KCDUtils.Entities.initiated = true
        System.LogAlways("KCDUtils: Initializing...")
        local entities = {
            "Horse",
            "Player",
            "Player.Actor",
            "Player.Human",
            "Player.Soul",
        }
        for _, entity in ipairs(entities) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/Utils/Entities/" .. entity .. ".lua") end)
            if not status then
                System.LogAlways("Error loading KCDUtils." .. entity .. ": " .. tostring(err))
            else
                System.LogAlways("KCDUtils." .. entity .. " loaded successfully.")
            end
        end
    end
end

KCDUtils.Entities.Initialize()