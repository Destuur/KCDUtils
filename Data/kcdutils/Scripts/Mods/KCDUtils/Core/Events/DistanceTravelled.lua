-- ============================================================================ 
-- KCDUtils.Events.DistanceTravelled (Reload-sicher)
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.DistanceTravelled = KCDUtils.Events.DistanceTravelled or {}

local DT = KCDUtils.Events.DistanceTravelled

DT.listeners = DT.listeners or {}
DT.isUpdaterRegistered = DT.isUpdaterRegistered or false
DT.updaterFn = DT.updaterFn or nil

-- Interne Add/Remove Methoden
local function addListener(config, callback)
    config = config or {}
    local sub = {
        callback = callback,
        once = config.once == true,
        lastTriggerDistance = 0,
        pausedDistanceOffset = nil,
        triggerDistance = config.triggerDistance or 0,
        isPaused = false
    }
    table.insert(DT.listeners, sub)
    if not DT.isUpdaterRegistered then
        DT.startUpdater()
        DT.isUpdaterRegistered = true
    end
    return sub
end

local function removeListener(sub)
    for i = #DT.listeners, 1, -1 do
        if DT.listeners[i] == sub then
            table.remove(DT.listeners, i)
            break
        end
    end
    if #DT.listeners == 0 and DT.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(DT.updaterFn)
        DT.isUpdaterRegistered = false
    end
end

DT.Pause = function(sub) if sub then sub.isPaused = true end end
DT.Resume = function(sub)
    if sub then
        sub.isPaused = false
        sub.pausedDistanceOffset = nil
    end
end

function DT.startUpdater()
    local lastPos = nil
    local totalDistance = 0
    local minDistanceFilter = 0.05

    local fn = function(deltaTime)
        deltaTime = deltaTime or 1.0
        if not player then return end

        local pos = KCDUtils.Math.GetPlayerPosition(player)
        if not pos then return end

        local dist = 0
        if lastPos then
            dist = KCDUtils.Math.CalculateDistance(lastPos, pos)
            if dist > minDistanceFilter then
                totalDistance = totalDistance + dist
            end
        end
        lastPos = pos

        local speed = dist / deltaTime
        local data = { distance = totalDistance, speed = speed, position = pos }

        for i = #DT.listeners, 1, -1 do
            local sub = DT.listeners[i]
            if not sub.isPaused then
                local effectiveLast = sub.pausedDistanceOffset or sub.lastTriggerDistance
                if data.distance - effectiveLast >= sub.triggerDistance then
                    sub.callback(data)
                    sub.lastTriggerDistance = data.distance
                    sub.pausedDistanceOffset = nil
                    if sub.once then removeListener(sub) end
                end
            else
                sub.pausedDistanceOffset = sub.lastTriggerDistance
            end
        end
    end

    DT.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

-- Reload-sichere Add/Remove Funktionen für Modder
function DT.Add(config, callback)
    return addListener(config, callback)
end

function DT.Remove(sub)
    return removeListener(sub)
end
