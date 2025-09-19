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

local loggers = setmetatable({}, { __mode = "k" })
local dbs     = setmetatable({}, { __mode = "k" })
local on_hooks    = setmetatable({}, { __mode = "k" })
local on_handlers = setmetatable({}, { __mode = "k" })

local function wrapSubscription(eventTable, subscription)
    if not subscription then return nil end
    return setmetatable({
        _eventTable = eventTable,
        _subscription = subscription
    }, {
        __index = {
            Pause = function(self)
                if self._subscription then self._subscription.isPaused = true end
            end,
            Resume = function(self)
                if self._subscription then self._subscription.isPaused = false end
            end,
            Remove = function(self)
                if self._subscription and self._eventTable then
                    self._eventTable.Remove(self._subscription)
                    self._subscription = nil
                end
            end
        }
    })
end

local meta_on_handler = {}

function meta_on_handler.__index(mod, key)
    if key == "Add" then
        return function(_, eventName, fn, config)
            local eventTable = KCDUtils.Events[eventName]
            if not eventTable then return nil end
            on_hooks[mod] = on_hooks[mod] or {}
            local subscription = eventTable.Add(config or {}, fn)
            on_hooks[mod][eventName] = { subscription = subscription, callback = fn }
            return wrapSubscription(eventTable, subscription)
        end
    end

    on_hooks[mod] = on_hooks[mod] or {}
    local hook = on_hooks[mod][key]
    if hook then
        return wrapSubscription(KCDUtils.Events[key], hook.subscription)
    end
    return nil
end

function meta_on_handler.__newindex(mod, key, val)
    local eventTable = KCDUtils.Events[key]
    if not eventTable then
        local logger = KCDUtils.Logger.Factory(mod.Name or "UnknownMod")
        logger:Error("Tried to bind to unknown event: " .. tostring(key))
        return
    end

    on_hooks[mod] = on_hooks[mod] or {}
    local current = on_hooks[mod][key]

    if val == nil and current then
        eventTable.Remove(current.subscription)
        on_hooks[mod][key] = nil
        return
    end

    if current then
        eventTable.Remove(current.subscription)
        on_hooks[mod][key] = nil
    end

    if type(val) == "function" then
        local subscription = eventTable.Add({}, val)
        on_hooks[mod][key] = { subscription = subscription, callback = val }
    end
end

local function setupOnHandler(mod)
    if on_handlers[mod] then return on_handlers[mod] end
    on_hooks[mod] = on_hooks[mod] or {}
    local handler = setmetatable({}, meta_on_handler)
    on_handlers[mod] = handler
    return handler
end

--- @return KCDUtils*mod
function KCDUtils.RegisterMod(nameOrTable)
    local mod = type(nameOrTable) == "table" and nameOrTable or { Name = nameOrTable }
    local modName = mod.Name or "UnnamedMod"

    KCDUtils.RegisteredMods[modName] = mod
    System.LogAlways(KCDUtils.Name .. ": Mod " .. modName .. " registered.")

    loggers[mod] = KCDUtils.Logger.Factory(modName)
    dbs[mod]     = KCDUtils.DB.Factory(modName)

    KCDUtils.Events[modName] = KCDUtils.Events[modName] or {}
    mod.Events = KCDUtils.Events[modName]

    mod._listeners = mod._listeners or {}

    setmetatable(mod, {
        __index = function(tbl, key)
            if key == "Logger" then return loggers[tbl] end
            if key == "DB"     then return dbs[tbl]     end
            if key == "On"     then return setupOnHandler(tbl) end
            return rawget(tbl, key)
        end
        -- __newindex wird weggelassen! Default-Behavior reicht.
    })

    return mod
end

function KCDUtils.OnGameplayStarted()
    local logger = KCDUtils.Logger.Factory(KCDUtils.Name)
    logger:Info("OnGameplayStarted triggered")

    for modName, modTable in pairs(KCDUtils.RegisteredMods) do
        if type(modTable.Init) == "function" then
            logger:Info("Re-initializing mod: " .. modName)
            modTable.Init()
        end

        if modTable._listeners then
            for _, subEntry in pairs(modTable._listeners) do
                if subEntry.subscription and subEntry.eventTable and subEntry.eventTable.Remove then
                    subEntry.eventTable.Remove(subEntry.subscription)
                end
            end
        end
        modTable._listeners = {}

        if type(modTable.OnGameplayStarted) == "function" then
            logger:Info("Calling OnGameplayStarted for mod: " .. modName)
            modTable.OnGameplayStarted()
        end

        local hooks = on_hooks[modTable]
        if hooks then
            for eventName, hookData in pairs(hooks) do
                local eventTable = KCDUtils.Events[eventName]
                if eventTable and type(hookData.callback) == "function" then
                    local subscription = eventTable.AddSafe({}, hookData.callback)
                    hooks[eventName].subscription = subscription
                end
            end
        end
    end

    if KCDUtils.Events.DistanceTravelled and KCDUtils.Events.DistanceTravelled.ResetListeners then
        KCDUtils.Events.DistanceTravelled.ResetListeners()
    end

    if KCDUtils.Events.watchLoopRunning then
        KCDUtils.Events.watchLoopRunning = false
    end
    KCDUtils.Events.WatchLoop()

    KCDUtils.Events.GameplayStarted.Fire()
end

local function Initialize()
    if not KCDUtils.initiated then
        KCDUtils.initiated = true
        System.LogAlways(KCDUtils.Name .. ": Initializing...")
        ScriptLoader.LoadFolder("Scripts/Mods/" .. KCDUtils.Name)
    end
    KCDUtils.Events.RegisterOnGameplayStarted(KCDUtils)
    System.LogAlways(KCDUtils.Name .. ": Initialization complete.")
end

Initialize()