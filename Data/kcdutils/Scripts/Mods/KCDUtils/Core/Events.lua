KCDUtils = KCDUtils or {}
--- @class KCDUtilsEvents
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.updaters = KCDUtils.Events.updaters or {}
KCDUtils.Events.watchLoopRunning = KCDUtils.Events.watchLoopRunning or false
KCDUtils.Events.availableEvents = {}


--- Creates a new custom event or returns an existing one
--- @param eventName string Name of the event
--- @return table evt Event object with Add, Remove, Pause, Resume, Trigger methods
local function CreateEvent(eventName)
    local evt = KCDUtils.Events[eventName] or {}
    KCDUtils.Events[eventName] = evt

    evt.listeners = evt.listeners or {}
    evt.isUpdaterRegistered = evt.isUpdaterRegistered or false
    evt.updaterFn = evt.updaterFn or nil

    --- Add a new listener to the event
    --- @param config table Optional event-specific configuration
    --- @param callback fun(data:table) Function to be called when event fires
    --- @return table|nil subscription Subscription handle (pass to Remove, Pause, Resume)
    function evt.Add(config, callback)
        config = config or {}

        -- Prüfen, ob Callback eine Funktion ist
        if type(callback) ~= "function" then
            local logger = KCDUtils.Logger.Factory("KCDUtils.Events." .. (eventName or "Unknown"))
            logger:Error("Add: callback must be a function, got: " .. tostring(callback))
            return nil
        end

        -- Doppelten Callback entfernen (optional)
        for i = #evt.listeners, 1, -1 do
            if evt.listeners[i].callback == callback then
                table.remove(evt.listeners, i)
            end
        end

        local subscription = { callback = callback, config = config, isPaused = false }
        table.insert(evt.listeners, subscription)

        -- Optional: Start updater, falls vorhanden
        if not evt.isUpdaterRegistered and evt.startUpdater then
            evt.startUpdater()
            evt.isUpdaterRegistered = true
        end

        return subscription
    end

    --- Remove a previously registered listener
    --- @param subscription table Subscription object returned from Add
    function evt.Remove(subscription)
        for i = #evt.listeners, 1, -1 do
            if evt.listeners[i] == subscription then
                table.remove(evt.listeners, i)
                break
            end
        end
        if #evt.listeners == 0 and evt.isUpdaterRegistered then
            if evt.updaterFn then KCDUtils.Events.UnregisterUpdater(evt.updaterFn) end
            evt.isUpdaterRegistered = false
        end
    end

    --- Temporarily pause a subscription without removing it
    --- @param subscription table Subscription object returned from Add
    function evt.Pause(subscription) if subscription then subscription.isPaused = true end end

    --- Resume a paused subscription
    --- @param subscription table Subscription object returned from Add
    function evt.Resume(subscription) if subscription then subscription.isPaused = false end end

    --- Fire/trigger the event manually
    --- @param data table Optional data passed to all listeners
    function evt.Trigger(data)
        for _, subscription in ipairs(evt.listeners) do
            if not subscription.isPaused then subscription.callback(data or {}) end
        end
    end

    return evt
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

--- Registers a function to be called on every watch loop tick
--- @param fn function Function to be registered
function KCDUtils.Events.RegisterUpdater(fn)
    if type(fn) ~= "function" then return end
    table.insert(KCDUtils.Events.updaters, fn)
end

--- Removes a previously registered updater function from the watch loop
--- @param fn function Function previously registered via RegisterUpdater
function KCDUtils.Events.UnregisterUpdater(fn)
    for i = #KCDUtils.Events.updaters, 1, -1 do
        if KCDUtils.Events.updaters[i] == fn then
            table.remove(KCDUtils.Events.updaters, i)
            break
        end
    end
end

--- Starts the global event watch loop that periodically calls all registered updaters
function KCDUtils.Events.WatchLoop()
    if KCDUtils.Events.watchLoopRunning then return end
    KCDUtils.Events.watchLoopRunning = true

    local function loop()
        for _, fn in ipairs(KCDUtils.Events.updaters) do
            pcall(fn, 1/60)
        end
        Script.SetTimer(16, loop)
    end

    loop()
end

--- Registers event metadata for documentation/debug purposes
--- @param eventName string Name of the event
--- @param modName string Name of the mod registering the event
--- @param description string Optional description
--- @param paramList table Optional list of parameters for documentation
function KCDUtils.Events.RegisterEvent(eventName, modName, description, paramList)
    KCDUtils.Events.availableEvents[eventName] = KCDUtils.Events.availableEvents[eventName] or {}
    table.insert(KCDUtils.Events.availableEvents[eventName], {
        modName = modName,
        description = description or "",
        params = paramList or {}
    })
end

--- Lists all available events and their registered mods in the system log
function KCDUtils.Events.ListEvents()
    for eventName, mods in pairs(KCDUtils.Events.availableEvents) do
        System.LogAlways("Event: " .. eventName)
    end
end

KCDUtils.Events.CreateEvent = CreateEvent
KCDUtils.Events.WatchLoop()