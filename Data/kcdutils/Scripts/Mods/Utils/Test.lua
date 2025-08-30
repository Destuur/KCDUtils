--- Represents the KCDUtils library
KCDUtils.Test = KCDUtils.Test or {}

--- Initializes the KCDUtils utility modules (nur einmal)
function KCDUtils.Test.Initialize()
    if not KCDUtils.Test.initiated then
        KCDUtils.Test.initiated = true
        System.LogAlways("Test: Initializing...")
        local entities = {
            "Player",
        }
        for _, entity in ipairs(entities) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/Utils/Tests/" .. entity .. ".lua") end)
            if not status then
                System.LogAlways("Error loading KCDUtils." .. entity .. ": " .. tostring(err))
            else
                System.LogAlways("KCDUtils." .. entity .. " loaded successfully.")
            end
        end
    end
end

KCDUtils.Test.Initialize()