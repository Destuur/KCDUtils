KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.StateThresholdDetected = KCDUtils.Events.StateThresholdDetected or {}

local STD = KCDUtils.Events.StateThresholdDetected

STD.listeners = STD.listeners or {}
STD.isUpdaterRegistered = STD.isUpdaterRegistered or false
STD.updaterFn = STD.updaterFn or nil

local function addListener(config, callback)
    config = config or {}

    local sub = {
        soulState = config.soulState,
        threshold = config.threshold,
        direction = config.direction, -- "above" | "below"
        callback = callback,
        isPaused = false,
        pausedValueOffset = nil,
        lastTriggered = nil
    }

    for i = #STD.listeners, 1, -1 do
        if STD.listeners[i].callback == callback then
            table.remove(STD.listeners, i)
        end
    end

    table.insert(STD.listeners, sub)

    if not STD.isUpdaterRegistered then
        STD.startUpdater()
        STD.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #STD.listeners, 1, -1 do
        if STD.listeners[i] == sub then
            table.remove(STD.listeners, i)
            break
        end
    end

    if #STD.listeners == 0 and STD.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(STD.updaterFn)
        STD.isUpdaterRegistered = false
    end
end

function STD.startUpdater()
    local fn = function(deltaTime)
        deltaTime = deltaTime or 1.0
        if not player or not player.soul then return end

        for i = #STD.listeners, 1, -1 do
            local sub = STD.listeners[i]
            local value = player.soul:GetState(sub.soulState)
            if value then
                if sub.isPaused then
                    sub.pausedValueOffset = value
                else
                    local effectiveValue = sub.pausedValueOffset or value
                    local triggered = (sub.direction == "below" and effectiveValue < sub.threshold)
                                   or (sub.direction == "above" and effectiveValue > sub.threshold)

                    if sub.lastTriggered == nil then
                        sub.lastTriggered = triggered
                    elseif triggered and not sub.lastTriggered then
                        sub.callback(value)
                        sub.lastTriggered = true
                    elseif not triggered then
                        sub.lastTriggered = false
                    end

                    sub.pausedValueOffset = nil
                end
            end
        end
    end

    STD.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

--- StateThresholdDetected Event
--- Fires when a soul state crosses a threshold
---
--- @param config table Configuration for the event:
---               soulState = string The soul state to track
---               threshold = number The threshold value
---               direction = "above" | "below" (required)
--- @param callback fun(value:number) Function called when threshold is crossed
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
KCDUtils.Events.StateThresholdDetected.Add = function(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.StateThresholdDetected.Remove = function(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.StateThresholdDetected.Pause = function(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.StateThresholdDetected.Resume = function(subscription)
    if subscription then
        subscription.isPaused = false
        subscription.pausedValueOffset = nil
    end
end
