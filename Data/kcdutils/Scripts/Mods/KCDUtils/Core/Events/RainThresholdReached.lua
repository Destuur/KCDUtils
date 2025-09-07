KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or { Name = "KCDUtils.Events" }
KCDUtils.Events.RainIntensityThresholdReached = KCDUtils.Events.RainIntensityThresholdReached or {}

KCDUtils.Events.RainIntensityThresholdReached.listeners = KCDUtils.Events.RainIntensityThresholdReached.listeners or {}
KCDUtils.Events.RainIntensityThresholdReached.isUpdaterRegistered = KCDUtils.Events.RainIntensityThresholdReached.isUpdaterRegistered or false
KCDUtils.Events.RainIntensityThresholdReached.updaterFn = KCDUtils.Events.RainIntensityThresholdReached.updaterFn or nil

--- Registers a listener that triggers when rain intensity crosses a threshold.
---
--- #### Example:
--- ```lua
--- KCDUtils.Events.RainIntensityThresholdReached.Add({ threshold = 0.5, direction = "above" }, function(intensity)
---     System.LogAlways("Rain intensity rose above 0.5: " .. intensity)
--- end)
---
--- KCDUtils.Events.RainIntensityThresholdReached.Add({ threshold = 0.2, direction = "below", once = true }, function(intensity)
---     System.LogAlways("Rain intensity dropped below 0.2")
--- end)
--- ```
---
--- @param config table Configuration table:
---        config.threshold number -> Rain intensity threshold (0.0–1.0)
---        config.direction '"above"' | '"below"' | '"both"' (default: "both") -> Which direction to trigger on
---        config.once boolean (default: false) -> If true, subscription triggers only once
--- @param callback fun(intensity:number) Callback function invoked when threshold is crossed. `intensity` is the current rain intensity.
--- @return table|nil Subscription object, can be removed with `Remove`
function KCDUtils.Events.RainIntensityThresholdReached.Add(config, callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.RainIntensityThresholdReached")
    if type(callback) ~= "function" then
        logger:Error("Add: callback must be a function")
        return nil
    end
    config = config or {}
    if type(config.threshold) ~= "number" then
        logger:Error("Add: threshold must be a number")
        return nil
    end
    local direction = config.direction or "both"
    if direction ~= "above" and direction ~= "below" and direction ~= "both" then
        logger:Error("Add: direction must be 'above', 'below' or 'both'. Defaulting to 'both'.")
        direction = "both"
    end

    local sub = {
        callback = callback,
        threshold = config.threshold,
        direction = direction,
        once = config.once or false,
        lastTriggeredAbove = nil,
        lastTriggeredBelow = nil,
        isPaused = false
    }

    table.insert(KCDUtils.Events.RainIntensityThresholdReached.listeners, sub)
    logger:Info("New RainIntensityThresholdReached subscription added: " .. sub.direction .. " " .. sub.threshold)

    if not KCDUtils.Events.RainIntensityThresholdReached.isUpdaterRegistered then
        KCDUtils.Events.RainIntensityThresholdReached:startUpdater()
        KCDUtils.Events.RainIntensityThresholdReached.isUpdaterRegistered = true
    end

    return sub
end

--- Removes a previously registered subscription
--- @param subscription table Subscription returned from `Add`
function KCDUtils.Events.RainIntensityThresholdReached.Remove(subscription)
    for i, sub in ipairs(KCDUtils.Events.RainIntensityThresholdReached.listeners) do
        if sub == subscription then
            table.remove(KCDUtils.Events.RainIntensityThresholdReached.listeners, i)
            break
        end
    end

    if #KCDUtils.Events.RainIntensityThresholdReached.listeners == 0 and KCDUtils.Events.RainIntensityThresholdReached.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(KCDUtils.Events.RainIntensityThresholdReached.updaterFn)
        KCDUtils.Events.RainIntensityThresholdReached.isUpdaterRegistered = false
    end
end

--- Pauses a subscription temporarily
--- @param subscription table Subscription returned from `Add`
function KCDUtils.Events.RainIntensityThresholdReached.Pause(subscription)
    subscription.isPaused = true
end

--- Resumes a previously paused subscription
--- @param subscription table Subscription returned from `Add`
function KCDUtils.Events.RainIntensityThresholdReached.Resume(subscription)
    subscription.isPaused = false
end

--- Internal updater function. Checks rain intensity every frame
function KCDUtils.Events.RainIntensityThresholdReached:startUpdater()
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.RainIntensityThresholdReached")
    logger:Info("RainIntensityThresholdReached updater started.")

    local fn = function(deltaTime)
        deltaTime = deltaTime or 1.0
        local ok, rain = pcall(EnvironmentModule.GetRainIntensity)
        if not ok or not rain then return end

        for i = #KCDUtils.Events.RainIntensityThresholdReached.listeners, 1, -1 do
            local sub = KCDUtils.Events.RainIntensityThresholdReached.listeners[i]
            if not sub.isPaused then
                local removed = false

                if sub.direction == "above" or sub.direction == "both" then
                    local triggeredAbove = rain > sub.threshold
                    if sub.lastTriggeredAbove == nil then
                        sub.lastTriggeredAbove = triggeredAbove
                    elseif triggeredAbove and sub.lastTriggeredAbove ~= true then
                        sub.callback(rain)
                        sub.lastTriggeredAbove = true
                        if sub.once then
                            KCDUtils.Events.RainIntensityThresholdReached.Remove(sub)
                            removed = true
                        end
                    elseif not triggeredAbove then
                        sub.lastTriggeredAbove = false
                    end
                end

                if not removed and (sub.direction == "below" or sub.direction == "both") then
                    local triggeredBelow = rain < sub.threshold
                    if sub.lastTriggeredBelow == nil then
                        sub.lastTriggeredBelow = triggeredBelow
                    elseif triggeredBelow and sub.lastTriggeredBelow ~= true then
                        sub.callback(rain)
                        sub.lastTriggeredBelow = true
                        if sub.once then
                            KCDUtils.Events.RainIntensityThresholdReached.Remove(sub)
                        end
                    elseif not triggeredBelow then
                        sub.lastTriggeredBelow = false
                    end
                end
            end
        end
    end

    KCDUtils.Events.RainIntensityThresholdReached.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end
