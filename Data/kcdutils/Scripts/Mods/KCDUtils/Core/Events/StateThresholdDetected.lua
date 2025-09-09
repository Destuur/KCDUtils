-- ============================================================================ 
-- KCDUtils.Events.StateThresholdDetected (Reload-sicher)
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.StateThresholdDetected = KCDUtils.Events.StateThresholdDetected or {}

local STD = KCDUtils.Events.StateThresholdDetected

STD.listeners = STD.listeners or {}
STD.isUpdaterRegistered = STD.isUpdaterRegistered or false
STD.updaterFn = STD.updaterFn or nil

-- Interne Add/Remove Methoden
local function addListener(config, callback)
    config = config or {}

    local sub = {
        soulState = config.soulState,
        threshold = config.threshold,
        direction = config.direction,
        callback = callback,
        isPaused = false,
        pausedValueOffset = nil,
        lastTriggered = nil
    }

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

STD.Pause = function(sub) if sub then sub.isPaused = true end end
STD.Resume = function(sub)
    if sub then
        sub.isPaused = false
        sub.pausedValueOffset = nil
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

-- Reload-sichere Add/Remove für Modder
function STD.Add(config, callback)
    return addListener(config, callback)
end

function STD.Remove(sub)
    return removeListener(sub)
end
