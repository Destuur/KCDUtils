---@class KCDUtilsTest
KCDUtils.Test = KCDUtils.Test or {}

local function Initialize()
    if not KCDUtils.Test.initiated then
        KCDUtils.Test.initiated = true
        System.LogAlways("KCDUtils.Test: Initializing...")
        local files = {
            "Player",
        }
        for _, file in ipairs(files) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/Test/" .. file .. ".lua") end)
            if not status then
                System.LogAlways("Error loading Test." .. file .. ": " .. tostring(err))
            else
                System.LogAlways("Test." .. file .. " loaded successfully.")
            end
        end
    end
end

Initialize()