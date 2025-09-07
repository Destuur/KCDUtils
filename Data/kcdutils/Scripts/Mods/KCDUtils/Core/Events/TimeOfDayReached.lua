KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or { Name = "KCDUtils.Events" }
KCDUtils.Events.TimeOfDayReached = KCDUtils.Events.TimeOfDayReached or {}

KCDUtils.Events.TimeOfDayReached.listeners = {}
KCDUtils.Events.TimeOfDayReached.isUpdaterRegistered = false
KCDUtils.Events.TimeOfDayReached.updaterFn = nil

--- Adds a subscription for a specific in-game hour.
---
--- #### Examples:
--- ```lua
--- -- Fire at 7:30 AM once
--- KCDUtils.Events.TimeOfDayReached.Add({ targetHour = 7.5, once = true }, function(hour)
---     System.LogAlways("It is now 7:30 AM!")
--- end)
---
--- -- Fire every day at 18:00
--- KCDUtils.Events.TimeOfDayReached.Add({ targetHour = 18.0 }, function(hour)
---     System.LogAlways("It is now 6 PM!")
--- end)
---
--- -- Fire immediately if the target hour has already passed
--- KCDUtils.Events.TimeOfDayReached.Add({ targetHour = 12.0, fireIfPast = true }, function(hour)
---     System.LogAlways("Noon reached!")
--- end)
--- ```
---
---@param config table Configuration table:
---        Fields:
---        config.targetHour number -> Target in-game hour (e.g., 7.5 for 7:30 AM) (required)
---        config.once boolean -> Fire only once? (optional, default: false)
---        config.fireIfPast boolean -> Fire immediately if target time already passed? (optional, default: false)
---@param callback fun(hour:number) Callback function called when the target hour is reached.
---@return table? subscription Returns the subscription object that can be removed via Remove()
function KCDUtils.Events.TimeOfDayReached.Add(config, callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.TimeOfDayReached")

    if type(callback) ~= "function" then
        logger:Error("Add: callback must be a function")
        return nil
    end
    if not config or type(config.targetHour) ~= "number" then
        logger:Error("Add: targetHour must be a number")
        return nil
    end

    local sub = {
        callback = callback,
        targetHour = config.targetHour,
        isPaused = false,
        triggered = false,
        once = config.once or false,
        direction = config.direction or "above",
        fireIfPast = config.fireIfPast or false
    }

    table.insert(KCDUtils.Events.TimeOfDayReached.listeners, sub)
    logger:Info("New TimeOfDayReached subscription added for " .. sub.targetHour .. "h")

    -- Direkt auslösen, falls Zeit schon vorbei und fireIfPast aktiv
    local ok, currentHour = pcall(KCDUtils.System.GetTimeOfDayHour)
    if ok and currentHour and sub.fireIfPast then
        if sub.direction == "above" and currentHour >= sub.targetHour then
            sub.callback(currentHour)
            sub.triggered = true
            if sub.once then KCDUtils.Events.TimeOfDayReached.Remove(sub) end
        elseif sub.direction == "below" and currentHour <= sub.targetHour then
            sub.callback(currentHour)
            sub.triggered = true
            if sub.once then KCDUtils.Events.TimeOfDayReached.Remove(sub) end
        elseif sub.direction == "both" then
            sub.callback(currentHour)
            sub.triggered = true
            if sub.once then KCDUtils.Events.TimeOfDayReached.Remove(sub) end
        end
    end

    if not KCDUtils.Events.TimeOfDayReached.isUpdaterRegistered then
        KCDUtils.Events.TimeOfDayReached.startUpdater()
        KCDUtils.Events.TimeOfDayReached.isUpdaterRegistered = true
    end

    return sub
end

function KCDUtils.Events.TimeOfDayReached.Remove(subscription)
    for i, sub in ipairs(KCDUtils.Events.TimeOfDayReached.listeners) do
        if sub == subscription then
            table.remove(KCDUtils.Events.TimeOfDayReached.listeners, i)
            break
        end
    end

    if #KCDUtils.Events.TimeOfDayReached.listeners == 0 and KCDUtils.Events.TimeOfDayReached.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(KCDUtils.Events.TimeOfDayReached.updaterFn)
        KCDUtils.Events.TimeOfDayReached.isUpdaterRegistered = false
    end
end

function KCDUtils.Events.TimeOfDayReached.Pause(subscription)
    subscription.isPaused = true
end

function KCDUtils.Events.TimeOfDayReached.Resume(subscription)
    subscription.isPaused = false
end

function KCDUtils.Events.TimeOfDayReached.startUpdater()
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.TimeOfDayReached")
    logger:Info("TimeOfDayReached updater started.")

    local fn = function(deltaTime)
        deltaTime = deltaTime or 1.0
        local ok, currentHour = pcall(KCDUtils.System.GetTimeOfDayHour)
        if not ok or not currentHour then return end

        for i = #KCDUtils.Events.TimeOfDayReached.listeners, 1, -1 do
            local sub = KCDUtils.Events.TimeOfDayReached.listeners[i]
            if not sub.isPaused then
                if not sub.triggered then
                    if sub.direction == "above" and currentHour >= sub.targetHour then
                        sub.callback(currentHour)
                        sub.triggered = true
                        if sub.once then KCDUtils.Events.TimeOfDayReached.Remove(sub) end
                    elseif sub.direction == "below" and currentHour <= sub.targetHour then
                        sub.callback(currentHour)
                        sub.triggered = true
                        if sub.once then KCDUtils.Events.TimeOfDayReached.Remove(sub) end
                    elseif sub.direction == "both" then
                        sub.callback(currentHour)
                        sub.triggered = true
                        if sub.once then KCDUtils.Events.TimeOfDayReached.Remove(sub) end
                    end
                else
                    -- Reset für wiederkehrende Events
                    if not sub.once then
                        if sub.direction == "above" and currentHour < sub.targetHour then
                            sub.triggered = false
                        elseif sub.direction == "below" and currentHour > sub.targetHour then
                            sub.triggered = false
                        end
                    end
                end
            end
        end
    end

    KCDUtils.Events.TimeOfDayReached.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end