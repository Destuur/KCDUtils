---@class KCDUtils
---@field Resources KCDUtilsResources
---@field Entities KCDUtilsEntities
---@field Core KCDUtilsCore
---@field Test KCDUtilsTest
---@field API KCDUtilsAPI
---@field Time KCDUtilsTime
---@field Debug KCDUtilsDebug
---@field Table KCDUtilsTable
---@field Math KCDUtilsMath
---@field String KCDUtilsString
KCDUtils = {}

local mods = {}

local function Initialize()
    if not KCDUtils.initiated then
        KCDUtils.initiated = true
        System.LogAlways("KCDUtils: Initializing...")
        local folders = {
            "API",
            "Core",
            "Entities",
            "Resources",
            -- "Test",
            "Utils",
        }
        for _, folder in ipairs(folders) do
            local status, err = pcall(function() Script.ReloadScript("Scripts/Mods/" .. folder .. "/init.lua") end)
            if not status then
                System.LogAlways("Error loading KCDUtils." .. folder .. ": " .. tostring(err))
            else
                System.LogAlways("KCDUtils." .. folder .. " loaded successfully.")
            end
        end
    end
    System.LogAlways("KCDUtils: Initialization complete.")
end

--- Registers a mod with KCDUtils
---@param mod table
---@return KCDUtilsCoreDB, KCDUtilsCoreLogger, KCDUtilsCoreConfig
function KCDUtils.RegisterMod(mod)
    local modName = mod.Name
    mods[modName] = mods[modName] or {}

    local db = KCDUtils.Core.DB.Factory(modName)
    local logger = KCDUtils.Core.Logger.Factory(modName)
    local config = KCDUtils.Core.Config.Factory(modName)

    return db, logger, config
end

Initialize()