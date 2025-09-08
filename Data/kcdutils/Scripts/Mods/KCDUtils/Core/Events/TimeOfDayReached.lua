KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or { Name = "KCDUtils.Events" }
KCDUtils.Events.TimeOfDayThresholdReached = KCDUtils.Events.TimeOfDayThresholdReached or {}

KCDUtils.Events.TimeOfDayThresholdReached.listeners = KCDUtils.Events.TimeOfDayThresholdReached.listeners or {}
KCDUtils.Events.TimeOfDayThresholdReached.isUpdaterRegistered = KCDUtils.Events.TimeOfDayThresholdReached.isUpdaterRegistered or false
KCDUtils.Events.TimeOfDayThresholdReached.updaterFn = KCDUtils.Events.TimeOfDayThresholdReached.updaterFn or nil

function KCDUtils.Events.TimeOfDayThresholdReached.Add(config, callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.TimeOfDayThresholdReached")
    if type(callback) ~= "function" then
        logger:Error("Add: callback must be a function")
        return nil
    end
    if type(config.targetHour) ~= "number" then
        logger:Error("Add: targetHour must be a number")
        return nil
    end

    local sub = {
        callback = callback,
        targetHour = config.targetHour,
        once = config.once or false,
        triggered = false,
        isPaused = false
    }

    table.insert(KCDUtils.Events.TimeOfDayThresholdReached.listeners, sub)
    logger:Info("New TimeOfDayThresholdReached subscription added: " .. sub.targetHour .. "h")

    if not KCDUtils.Events.TimeOfDayThresholdReached.isUpdaterRegistered then
        KCDUtils.Events.TimeOfDayThresholdReached:startUpdater()
        KCDUtils.Events.TimeOfDayThresholdReached.isUpdaterRegistered = true
    end

    return sub
end

function KCDUtils.Events.TimeOfDayThresholdReached.Remove(sub)
    for i, s in ipairs(KCDUtils.Events.TimeOfDayThresholdReached.listeners) do
        if s == sub then
            table.remove(KCDUtils.Events.TimeOfDayThresholdReached.listeners, i)
            break
        end
    end

    if #KCDUtils.Events.TimeOfDayThresholdReached.listeners == 0 then
        KCDUtils.Events.UnregisterUpdater(KCDUtils.Events.TimeOfDayThresholdReached.updaterFn)
        KCDUtils.Events.TimeOfDayThresholdReached.isUpdaterRegistered = false
    end
end

function KCDUtils.Events.TimeOfDayThresholdReached.Pause(sub) sub.isPaused = true end
function KCDUtils.Events.TimeOfDayThresholdReached.Resume(sub) sub.isPaused = false end

function KCDUtils.Events.TimeOfDayThresholdReached:startUpdater()
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.TimeOfDayThresholdReached")
    logger:Info("TimeOfDayThresholdReached updater started.")

    local fn = function()
        local ok, hour = pcall(KCDUtils.System.GetTimeOfDayHour)
        if not ok or not hour then return end

        for i = #KCDUtils.Events.TimeOfDayThresholdReached.listeners, 1, -1 do
            local sub = KCDUtils.Events.TimeOfDayThresholdReached.listeners[i]
            if not sub.isPaused and not sub.triggered then
                if hour >= sub.targetHour then
                    local success, err = pcall(sub.callback, hour)
                    if not success then
                        logger:Error("Callback error: " .. tostring(err))
                    end
                    sub.triggered = true
                    if sub.once then
                        KCDUtils.Events.TimeOfDayThresholdReached.Remove(sub)
                    end
                end
            end
        end
    end

    KCDUtils.Events.TimeOfDayThresholdReached.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end
