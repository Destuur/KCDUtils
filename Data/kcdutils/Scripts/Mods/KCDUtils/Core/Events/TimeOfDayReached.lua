KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.TimeOfDayThresholdReached = KCDUtils.Events.TimeOfDayThresholdReached or {}

local TOD = KCDUtils.Events.TimeOfDayThresholdReached

TOD.listeners = TOD.listeners or {}
TOD.isUpdaterRegistered = TOD.isUpdaterRegistered or false
TOD.updaterFn = TOD.updaterFn or nil

local function addListener(config, callback)
    config = config or {}

    local sub = {
        callback = callback,
        targetHour = config.targetHour,
        once = config.once or false,
        triggered = false,
        isPaused = false
    }

    for i = #TOD.listeners, 1, -1 do
        if TOD.listeners[i].callback == callback then
            table.remove(TOD.listeners, i)
        end
    end

    table.insert(TOD.listeners, sub)

    if not TOD.isUpdaterRegistered then
        TOD.startUpdater()
        TOD.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #TOD.listeners, 1, -1 do
        if TOD.listeners[i] == sub then
            table.remove(TOD.listeners, i)
            break
        end
    end

    if #TOD.listeners == 0 and TOD.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(TOD.updaterFn)
        TOD.isUpdaterRegistered = false
    end
end

function TOD.startUpdater()
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.TimeOfDayThresholdReached")
    local fn = function()
        local ok, hour = pcall(KCDUtils.System.GetTimeOfDayHour)
        if not ok or not hour then return end

        for i = #TOD.listeners, 1, -1 do
            local sub = TOD.listeners[i]
            if not sub.isPaused and not sub.triggered then
                if hour >= sub.targetHour then
                    local success, err = pcall(sub.callback, hour)
                    if not success then
                        logger:Error("Callback error: " .. tostring(err))
                    end
                    sub.triggered = true
                    if sub.once then
                        removeListener(sub)
                    end
                end
            end
        end
    end

    TOD.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

--- TimeOfDayThresholdReached Event
--- Fires when the in-game time reaches or exceeds a target hour
---
--- @param config table Configuration for the event:
---               targetHour = number Hour of the day to trigger
---               once = boolean (optional, default false)
--- @param callback fun(hour:number) Function called when target hour is reached
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
KCDUtils.Events.TimeOfDayThresholdReached.Add = function(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.TimeOfDayThresholdReached.Remove = function(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.TimeOfDayThresholdReached.Pause = function(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.TimeOfDayThresholdReached.Resume = function(subscription)
    if subscription then subscription.isPaused = false end
end
