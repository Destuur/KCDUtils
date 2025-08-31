---@type KCDUtils
KCDUtils = KCDUtils or {}

local function Initialize()
    if not KCDUtils.initiated then
        KCDUtils.initiated = true
        System.LogAlways("KCDUtils: Initializing...")
        local files = {
            "Debug",
            "Math",
            "String",
            "Table",
            "Time",
        }
        for _, file in ipairs(files) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/Utils/" .. file .. ".lua") end)
            if not status then
                System.LogAlways("Error loading KCDUtils." .. file .. ": " .. tostring(err))
            else
                System.LogAlways("KCDUtils." .. file .. " loaded successfully.")
            end
        end
    end
end

Initialize()