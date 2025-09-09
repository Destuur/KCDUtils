KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.GameplayStarted = KCDUtils.Events.GameplayStarted or { listeners = {} }

-- Listener-Objekt: { callback = function, modName = "Firstmod" }

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

function KCDUtils.Events.GameplayStarted.Remove(callback)
    for i, entry in ipairs(KCDUtils.Events.GameplayStarted.listeners) do
        if entry.callback == callback then
            table.remove(KCDUtils.Events.GameplayStarted.listeners, i)
            break
        end
    end
end

-- Entfernt alle Listener, die zu einem bestimmten Mod gehören
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

-- Set = vorherige Listener des Mods entfernen + neuen registrieren
function KCDUtils.Events.GameplayStarted.Set(modName, callback)
    KCDUtils.Events.GameplayStarted.RemoveByMod(modName)
    KCDUtils.Events.GameplayStarted.Add(callback, modName)
end

function KCDUtils.Events.GameplayStarted.Fire()
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.GameplayStarted")
    logger:Info("Firing OnGameplayStarted event to " .. #KCDUtils.Events.GameplayStarted.listeners .. " listeners.")
    for _, entry in ipairs(KCDUtils.Events.GameplayStarted.listeners) do
        entry.callback()
    end
end
