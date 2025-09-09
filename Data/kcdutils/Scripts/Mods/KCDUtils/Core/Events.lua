--- @diagnostic disable
KCDUtils = KCDUtils or {}
---@class KCDUtilsEvents
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.updaters = KCDUtils.Events.updaters or {}
KCDUtils.Events.watchLoopRunning = KCDUtils.Events.watchLoopRunning or false
KCDUtils.Events.initialized = KCDUtils.Events.initialized or false
KCDUtils.Events.listeners = KCDUtils.Events.listeners or {}
KCDUtils.Events.cachedEvents = KCDUtils.Events.cachedEvents or {}
KCDUtils.Events.availableEvents = KCDUtils.Events.availableEvents or {}

local unpack = table.unpack or unpack
local pack = table.pack or function(...) return { n = select("#", ...), ... } end

if KCDUtils.Events.initialized then
    System.LogAlways("[KCDUtils.Events] Reload detected, re-registering updaters...")

    -- Alte Updater entfernen
    for _, fn in ipairs(KCDUtils.Events.updaters) do
        KCDUtils.Events.UnregisterUpdater(fn)
    end
    KCDUtils.Events.updaters = {} -- leere Liste

    -- WatchLoop neu starten
    KCDUtils.Events.watchLoopRunning = false
    KCDUtils.Events.WatchLoop()
else
    -- Erstinitialisierung
    KCDUtils.Events.initialized = true
end

--------------------------------------------------
--- Event Registry
--------------------------------------------------
-- #region Event Registry

-- Registers a new event in the EventForge system.
--
--- This function allows a mod to declare a new event that can be listened to by other mods or systems.
---
---@param eventName (string) The unique name of the event to register.
---@param modName (string) The name of the mod registering the event.
---@param description (string|nil) Optional description of the event's purpose.
---@param paramList (table|nil) Optional list of parameter names or descriptions for the event.
function KCDUtils.Events.RegisterEvent(eventName, modName, description, paramList)
    local logger = KCDUtils.Logger.Factory(modName)

    KCDUtils.Events.availableEvents[eventName] = KCDUtils.Events.availableEvents[eventName] or {}
    table.insert(KCDUtils.Events.availableEvents[eventName], {
        modName = modName,
        description = description or "",
        params = paramList or {}
    })

    logger:Info("Event registered: '" .. eventName .. "'")
end

function KCDUtils.Events.RegisterListener(mod, eventTable, config, callback)
    mod._listeners = mod._listeners or {}

    -- Prüfen, ob schon ein Listener für diese Callback existiert
    for i = #mod._listeners, 1, -1 do
        local entry = mod._listeners[i]
        if entry.callback == callback and entry.eventTable == eventTable then
            entry.eventTable.Remove(entry.subscription)
            table.remove(mod._listeners, i)
        end
    end

    -- Neuen Listener hinzufügen
    local sub = eventTable.Add(config, callback)
    table.insert(mod._listeners, { eventTable = eventTable, subscription = sub, callback = callback })

    return sub
end

-- #endregion

--------------------------------------------------
--- Event Listener Subscription
--------------------------------------------------
-- #region Event Listener Subscription

-- This section contains the implementation of the KCDUtils listener subscription function.
-- The KCDUtils system allows different mods or systems to register callback functions for specific events.
-- When an event is triggered, all subscribed listeners for that event will be notified.

