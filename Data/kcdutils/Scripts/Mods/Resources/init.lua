---@class KCDUtilsResources
KCDUtils.Resources = KCDUtils.Resources or {}

local function Initialize()
    if not KCDUtils.Resources.initiated then
        KCDUtils.Resources.initiated = true
        System.LogAlways("KCDUtils.Resources: Initializing...")
        local files = {
            "DerivedStats",
            "IntermediateStats",
            "SoulSkills",
            "SoulStates",
            "SoulStats",
            "StaticStats",
        }
        for _, file in ipairs(files) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/Resources/" .. file .. ".lua") end)
            if not status then
                System.LogAlways("Error loading Resources." .. file .. ": " .. tostring(err))
            else
                System.LogAlways("Resources." .. file .. " loaded successfully.")
            end
        end
    end
end

Initialize()