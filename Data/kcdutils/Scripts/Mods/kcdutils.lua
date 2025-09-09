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
KCDUtils = KCDUtils or {}
KCDUtils.Name = KCDUtils.Name or "KCDUtils"
KCDUtils.RegisteredMods = KCDUtils.RegisteredMods or {} 

local function Initialize()
    if not KCDUtils.initiated then
        KCDUtils.initiated = true
        System.LogAlways(KCDUtils.Name .. ": Initializing...")
        ScriptLoader.LoadFolder("Scripts/Mods/" .. KCDUtils.Name)
    end
    KCDUtils.Events.RegisterOnGameplayStarted(KCDUtils)
    System.LogAlways(KCDUtils.Name .. ": Initialization complete.")
end

-- --- Registers a mod with KCDUtils
-- ---@param mod table
-- -- ---@return KCDUtilsDB, KCDUtilsLogger
-- ---@return KCDUtilsLogger
-- function KCDUtils.RegisterMod(mod)
--     local modName = mod.Name
--     KCDUtils.RegisteredMods[modName] = true   -- 👈 jetzt wird es in der globalen Liste gespeichert

--     -- local db = KCDUtils.DB.Factory(modName)
--     -- local logger = KCDUtils.Logger.Factory(modName)
--     -- System.LogAlways(KCDUtils.Name .. ": Mod " .. tostring(modName) .. " registered.")

--     local logger = KCDUtils.Logger.Factory(modName)
--     System.LogAlways(KCDUtils.Name .. ": Mod " .. tostring(modName) .. " registered.")

--     return logger
-- end

function KCDUtils.OnGameplayStarted()
    local logger = KCDUtils.Logger.Factory(KCDUtils.Name)
    logger:Info("OnGameplayStarted triggered")

    -- Alle Mods re-initialisieren
    for modName, modTable in pairs(KCDUtils.RegisteredMods) do
        if type(modTable.Init) == "function" then
            logger:Info("Re-initializing mod: " .. modName)
            modTable.Init()
        end
    end

    -- WatchLoop reload-sicher starten
    if KCDUtils.Events.watchLoopRunning then
        KCDUtils.Events.watchLoopRunning = false
    end
    KCDUtils.Events.WatchLoop()

    -- Fire OnGameplayStarted Event
    KCDUtils.Events.GameplayStarted.Fire()
end

-- ============================================================
-- Mod-Registration
-- ============================================================
--- Registers a mod with KCDUtils
---@param mod table
---@return KCDUtilsDB, KCDUtilsLogger
function KCDUtils.RegisterMod(mod)
    local modName = mod.Name
    mod._listeners = mod._listeners or {}   -- Jede Mod speichert ihre eigenen Listener

    KCDUtils.RegisteredMods[modName] = mod

    local logger = KCDUtils.Logger.Factory(modName)
    local db = KCDUtils.DB.Factory(modName)
    System.LogAlways(KCDUtils.Name .. ": Mod " .. tostring(modName) .. " registered.")

    return db, logger
end

-- ============================================================================ 
-- Mod Wrapper (Reload-sicher)
-- ============================================================================

function KCDUtils.RegisterModCallbacks(mod)
    mod._listeners = mod._listeners or {}

    -- Alte Listener entfernen
    for _, subEntry in pairs(mod._listeners) do
        if subEntry.subscription and subEntry.eventTable and subEntry.eventTable.Remove then
            subEntry.eventTable.Remove(subEntry.subscription)
        end
    end
    mod._listeners = {}

    local function wrapper()
        if type(mod.OnGameplayStarted) == "function" then
            -- Aktuelles Aufrufen
            mod.OnGameplayStarted()

            -- AddSafe würde hier die neuen Listener automatisch tracken:
            -- Beispiel: AddSafe(mod, eventTable, config, callback)
        end
    end

    KCDUtils.Events.GameplayStarted.Set(mod.Name, wrapper)
end

-- Helper für table.find (einfach)
function table.find(tbl, val)
    for i,v in ipairs(tbl) do if v==val then return i end end
    return nil
end


Initialize()