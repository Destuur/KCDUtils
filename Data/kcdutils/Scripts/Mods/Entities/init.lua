---@class KCDUtilsEntities
KCDUtils.Entities = KCDUtils.Entities or {}

local function Initialize()
    if not KCDUtils.Entities.initiated then
        KCDUtils.Entities.initiated = true
        System.LogAlways("KCDUtils.Entities: Initializing...")
        local files = {
            "Horse",
            "Player",
        }
        for _, file in ipairs(files) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/Entities/" .. file .. ".lua") end)
            if not status then
                System.LogAlways("Error loading Entities." .. file .. ": " .. tostring(err))
            else
                System.LogAlways("Entities." .. file .. " loaded successfully.")
            end
        end
    end
end

Initialize()