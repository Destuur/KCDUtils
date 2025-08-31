---@class KCDUtilsAPI
KCDUtils.API = KCDUtils.API or {}

local function Initialize()
    if not KCDUtils.API.UIActionInitiated then
        KCDUtils.API.UIActionInitiated = true
        System.LogAlways("KCDUtils.UI: Initializing...")
        local files = {
            "HUD",
        }
        for _, file in ipairs(files) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/API/UIAction/" .. file .. ".lua") end)
            if not status then
                System.LogAlways("Error loading KCDUtils.UI." .. file .. ": " .. tostring(err))
            else
                System.LogAlways("KCDUtils.UI." .. file .. " loaded successfully.")
            end
        end
    end
end

Initialize()