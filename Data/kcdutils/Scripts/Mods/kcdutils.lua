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
KCDUtils.HasGameStarted = false

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

local function createLocalEvent(mod, eventName)
    return {
        listeners = {},

        Add = function(self, callback)
            for i = #self.listeners, 1, -1 do
                if self.listeners[i].callback == callback then
                    table.remove(self.listeners, i)
                end
            end
            local sub = { callback = callback, once = false, isPaused = false }
            table.insert(self.listeners, sub)
            return sub
        end,

        Remove = function(self, sub)
            for i = #self.listeners, 1, -1 do
                if self.listeners[i] == sub then
                    table.remove(self.listeners, i)
                    break
                end
            end
        end,

        Trigger = function(self, arg)
            for i = #self.listeners, 1, -1 do
                local sub = self.listeners[i]
                if not sub.isPaused then
                    local ok, err = pcall(sub.callback, arg)
                    if not ok then
                        KCDUtils.Logger.Factory(mod.Name):Error(
                            ("%s callback error: %s"):format(eventName, tostring(err))
                        )
                    end
                    if sub.once then self:Remove(sub) end
                end
            end
        end
    }
end

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

    -- Globale Events vorbereiten
    KCDUtils.Events[modName] = KCDUtils.Events[modName] or {}
    mod.Events = setmetatable({}, { __index = KCDUtils.Events })

    -- --------------------------
    -- Lokale Events automatisch hinzufügen
    -- --------------------------
    mod.OnMenuChanged = createLocalEvent(mod, "OnMenuChanged")
    -- später kannst du weitere vorkonfigurierte Events hinzufügen:
    -- mod.OnSomething = createLocalEvent(mod, "OnSomething")

    -- --------------------------
    -- Setup globales "On" Handler
    -- --------------------------
    local handler = setupOnHandler(mod)
    mod._listeners = mod._listeners or {}

    setmetatable(mod, {
        __index = function(tbl, key)
            if key == "Logger" then return loggers[tbl] end
            if key == "DB"     then return dbs[tbl]     end
            if key == "On"     then return handler end -- global
            return rawget(tbl, key)
        end,
        __newindex = function(tbl, key, val)
            rawset(tbl, key, val)
        end
    })

    return mod
end

function KCDUtils.OnGameplayStarted()
    local logger = KCDUtils.Logger.Factory(KCDUtils.Name)
    logger:Info("OnGameplayStarted triggered")
    KCDUtils.HasGameStarted = true

    for modName, modTable in pairs(KCDUtils.RegisteredMods) do
        -- Init-Funktion sicher ausführen
        if type(modTable.Init) == "function" then
            local ok, err = xpcall(modTable.Init, function(e)
                logger:Error(("Error in Init for mod '%s': %s\n%s"):format(modName, tostring(e), debug.traceback()))
            end)
            if not ok then
                logger:Error("Init xpcall failed for mod '" .. tostring(modName) .. "'")
            end
        end

        -- Menü erst jetzt mit DB-Werten bauen
        local reg = KCDUtils.Menu._registeredMenus and KCDUtils.Menu._registeredMenus[modName]
        if reg then
            local ok, err = pcall(KCDUtils.Menu.BuildWithDB, KCDUtils.Menu, modTable)
            if not ok then
                logger:Error(("Error building menu for mod '%s': %s"):format(modName, tostring(err)))
            end
        end

        -- OnGameplayStarted des Mods sicher aufrufen
        if type(modTable.OnGameplayStarted) == "function" then
            local ok, err = xpcall(modTable.OnGameplayStarted, function(e)
                logger:Error(("Error in OnGameplayStarted for mod '%s': %s\n%s"):format(modName, tostring(e), debug.traceback()))
            end)
            if not ok then
                logger:Error("OnGameplayStarted xpcall failed for mod '" .. tostring(modName) .. "'")
            end
        end

        -- Hooks wieder registrieren
        local hooks = on_hooks[modTable]
        if hooks then
            for eventName, hookData in pairs(hooks) do
                local ok, err = pcall(function()
                    local eventTable = KCDUtils.Events[eventName]
                    if not eventTable or type(hookData.callback) ~= "function" then return end

                    -- prefer AddSafe if available, otherwise fallback to Add
                    local addFn = eventTable.AddSafe or eventTable.Add
                    if type(addFn) ~= "function" then
                        KCDUtils.Logger.Factory("KCDUtils.OnGameplayStarted"):Error(
                            ("No Add/AddSafe found for event '%s'"):format(tostring(eventName))
                        )
                        return
                    end

                    local subscription = addFn({}, hookData.callback)
                    hooks[eventName].subscription = subscription
                end)
                if not ok then
                    logger:Error(
                        ("Error re-registering hook '%s' for mod '%s': %s"):format(tostring(eventName), tostring(modName), tostring(err))
                    )
                end
            end
        end
    end

    -- WatchLoop & DistanceTravelled Reset
    if KCDUtils.Events.DistanceTravelled and KCDUtils.Events.DistanceTravelled.ResetListeners then
        KCDUtils.Events.DistanceTravelled.ResetListeners()
    end
    if KCDUtils.Events.watchLoopRunning then
        KCDUtils.Events.watchLoopRunning = false
    end
    if KCDUtils.Events.WatchLoop then
        KCDUtils.Events.WatchLoop()
    end

    if KCDUtils.Events.GameplayStarted and KCDUtils.Events.GameplayStarted.Fire then
        KCDUtils.Events.GameplayStarted.Fire()
    end
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