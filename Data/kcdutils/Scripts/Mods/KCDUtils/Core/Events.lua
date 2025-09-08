--- @diagnostic disable
KCDUtils = KCDUtils or {}
---@class KCDUtilsEvents
KCDUtils.Events = KCDUtils.Events or { Name = "KCDUtils.Events" }

KCDUtils.Events.updaters = KCDUtils.Events.updaters or {}
KCDUtils.Events.watchLoopRunning = KCDUtils.Events.watchLoopRunning or false

if KCDUtils.Events.initialized then
    System.LogAlways("[KCDUtils.Events] Already initialized, skipping Events.lua")
    return
end

local listeners = {}
local cachedEvents = {}
local availableEvents = {}
table.unpack = table.unpack or unpack
table.pack = table.pack or function(...)
    return { n = select("#", ...), ... }
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

    availableEvents[eventName] = availableEvents[eventName] or {}
    table.insert(availableEvents[eventName], {
        modName = modName,
        description = description or "",
        params = paramList or {}
    })

    logger:Info("Event registered: '" .. eventName .. "'")
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
    local logger = KCDUtils.Logger.Factory(opts.Name or "Unknown")

    if type(callbackFunction) ~= "function" then
        logger:Error("Callback must be a function")
    end

    listeners[eventName] = listeners[eventName] or {}

    for _, listener in ipairs(listeners[eventName]) do
        if listener.callback == callbackFunction then
            return
        end
    end

    table.insert(listeners[eventName], {
        callback = callbackFunction,
        modName = opts.modName,
        once = opts.once or false
    })

    logger:Info("Subscribed listener for event '" .. eventName .. "'.")

    if cachedEvents[eventName] and #cachedEvents[eventName] > 0 then
        logger:Info("Publish cached events for '" .. eventName .. "' (" .. tostring(#cachedEvents[eventName]) .. " cached events).")
        for _, args in ipairs(cachedEvents[eventName]) do
            KCDUtils.Event.Publish(eventName, table.unpack(args))
        end
        cachedEvents[eventName] = nil
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
    local lst = listeners[eventName]
    if not lst then return end
    for i = #lst, 1, -1 do
        if lst[i].callback == callbackFunction then
            table.remove(lst, i)
        end
    end
    if #lst == 0 then listeners[eventName] = nil end
end
-- #endregion

--------------------------------------------------
--- Updater
--------------------------------------------------
-- #region Updater


function KCDUtils.Events.RegisterUpdater(fn)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events")
    if type(fn) ~= "function" then
        logger:Error("Attempted to register a non-function as updater!")
        return
    end
    logger:Info("Registered updater function.")
    table.insert(KCDUtils.Events.updaters, fn)
end

function KCDUtils.Events.UnregisterUpdater(fn)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events")
    local found = false
    
    for i, updaterFn in ipairs(KCDUtils.Events.updaters) do
        if updaterFn == fn then
            table.remove(KCDUtils.Events.updaters, i)
            found = true
            break
        end
    end

    if found then
        logger:Info("Unregistered updater function.")
    else
        logger:Error("Attempted to unregister a function that was not found!")
    end
end

function KCDUtils.Events.WatchLoop()
    if KCDUtils.Events.watchLoopRunning then
        return
    end
    KCDUtils.Events.watchLoopRunning = true

    local function loop()
        for i, fn in ipairs(KCDUtils.Events.updaters) do
            local ok, err = pcall(fn, 1/60)
            if not ok then
                local logger = KCDUtils.Logger.Factory("KCDUtils.Events")
                logger:Error("Updater failed: " .. tostring(err))
            end
        end

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
    local lst = listeners[eventName]
    if not lst or #lst == 0 then
        cachedEvents[eventName] = cachedEvents[eventName] or {}
        table.insert(cachedEvents[eventName], table.pack(...))
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
    for eventName, mods in pairs(availableEvents) do
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
    for eventName, lst in pairs(listeners) do
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
    for eventName, mods in pairs(availableEvents) do
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