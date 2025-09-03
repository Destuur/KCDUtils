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
---@field Events KCDUtilsEvents
---@field Name string
KCDUtils = { Name = "KCDUtils" }

local mods = {}

local function Initialize()
    if not KCDUtils.initiated then
        KCDUtils.initiated = true
        System.LogAlways(KCDUtils.Name .. ": Initializing...")
        ScriptLoader.LoadFolder("Scripts/Mods/" .. KCDUtils.Name)
    end
    KCDUtils.Events.RegisterOnGameplayStarted(KCDUtils)
    System.LogAlways(KCDUtils.Name .. ": Initialization complete.")
end

--- Registers a mod with KCDUtils
---@param mod table
---@return KCDUtilsDB, KCDUtilsLogger
function KCDUtils.RegisterMod(mod)
    local modName = mod.Name
    mods[modName] = mods[modName] or {}

    local db = KCDUtils.DB.Factory(modName)
    local logger = KCDUtils.Logger.Factory(modName)
    System.LogAlways(KCDUtils.Name .. ": Mod " .. tostring(modName) .. " registered.")

    return db, logger
end

function KCDUtils.OnGameplayStarted()
    local logger = KCDUtils.Logger.Factory(KCDUtils.Name)
    logger:Info("Starting WatchLoop")
    Script.SetTimer(1000, KCDUtils.Events.WatchLoop) -- bind self!
end

Initialize()