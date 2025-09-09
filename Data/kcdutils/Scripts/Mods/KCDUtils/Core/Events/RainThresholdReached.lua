-- ============================================================================ 
-- KCDUtils.Events.RainIntensityThresholdReached (Reload-sicher)
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.RainThresholdReached = KCDUtils.Events.RainThresholdReached or {}

local RITR = KCDUtils.Events.RainThresholdReached

RITR.listeners = RITR.listeners or {}
RITR.isUpdaterRegistered = RITR.isUpdaterRegistered or false
RITR.updaterFn = RITR.updaterFn or nil

-- Interne Add/Remove Methoden
local function addListener(config, callback)
    config = config or {}
    local sub = {
        callback = callback,
        threshold = config.threshold or 0,
        direction = config.direction or "both",
        once = config.once or false,
        lastTriggeredAbove = nil,
        lastTriggeredBelow = nil,
        isPaused = false
    }

    table.insert(RITR.listeners, sub)
    if not RITR.isUpdaterRegistered then
        RITR.startUpdater()
        RITR.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #RITR.listeners, 1, -1 do
        if RITR.listeners[i] == sub then
            table.remove(RITR.listeners, i)
            break
        end
    end
    if #RITR.listeners == 0 and RITR.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(RITR.updaterFn)
        RITR.isUpdaterRegistered = false
    end
end

RITR.Pause = function(sub) if sub then sub.isPaused = true end end
RITR.Resume = function(sub) if sub then sub.isPaused = false end end

function RITR.startUpdater()
    local fn = function(deltaTime)
        deltaTime = deltaTime or 1.0
        local ok, rain = pcall(EnvironmentModule.GetRainIntensity)
        if not ok or rain == nil then return end

        for i = #RITR.listeners, 1, -1 do
            local sub = RITR.listeners[i]
            if not sub.isPaused then
                local removed = false

                if sub.direction == "above" or sub.direction == "both" then
                    local triggeredAbove = rain > sub.threshold
                    if sub.lastTriggeredAbove == nil then
                        sub.lastTriggeredAbove = triggeredAbove
                    elseif triggeredAbove and sub.lastTriggeredAbove ~= true then
                        sub.callback({
                            triggered = true,
                            intensity = rain
                        })
                        sub.lastTriggeredAbove = true
                        if sub.once then removeListener(sub) removed = true end
                    elseif not triggeredAbove then
                        sub.lastTriggeredAbove = false
                    end
                end

                if not removed and (sub.direction == "below" or sub.direction == "both") then
                    local triggeredBelow = rain < sub.threshold
                    if sub.lastTriggeredBelow == nil then
                        sub.lastTriggeredBelow = triggeredBelow
                    elseif triggeredBelow and sub.lastTriggeredBelow ~= true then
                        sub.callback({
                            triggered = true,
                            intensity = rain
                        })
                        sub.lastTriggeredBelow = true
                        if sub.once then removeListener(sub) end
                    elseif not triggeredBelow then
                        sub.lastTriggeredBelow = false
                    end
                end
            end
        end
    end

    RITR.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

-- Reload-sichere Add/Remove Funktionen für Modder
function RITR.Add(config, callback)
    return addListener(config, callback)
end

function RITR.Remove(sub)
    return removeListener(sub)
end