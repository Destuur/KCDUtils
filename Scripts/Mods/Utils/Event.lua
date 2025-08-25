---@class KCDUtilsEvent
KCDUtils.Event = KCDUtils and KCDUtils.Event or {}

if KCDUtils.Event.initialized then
    System.LogAlways("[EventForge] Already initialized, skipping EventForge.lua")
    return
end

local listeners = {}
local cachedEvents = {}
local availableEvents = {}

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
function KCDUtils.Event:DefineEvent(eventName, modName, description, paramList)
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
--- Event Listener Registration
--------------------------------------------------
-- #region Event Listener Registration

-- This section contains the implementation of the EventForge listener registration function.
-- The EventForge system allows different mods or systems to register callback functions for specific events.
-- When an event is triggered, all registered listeners for that event will be notified.

--- Registers a listener (callback) for a specific event in the EventForge system.
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
function KCDUtils.Event:Subscribe(eventName, callbackFunction, opts)
    
    opts = opts or {}
    local logger = KCDUtils.Logger.Factory(opts.modName or "Unknown")

    if type(callbackFunction) ~= "function" then
        error("Callback must be a function")
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

    logger:Info("Registered listener for event '" .. eventName .. "'.")

    if cachedEvents[eventName] and #cachedEvents[eventName] > 0 then
        logger:Info("Firing cached events for '" .. eventName .. "' (" .. tostring(#cachedEvents[eventName]) .. " cached events).")
        for _, args in ipairs(cachedEvents[eventName]) do
            self:Publish(eventName, table.unpack(args))
        end
        cachedEvents[eventName] = nil
    end
end

---
--- Unregisters a previously registered listener for a specific event.
---
--- Removes the given callback function from the list of listeners for the specified event.
---
--- @param eventName (string) The name of the event.
--- @param callbackFunction (function) The callback function to remove.
function KCDUtils.Event:Unsubscribe(eventName, callbackFunction)
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
--- Event Firing
--------------------------------------------------
-- #region Event Firing

--- Fires (triggers) an event, calling all registered listeners for that event.
---
--- If no listeners are registered, the event and its arguments are cached for later delivery.
--- Listeners registered with 'once=true' are removed after being called.
---
--- @param eventName (string) The name of the event to fire.
--- @param ... (any) Arguments to pass to the listener callback functions.
function KCDUtils.Event:Publish(eventName, ...)
    System.LogAlways("FireEvent called for '" .. eventName .. "' with " .. select("#", ...) .. " args")
    local lst = listeners[eventName]
    if not lst or #lst == 0 then
        cachedEvents[eventName] = cachedEvents[eventName] or {}
        table.insert(cachedEvents[eventName], {...})
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
--- Event Delaying ###### Does not work ######
--------------------------------------------------
-- #region Event Delaying

--- Fires an event after a specified delay (in milliseconds).
---
--- Uses Script.SetTimer to schedule the event firing.
---
-- @param eventName (string) The name of the event to fire.
-- @param delayMs (number) The delay in milliseconds before firing the event.
-- @param ... (any) Arguments to pass to the listener callback functions.
-- function KCDUtils.Event.FireEventDelayed(eventName, delayMs, ...)
--     KCDUtils.Event._delayedEvents = KCDUtils.Event._delayedEvents or {}
    
--     local function FireEventDelayedCallback(id)
--         local info = KCDUtils.Event._delayedEvents[id]
--         if info then
--             KCDUtils.Event.FireEvent(info.eventName, table.unpack(info.args))
--             KCDUtils.Event._delayedEvents[id] = nil
--         end
--         return false
--     end
--     local id = tostring(System.GetFrameTickCount()) .. tostring(math.random(1000000))
--     KCDUtils.Event._delayedEvents[id] = { eventName = eventName, args = {...} }
--     Script.SetTimer(delayMs, function() FireEventDelayedCallback(id) end)
-- end


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
function KCDUtils.Event:ListEvents()
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
--- Logs all listeners registered for a specific event to the system log.
---
-- @param eventName (string) The name of the event to list listeners for.
-- function KCDUtils.Event.DebugListListeners(eventName)
--     local lst = listeners[eventName]
--     if not lst then
--         System.LogAlways("[EventForge] No listeners for event '" .. eventName .. "'.")
--         return
--     end
--     System.LogAlways("[EventForge] ---- Listeners for " .. eventName .. " ----")
-- end


---
--- Logs all listeners registered for all events to the system log.
---
--- Usage: EventForge.Listeners
---
--- Lists all registered listeners for every event, including the mod name and whether the listener is set to fire only once.
---
function KCDUtils.Event:ListSubscribers()
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
function KCDUtils.Event:ListEventsByMod(modName)
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

------------------------------------------------

KCDUtils.Event.initialized = true