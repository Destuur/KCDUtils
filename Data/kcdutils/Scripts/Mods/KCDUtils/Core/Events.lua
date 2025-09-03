--- @diagnostic disable
KCDUtils = KCDUtils or {}
---@class KCDUtilsEvents
KCDUtils.Events = KCDUtils.Events or { Name = "KCDUtils.Events" }

KCDUtils.Events.updaters = {}

if KCDUtils.Events.initialized then
    System.LogAlways("[EventForge] Already initialized, skipping EventForge.lua")
    return
end

local listeners = {}
local cachedEvents = {}
local availableEvents = {}
table.unpack = table.unpack or unpack  -- Lua 5.1 compatibility
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
    local logger = KCDUtils.Logger.Factory(target.Name or "Unknown")
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

--- ### Registers a listener for a threshold event.
--- 
--- ### Examples:
--- ```lua
--- -- You can pass the callback function as anonymous function:
--- KCDUtils.Events.RegisterThresholdEvent("health", 30, "below", function(value)
---     -- here comes the callback logic
--- end)
--- 
--- -- Or you can define a named function:
--- KCDUtils.Events.RegisterThresholdEvent("stamina", 75, "above", SomeFunction)
--- 
--- function SomeFunction(value)
---     -- here comes the callback logic
--- end
--- ```
--- 
--- @param soulState string Name of the soul state to monitor (e.g. "health", "stamina", "hunger").
--- @param threshold number The threshold value to compare against.
--- @param direction '"above"'|'"below"' The direction to monitor (above or below the threshold).
--- @param callback fun(value:number) The callback function to call when the threshold is crossed. Will pass the current value of the monitored soul state.
function KCDUtils.Events.RegisterThresholdEvent(soulState, threshold, direction, callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events")

    -- Defensive checks
    if type(soulState) ~= "string" then
        logger:Error("RegisterThresholdEvent: soulState must be a string")
        return
    end
    if type(threshold) ~= "number" then
        logger:Error("RegisterThresholdEvent: threshold must be a number")
        return
    end
    if direction ~= "above" and direction ~= "below" then
        logger:Error("RegisterThresholdEvent: direction must be 'above' or 'below'")
        return
    end
    if type(callback) ~= "function" then
        logger:Error("RegisterThresholdEvent: callback must be a function")
        return
    end

    -- Event name
    local eventName = string.format("SoulState.%s.%s%d", soulState, direction, threshold)
    KCDUtils.Events.Subscribe(eventName, callback, { modName = "KCDUtils" })

    -- Updater watcher state
    local watcher = { lastState = nil }

    -- Stable updater function
    local fn = function()
        local player = KCDUtils.Entities.Player:Get()
        if not player or not player.soul then
            return -- Player or soul system not ready
        end

        local value = player.soul:GetState(soulState)
        if not value then
            return -- Defensive: no value returned
        end

        local triggered = (direction == "below" and value < threshold)
                       or (direction == "above" and value > threshold)

        if triggered and watcher.lastState ~= true then
            logger:Info(string.format("%s threshold triggered: %s = %s", soulState, soulState, tostring(value)))
            KCDUtils.Events.Publish(eventName, value)
        end

        watcher.lastState = triggered
    end

    -- Ensure one updater per event
    KCDUtils.Events.updatersByEvent = KCDUtils.Events.updatersByEvent or {}
    if not KCDUtils.Events.updatersByEvent[eventName] then
        KCDUtils.Events.RegisterUpdater(fn)
        KCDUtils.Events.updatersByEvent[eventName] = fn
    end
end

function KCDUtils.Events.RegisterDistanceTravelledEvent(callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events")
    if type(callback) ~= "function" then
        logger:Error("RegisterDistanceTravelledEvent: callback must be a function")
        return
    end

    local eventName = "Player.DistanceTravelled"
    KCDUtils.Events.Subscribe(eventName, callback, { modName = KCDUtils.Name })

    local lastPosition = nil
    local totalDistance = 0

    local fn = function(deltaTime)
        deltaTime = deltaTime or 1.0
        local player = KCDUtils.Entities.Player:Get()
        if not player then return end

        local pos = KCDUtils.Math.GetPlayerPosition(player._raw)
        if not pos then return end

        if lastPosition then
            local dist = KCDUtils.Math.CalculateDistance(lastPosition, pos)
            if dist > 0.05 then -- minimal filter
                totalDistance = totalDistance + dist
            end
        end

        lastPosition = pos

        local speed = KCDUtils.Math.GetPlayerSpeed(player._raw, deltaTime, dist)
        KCDUtils.Events.Publish("Player.DistanceTravelled", {
            distance = totalDistance,
            speed = speed,
            position = pos
        })
    end

    KCDUtils.Events.RegisterUpdater(fn)
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

function KCDUtils.Events.WatchLoop()
    if KCDUtils.Events.watchLoopRunning then
        return
    end
    KCDUtils.Events.watchLoopRunning = true
    for i, fn in ipairs(KCDUtils.Events.updaters) do
        local ok, err = pcall(fn) -- dt not used currently
        if not ok then
        end
    end
    -- Schedule next tick
    Script.SetTimer(1000, function()
        KCDUtils.Events.watchLoopRunning = false
        KCDUtils.Events.WatchLoop()
    end)
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
--- Usage: EventForge.Events
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
--- Usage: EventForge.Listeners
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

--- Console Commands for accessing EventForge functionality
-- System.AddCCommand("EventForge.Events", "KCDUtils.Event.DebugListEvents()", "List all registered events")
-- System.AddCCommand("EventForge.Listeners", "KCDUtils.Event.DebugListListeners()", "List all registered listeners for all events")
-- #### Not working with params ####
-- System.AddCCommand("EventForge.Listeners", "KCDUtils.Event.DebugListListeners()", "List all registered listeners for an event")
-- System.AddCCommand("EventForge.EventsByMod", "KCDUtils.Event.DebugListEventsByMod()", "List all events registered by a mod")
-- #####################

-- #endregion

KCDUtils.Events.initialized = true