--- Subscribes a listener (callback) for a specific event in the KCDUtils system.
---
--- This function allows a mod to listen for a specific event by providing:
---   - eventName: the event to listen for
---   - callbackFunction: the function to call when the event is fired
---   - opts: table with optional fields:
---       - modName (string): the name of the mod registering the listener (for debugging)
---       - once (boolean): if true, the listener is removed after the first call
---
--- Duplicate listeners (same callback for the same event) are prevented.
---
--- @param eventName (string) The name of the event to listen for.
--- @param callbackFunction (function) The function to be called when the event is triggered.
--- @param opts (table|nil) Optional table with fields 'modName' (string) and 'once' (boolean).
function KCDUtils.Events.Subscribe(eventName, callbackFunction, opts)
    opts = opts or {}
    local logger = KCDUtils.Logger.Factory(opts.modName or "Unknown")

    if type(callbackFunction) ~= "function" then
        logger:Error("Callback must be a function")
    end

    KCDUtils.Events.listeners[eventName] = KCDUtils.Events.listeners[eventName] or {}

    for _, listener in ipairs(KCDUtils.Events.listeners[eventName]) do
        if listener.callback == callbackFunction then
            return
        end
    end

    table.insert(KCDUtils.Events.listeners[eventName], {
        callback = callbackFunction,
        modName = opts.modName,
        once = opts.once or false
    })

    logger:Info("Subscribed listener for event '" .. eventName .. "'.")

    if KCDUtils.Events.cachedEvents[eventName] and #KCDUtils.Events.cachedEvents[eventName] > 0 then
        logger:Info("Publish cached events for '" .. eventName .. "' (" .. tostring(#KCDUtils.Events.cachedEvents[eventName]) .. " cached events).")
        for _, args in ipairs(KCDUtils.Events.cachedEvents[eventName]) do
            KCDUtils.Events.Publish(eventName, table.unpack(args))
        end
        KCDUtils.Events.cachedEvents[eventName] = nil
    end
end

--- Utility to subscribe a method as listener to a system event
--- @param target table Object that contains the callback method
--- @param methodName string Name of the method on the target
--- @param eventName string|nil Name of the system event (default = methodName)
function KCDUtils.Events.SubscribeSystemEvent(target, methodName, eventName)
    local name = target.Name or ("Table@" .. tostring(target))
    local logger = KCDUtils.Logger.Factory(name)
    eventName = eventName or methodName
    if not target[methodName] or type(target[methodName]) ~= "function" then
        logger:Error("Target does not have a method named '" .. methodName .. "'")
        return
    end
    UIAction.RegisterEventSystemListener(target, "System", eventName, methodName)
    logger:Info("Subscribed " .. tostring(methodName) .. " to system event '" .. eventName .. "'")
end

--- Utility to subscribe a method as listener to the OnGameplayStarted event
--- 
--- ### Callback method must have the signature:
--- ```lua
--- function MyMod.OnGameplayStarted(actionName, eventName, argTable) -- parameters optional
---     -- handle event
--- end
--- ```
--- 
--- @param target table Object that contains the callback method "OnGameplayStarted"
function KCDUtils.Events.RegisterOnGameplayStarted(target)
    KCDUtils.Events.SubscribeSystemEvent(target, "OnGameplayStarted")
end

--- Unsubscribes a previously subscribed listener for a specific event.
---
--- Removes the given callback function from the list of listeners for the specified event.
---
--- @param eventName (string) The name of the event.
--- @param callbackFunction (function) The callback function to remove.
function KCDUtils.Events.Unsubscribe(eventName, callbackFunction)
    local lst = KCDUtils.Events.listeners[eventName]
    if not lst then return end
    for i = #lst, 1, -1 do
        if lst[i].callback == callbackFunction then
            table.remove(lst, i)
        end
    end
    if #lst == 0 then KCDUtils.Events.listeners[eventName] = nil end
end
-- #endregion

--------------------------------------------------
--- Updater
--------------------------------------------------
-- #region Updater


--- Registers an updater function that runs each tick
---@param fn function
function KCDUtils.Events.RegisterUpdater(fn)
    if type(fn) ~= "function" then return end
    table.insert(KCDUtils.Events.updaters, fn)
end

--- Unregisters an updater function
---@param fn function
function KCDUtils.Events.UnregisterUpdater(fn)
    for i = #KCDUtils.Events.updaters, 1, -1 do
        if KCDUtils.Events.updaters[i] == fn then
            table.remove(KCDUtils.Events.updaters, i)
            break
        end
    end
end

--- Starts the watch loop (idempotent, reload-safe)
function KCDUtils.Events.WatchLoop()
    if KCDUtils.Events.watchLoopRunning then
        return
    end
    KCDUtils.Events.watchLoopRunning = true

    local function loop()
        -- Run all updaters safely
        for i, fn in ipairs(KCDUtils.Events.updaters) do
            local ok, err = pcall(fn, 1/60)
            if not ok then
                local logger = KCDUtils.Logger.Factory("KCDUtils.Events")
                logger:Error("Updater failed: " .. tostring(err))
            end
        end

        -- Schedule next tick
        Script.SetTimer(16, loop)
    end

    loop()
end

-- #endregion

--------------------------------------------------
--- Updater Events
--------------------------------------------------
-- #region Updater Events

function KCDUtils.Events.OnEnteringSettlement(settlement)
    KCDUtils.Events.Publish("World.EnteringSettlement", settlement)
end

function KCDUtils.Events.GetWorldDayOfWeek(settlement)
    KCDUtils.Events.Publish("World.GetDayOfWeek", settlement)
end

function KCDUtils.Events.OnLeavingSettlement(settlement)
    KCDUtils.Events.Publish("World.LeavingSettlement", settlement)
end

function KCDUtils.Events.OnNearbyEnemiesDetected(enemies)
    KCDUtils.Events.Publish("World.NearbyEnemiesDetected", enemies)
end

function KCDUtils.Events.OnSkillLevelUp(skillName, newLevel)
    KCDUtils.Events.Publish("Player.SkillLevelUp", skillName, newLevel)
end

function KCDUtils.Events.OnReputationThresholdCrossed(factionName, newReputation)
    KCDUtils.Events.Publish("Player.ReputationThresholdCrossed", factionName, newReputation)
end

function KCDUtils.Events.OnMoneyThresholdCrossed(newAmount)
    KCDUtils.Events.Publish("Player.MoneyThresholdCrossed", newAmount)
end

function KCDUtils.Events.OnPeriodicTick(deltaTime)
    KCDUtils.Events.Publish("Game.PeriodicTick", deltaTime)
end

-- #endregion

--------------------------------------------------
--- Event Publishing
--------------------------------------------------
-- #region Event Publishing

--- Publish (triggers) an event, calling all subscribed listeners for that event.
---
--- If no listeners are subscribed, the event and its arguments are cached for later delivery.
--- Listeners subscribed with 'once=true' are removed after being called.
---
--- @param eventName (string) The name of the event to publish.
--- @param ... (any) Arguments to pass to the listener callback functions.
function KCDUtils.Events.Publish(eventName, ...)
    System.LogAlways("Publish called for '" .. eventName .. "' with " .. select("#", ...) .. " args")
    local lst = KCDUtils.Events.listeners[eventName]
    if not lst or #lst == 0 then
        KCDUtils.Events.cachedEvents[eventName] = KCDUtils.Events.cachedEvents[eventName] or {}
        table.insert(KCDUtils.Events.cachedEvents[eventName], table.pack(...))
        System.LogAlways("No listeners for event '" .. eventName .. "'. Event cached.")
        return
    end

    for i = #lst, 1, -1 do
        local listener = lst[i]
        local ok, err = pcall(listener.callback, ...)
        if not ok then
            System.LogAlways("Error calling listener from mod '" .. (listener.modName or "Unknown") .. "': " .. err)
        end

        if listener.once then
            table.remove(lst, i)
        end
    end
end

-- #endregion

--------------------------------------------------
--- Event Debugging
--------------------------------------------------
-- #region Debugging Tools

--- Logs all registered events and their descriptions/parameters to the system log.
---
--- Usage: KCDUtils.Events
---
--- Lists all registered events and their descriptions/parameters.
function KCDUtils.Events.ListEvents()
    System.LogAlways("---- Registered Events ----")
    for eventName, mods in pairs(KCDUtils.Events.availableEvents) do
        System.LogAlways("Event: " .. eventName)
        for _, info in ipairs(mods) do
            System.LogAlways("  - By " .. info.modName .. ": " .. (info.description or ""))
            if info.params and #info.params > 0 then
                System.LogAlways("    Params: " .. table.concat(info.params, ", "))
            end
        end
    end
end

---
--- Logs all listeners registered for all events to the system log.
---
--- Usage: KCDUtils.Listeners
---
--- Lists all registered listeners for every event, including the mod name and whether the listener is set to fire only once.
---
function KCDUtils.Events.ListSubscribers()
    System.LogAlways("---- Registered Listeners ----")
    local found = false
    for eventName, lst in pairs(KCDUtils.Events.listeners) do
        if lst and #lst > 0 then
            System.LogAlways("Event: " .. eventName)
            for _, listener in ipairs(lst) do
                System.LogAlways("  - " .. (listener.modName or "Unknown") .. " (once=" .. tostring(listener.once) .. ")")
            end
            found = true
        end
    end
    if not found then
        System.LogAlways("No listeners registered.")
    end
end

---
--- Logs all events registered by a specific mod to the system log.
---
--- @param modName (string) The name of the mod whose events should be listed.
function KCDUtils.Events.ListEventsByMod(modName)
    System.LogAlways("---- Events registered by " .. modName .. " ----")
    for eventName, mods in pairs(KCDUtils.Events.availableEvents) do
        for _, info in ipairs(mods) do
            if info.modName == modName then
                System.LogAlways("  - " .. eventName .. ": " .. (info.description or ""))
                if info.params and #info.params > 0 then
                    System.LogAlways("    Params: " .. table.concat(info.params, ", "))
                end
            end
        end
    end
end

-- #endregion

--------------------------------------------------
--- Console Commands
--------------------------------------------------
-- #region Console Commands

--- Console Commands for accessing KCDUtils.Events functionality
-- System.AddCCommand("KCDUtils.Events", "KCDUtils.Events.DebugListEvents()", "List all registered events")
-- System.AddCCommand("KCDUtils.Listeners", "KCDUtils.Events.DebugListListeners()", "List all registered listeners for all events")
-- #### Not working with params ####
-- System.AddCCommand("KCDUtils.Listeners", "KCDUtils.Events.DebugListListeners()", "List all registered listeners for an event")
-- System.AddCCommand("KCDUtils.EventsByMod", "KCDUtils.Events.DebugListEventsByMod()", "List all events registered by a mod")
-- #####################

-- #endregion

KCDUtils.Events.initialized = true