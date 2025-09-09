-- ============================================================================ 
-- KCDUtils.Events.TimeOfDayThresholdReached (Reload-sicher)
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.TimeOfDayThresholdReached = KCDUtils.Events.TimeOfDayThresholdReached or {}

local TOD = KCDUtils.Events.TimeOfDayThresholdReached

TOD.listeners = TOD.listeners or {}
TOD.isUpdaterRegistered = TOD.isUpdaterRegistered or false
TOD.updaterFn = TOD.updaterFn or nil

-- Interne Add/Remove Methoden
local function addListener(config, callback)
    config = config or {}

    local sub = {
        callback = callback,
        targetHour = config.targetHour,
        once = config.once or false,
        triggered = false,
        isPaused = false
    }

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

TOD.Pause = function(sub) if sub then sub.isPaused = true end end
TOD.Resume = function(sub) if sub then sub.isPaused = false end end

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

-- Reload-sichere Add/Remove für Modder
function TOD.Add(config, callback)
    return addListener(config, callback)
end

function TOD.Remove(sub)
    return removeListener(sub)
end