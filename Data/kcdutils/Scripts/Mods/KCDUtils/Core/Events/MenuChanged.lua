KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.MenuChanged = KCDUtils.Events.MenuChanged or {}

local MC = KCDUtils.Events.MenuChanged
MC.listeners = MC.listeners or {}

local function addListener(config, callback)
    config = config or {}

    -- doppelte Listener entfernen
    for i = #MC.listeners, 1, -1 do
        if MC.listeners[i].callback == callback then
            table.remove(MC.listeners, i)
        end
    end

    local sub = {
        callback = callback,
        once = config.once or false,
        isPaused = false
    }

    table.insert(MC.listeners, sub)
    return sub
end

local function removeListener(sub)
    for i = #MC.listeners, 1, -1 do
        if MC.listeners[i] == sub then
            table.remove(MC.listeners, i)
            break
        end
    end
end

--- Trigger-Funktion ohne Parameter
function MC.Trigger(arg)
    System.LogAlways("KCDUtils.Events.MenuChanged: Trigger called")
    for i = #MC.listeners, 1, -1 do
        local sub = MC.listeners[i]
        if not sub.isPaused then
            local ok, err = pcall(sub.callback, arg)  -- <-- Parameter übergeben
            if not ok then
                KCDUtils.Logger.Factory("KCDUtils.Events.MenuChanged"):Error(
                    "Callback error: " .. tostring(err)
                )
            end
            if sub.once then
                removeListener(sub)
            end
        end
    end
end

--- Public API
MC.Add = function(config, callback)
    return addListener(config, callback)
end

MC.Remove = function(subscription)
    return removeListener(subscription)
end

MC.Pause = function(subscription)
    if subscription then subscription.isPaused = true end
end

MC.Resume = function(subscription)
    if subscription then subscription.isPaused = false end
end
