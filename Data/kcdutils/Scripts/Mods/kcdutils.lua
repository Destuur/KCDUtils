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

function meta_on_handler.__index(handler, key)
    if key == "Add" then
        return function(_, eventName, fn, config)
            local owner = handler.__owner or handler
            local eventTable = KCDUtils.Events[eventName] or (KCDUtils.Events.CreateEvent and KCDUtils.Events.CreateEvent(eventName))
            if not eventTable then return nil end
            on_hooks[owner] = on_hooks[owner] or {}
            local subscription = eventTable.Add(config or {}, fn)
            on_hooks[owner][eventName] = { subscription = subscription, callback = fn }
            return wrapSubscription(eventTable, subscription)
        end
    end
    local owner = handler.__owner or handler
    on_hooks[owner] = on_hooks[owner] or {}
    local hook = on_hooks[owner][key]
    if hook then
        return wrapSubscription(KCDUtils.Events[key], hook.subscription)
    end
    return nil
end

function meta_on_handler.__newindex(handler, key, val)
    local owner = handler.__owner or handler
    local eventTable = KCDUtils.Events[key] or (KCDUtils.Events.CreateEvent and KCDUtils.Events.CreateEvent(key))
    if not eventTable then
        KCDUtils.Logger.Factory((owner and owner.Name) or "UnknownMod"):Error("Tried to bind to unknown event: "..tostring(key))
        return
    end
    on_hooks[owner] = on_hooks[owner] or {}
    local current = on_hooks[owner][key]
    if val == nil and current then
        eventTable.Remove(current.subscription); on_hooks[owner][key] = nil; return
    end
    if current then eventTable.Remove(current.subscription); on_hooks[owner][key] = nil end
    if type(val) == "function" then
        local subscription = eventTable.Add({}, val)
        on_hooks[owner][key] = { subscription = subscription, callback = val }
    end
end

local function setupOnHandler(mod)
    if on_handlers[mod] then return on_handlers[mod] end
    on_hooks[mod] = on_hooks[mod] or {}
    local handler = setmetatable({ __owner = mod }, meta_on_handler)
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
    mod.Events = setmetatable({}, { __index = KCDUtils.Events })

    mod.OnMenuChanged = createLocalEvent(mod, "OnMenuChanged")
    local handler = setupOnHandler(mod)
    mod._listeners = mod._listeners or {}

    setmetatable(mod, {
        __index = function(tbl, key)
            if key == "Logger" then return loggers[tbl] end
            if key == "DB"     then return dbs[tbl]     end
            if key == "On"     then return handler end
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

    KCDUtils.Events.RegisterOnUsedEvent("Smithery",     "SmitheryStarted",  { phase = "before" })
    KCDUtils.Events.RegisterOnUsedEvent("AlchemyTable", "AlchemyStarted",   { phase = "before" })
    KCDUtils.Events.RegisterAnyOnButcherEvent("ButcherStarted", { phase = "after" })

    local function rebindOnHandlersForMod(modTable, modName)
        local primary = on_hooks[modTable]

        local handler = on_handlers[modTable]
        local altA    = handler and on_hooks[handler] or nil
        local altB    = (modTable.On and modTable.On ~= handler) and on_hooks[modTable.On] or nil

        local sources = { primary, altA, altB }
        local seen = {}

        for _, src in ipairs(sources) do
            if src then
                for eventName, hookData in pairs(src) do
                    if not seen[eventName] and type(hookData.callback) == "function" then
                        local eventTable = KCDUtils.Events[eventName] or KCDUtils.Events.CreateEvent(eventName)
                        local addFn = eventTable.AddSafe or eventTable.Add
                        if type(addFn) ~= "function" then
                            KCDUtils.Logger.Factory("KCDUtils.OnGameplayStarted")
                                :Error(("No Add/AddSafe found for event '%s'"):format(tostring(eventName)))
                        else
                            local ok, sub = pcall(addFn, {}, hookData.callback)
                            if ok and sub then
                                hookData.subscription = sub
                                seen[eventName] = true
                            else
                                logger:Error(("Failed to bind '%s' for mod '%s'"):format(tostring(eventName), tostring(modName)))
                            end
                        end
                    end
                end
            end
        end
    end

    for modName, modTable in pairs(KCDUtils.RegisteredMods) do
        if type(modTable.Init) == "function" then
            local ok = xpcall(modTable.Init, function(e)
                logger:Error(("Error in Init for mod '%s': %s\n%s"):format(modName, tostring(e), debug.traceback()))
            end)
            if not ok then logger:Error("Init xpcall failed for mod '" .. tostring(modName) .. "'") end
        end

        local reg = KCDUtils.Menu._registeredMenus and KCDUtils.Menu._registeredMenus[modName]
        if reg then
            local ok, err = pcall(KCDUtils.Menu.BuildWithDB, KCDUtils.Menu, modTable)
            if not ok then
                logger:Error(("Error building menu for mod '%s': %s"):format(modName, tostring(err)))
            end
        end

        if type(modTable.OnGameplayStarted) == "function" then
            local ok = xpcall(modTable.OnGameplayStarted, function(e)
                logger:Error(("Error in OnGameplayStarted for mod '%s': %s\n%s"):format(modName, tostring(e), debug.traceback()))
            end)
            if not ok then logger:Error("OnGameplayStarted xpcall failed for mod '" .. tostring(modName) .. "'") end
        end

        rebindOnHandlersForMod(modTable, modName)
    end

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