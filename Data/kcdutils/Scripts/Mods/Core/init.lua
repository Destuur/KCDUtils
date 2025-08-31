KCDUtils = KCDUtils or {}

---@class KCDUtilsCore
KCDUtils.Core = KCDUtils.Core or {}

local function Initialize()
    if not KCDUtils.Core.initiated then
        KCDUtils.Core.initiated = true
        System.LogAlways("KCDUtils.Core: Initializing...")
        local entities = {
            "Calendar",
            "Command",
            "Config",
            "DB",
            "Event",
            "Game",
            "Logger",
            "Script",
            "System",
            "UI",
            "Vector",
        }
        for _, entity in ipairs(entities) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/Core/" .. entity .. ".lua") end)
            if not status then
                System.LogAlways("Error loading Core." .. entity .. ": " .. tostring(err))
            else
                System.LogAlways("Core." .. entity .. " loaded successfully.")
            end
        end
    end
end

Initialize()