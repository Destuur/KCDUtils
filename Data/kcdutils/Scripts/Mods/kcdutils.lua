---@class KCDUtils
---@field Resources KCDUtilsResources
---@field Entities KCDUtilsEntities
---@field Test KCDUtilsTest
---@field API KCDUtilsAPI
---@field Time KCDUtilsTime
---@field Debug KCDUtilsDebug
---@field Table KCDUtilsTable
---@field Math KCDUtilsMath
---@field String KCDUtilsString
---@field UI KCDUtilsUI
KCDUtils = {}

local mods = {}

local function Initialize()
    if not KCDUtils.initiated then
        KCDUtils.initiated = true
        System.LogAlways("KCDUtils: Initializing...")
        ScriptLoader.LoadFolder("Scripts/Mods/KCDUtils")
    end
    System.LogAlways("KCDUtils: Initialization complete.")
end

--- Registers a mod with KCDUtils
---@param mod table
---@return KCDUtilsDB, KCDUtilsLogger
function KCDUtils.RegisterMod(mod)
    local modName = mod.Name
    mods[modName] = mods[modName] or {}

    local db = KCDUtils.DB.Factory(modName)
    local logger = KCDUtils.Logger.Factory(modName)
    System.LogAlways("KCDUtils: Mod " .. tostring(modName) .. " registered.")

    return db, logger
end

Initialize()