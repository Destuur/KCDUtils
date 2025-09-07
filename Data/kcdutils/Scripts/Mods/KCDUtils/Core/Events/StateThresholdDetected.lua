KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or { Name = "KCDUtils.Events" }
KCDUtils.Events.StateThresholdDetected = KCDUtils.Events.StateThresholdDetected or {}

KCDUtils.Events.StateThresholdDetected.listeners = KCDUtils.Events.StateThresholdDetected.listeners or {}
KCDUtils.Events.StateThresholdDetected.isUpdaterRegistered = KCDUtils.Events.StateThresholdDetected.isUpdaterRegistered or false
KCDUtils.Events.StateThresholdDetected.updaterFn = KCDUtils.Events.StateThresholdDetected.updaterFn or nil

--- Registers a listener for a soul state threshold event.
---
--- #### Examples:
--- ```lua
--- -- Fire when health drops below 30
--- KCDUtils.Events.StateThresholdDetected.Add({
---     soulState = "health",
---     threshold = 30,
---     direction = "below"
--- }, function(value)
---     System.LogAlways("Health is now below 30: " .. value)
--- end)
---
--- -- Fire when stamina rises above 75
--- KCDUtils.Events.StateThresholdDetected.Add({
---     soulState = "stamina",
---     threshold = 75,
---     direction = "above"
--- }, function(value)
---     System.LogAlways("Stamina is now above 75: " .. value)
--- end)
--- ```
---
---@param config table Configuration table:
---        Fields:
---        config.soulState string -> Name of the soul state to monitor (e.g., "health", "stamina", "hunger") (required)
---        config.threshold number -> The threshold value to compare against (required)
---        config.direction '"above"' | '"below"' -> The direction to monitor (above or below the threshold) (required)
---@param callback fun(value:number) Callback function invoked when the threshold is crossed. Passes the current value.
---@return table? subscription Returns the subscription object that can be removed via Remove()
function KCDUtils.Events.StateThresholdDetected.Add(config, callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.StateThresholdDetected")

    if type(config) ~= "table" or type(callback) ~= "function" then
        logger:Error("Add: config must be a table and callback must be a function")
        return nil
    end

    if type(config.soulState) ~= "string" or type(config.threshold) ~= "number" or 
       (config.direction ~= "above" and config.direction ~= "below") then
        logger:Error("Add: Invalid config values. soulState(string), threshold(number), direction('above'|'below') required")
        return nil
    end

    local newSub = {
        soulState = config.soulState,
        threshold = config.threshold,
        direction = config.direction,
        callback = callback,
        isPaused = false,
        pausedValueOffset = nil,
        lastTriggered = nil
    }

    table.insert(KCDUtils.Events.StateThresholdDetected.listeners, newSub)

    if not KCDUtils.Events.StateThresholdDetected.isUpdaterRegistered then
        KCDUtils.Events.StateThresholdDetected:startUpdater()
        KCDUtils.Events.StateThresholdDetected.isUpdaterRegistered = true
    end

    return newSub
end

function KCDUtils.Events.StateThresholdDetected.Remove(sub)
    for i, s in ipairs(KCDUtils.Events.StateThresholdDetected.listeners) do
        if s == sub then
            table.remove(KCDUtils.Events.StateThresholdDetected.listeners, i)
            break
        end
    end
    if #KCDUtils.Events.StateThresholdDetected.listeners == 0 and KCDUtils.Events.StateThresholdDetected.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(KCDUtils.Events.StateThresholdDetected.updaterFn)
        KCDUtils.Events.StateThresholdDetected.isUpdaterRegistered = false
    end
end

function KCDUtils.Events.StateThresholdDetected.Pause(sub)
    if sub then sub.isPaused = true end
end

function KCDUtils.Events.StateThresholdDetected.Resume(sub)
    if sub then
        sub.isPaused = false
        sub.pausedValueOffset = nil
    end
end

function KCDUtils.Events.StateThresholdDetected:startUpdater()
    local fn = function(deltaTime)
        deltaTime = deltaTime or 1.0
        local player = KCDUtils.Entities.Player:Get()
        if not player or not player.soul then return end

        for _, sub in ipairs(KCDUtils.Events.StateThresholdDetected.listeners) do
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

    KCDUtils.Events.StateThresholdDetected.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end