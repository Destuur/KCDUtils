KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.GameplayStarted = KCDUtils.Events.GameplayStarted or { listeners = {} }

--- Adds a listener callback for the OnGameplayStarted event.
--- @param callback function The function to call when gameplay starts.
--- @param modName string? Optional mod name for tracking and removal.
function KCDUtils.Events.GameplayStarted.Add(callback, modName)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.GameplayStarted")
    if type(callback) ~= "function" then
        logger:Error("Add: callback must be a function")
        return
    end
    table.insert(KCDUtils.Events.GameplayStarted.listeners, {
        callback = callback,
        modName = modName or "unknown"
    })
    logger:Info("Listener added for mod: " .. (modName or "unknown"))
end

--- Removes a specific listener callback from the OnGameplayStarted event.
--- @param callback function The callback function to remove.
function KCDUtils.Events.GameplayStarted.Remove(callback)
    for i, entry in ipairs(KCDUtils.Events.GameplayStarted.listeners) do
        if entry.callback == callback then
            table.remove(KCDUtils.Events.GameplayStarted.listeners, i)
            break
        end
    end
end

--- Removes all listener callbacks associated with the given mod name.
--- @param modName string The mod name whose listeners should be removed.
function KCDUtils.Events.GameplayStarted.RemoveByMod(modName)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.GameplayStarted")
    local removed = 0
    for i = #KCDUtils.Events.GameplayStarted.listeners, 1, -1 do
        if KCDUtils.Events.GameplayStarted.listeners[i].modName == modName then
            table.remove(KCDUtils.Events.GameplayStarted.listeners, i)
            removed = removed + 1
        end
    end
    if removed > 0 then
        logger:Info("Removed " .. removed .. " listeners for mod: " .. modName)
    end
end

--- Sets (replaces) the listener for a given mod name.
--- Removes all previous listeners for the mod and adds the new callback.
--- @param modName string The mod name to set the listener for.
--- @param callback function The callback function to register.
function KCDUtils.Events.GameplayStarted.Set(modName, callback)
    KCDUtils.Events.GameplayStarted.RemoveByMod(modName)
    KCDUtils.Events.GameplayStarted.Add(callback, modName)
end

--- Fires the OnGameplayStarted event, calling all registered listener callbacks.
function KCDUtils.Events.GameplayStarted.Fire()
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.GameplayStarted")
    logger:Info("Firing OnGameplayStarted event to " .. #KCDUtils.Events.GameplayStarted.listeners .. " listeners.")
    for _, entry in ipairs(KCDUtils.Events.GameplayStarted.listeners) do
        entry.callback()
    end
end
