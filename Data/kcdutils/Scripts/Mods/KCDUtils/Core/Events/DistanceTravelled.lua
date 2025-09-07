KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or { Name = "KCDUtils.Events" }
KCDUtils.Events.DistanceTravelled = KCDUtils.Events.DistanceTravelled or {}

KCDUtils.Events.DistanceTravelled.listeners = KCDUtils.Events.DistanceTravelled.listeners or {}
KCDUtils.Events.DistanceTravelled.isUpdaterRegistered = KCDUtils.Events.DistanceTravelled.isUpdaterRegistered or false
KCDUtils.Events.DistanceTravelled.updaterFn = KCDUtils.Events.DistanceTravelled.updaterFn or nil

--- Registers a listener that triggers when the player has traveled a certain distance.
---
--- #### Example:
--- ```lua
--- KCDUtils.Events.DistanceTravelled.Add({ triggerDistance = 10 }, function(eventData)
---     System.LogAlways("Player traveled " .. eventData.distance .. " units!")
--- end)
--- ```
--- @param config table Optional configuration table:
---        config.triggerDistance number -> Distance in game units after which callback is triggered (default 0).
--- @param callback fun(eventData:table) Callback function called when distance threshold is reached.
---        `eventData` contains:
---        - distance: total distance traveled since tracker started
---        - speed: current movement speed (units per second)
---        - position: current player position {x, y, z}
--- @return table|nil subscription object, can be removed with `DistanceTravelled.Remove`
function KCDUtils.Events.DistanceTravelled.Add(config, callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.DistanceTravelled")
    if type(callback) ~= "function" then
        logger:Error("Add: callback must be a function")
        return nil
    end

    config = config or {}
    local newSub = {
        callback = callback,
        isPaused = false,
        lastTriggerDistance = 0,
        pausedDistanceOffset = nil,
        triggerDistance = config.triggerDistance or 0
    }

    table.insert(KCDUtils.Events.DistanceTravelled.listeners, newSub)

    if not KCDUtils.Events.DistanceTravelled.isUpdaterRegistered then
        KCDUtils.Events.DistanceTravelled.startUpdater()
        KCDUtils.Events.DistanceTravelled.isUpdaterRegistered = true
    end

    return newSub
end

--- Removes a previously registered subscription.
--- @param subscription table The subscription returned from `Add`.
function KCDUtils.Events.DistanceTravelled.Remove(subscription)
    for i, sub in ipairs(KCDUtils.Events.DistanceTravelled.listeners) do
        if sub == subscription then
            table.remove(KCDUtils.Events.DistanceTravelled.listeners, i)
            break
        end
    end
    if #KCDUtils.Events.DistanceTravelled.listeners == 0 and KCDUtils.Events.DistanceTravelled.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(KCDUtils.Events.DistanceTravelled.updaterFn)
        KCDUtils.Events.DistanceTravelled.isUpdaterRegistered = false
    end
end

--- Pauses a subscription temporarily.
--- @param subscription table Subscription returned from `Add`.
function KCDUtils.Events.DistanceTravelled.Pause(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resumes a previously paused subscription.
--- @param subscription table Subscription returned from `Add`.
function KCDUtils.Events.DistanceTravelled.Resume(subscription)
    if subscription then
        subscription.isPaused = false
        subscription.pausedDistanceOffset = nil
    end
end

--- Internal updater function. Tracks player distance every frame.
function KCDUtils.Events.DistanceTravelled.startUpdater()
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

        for _, sub in ipairs(KCDUtils.Events.DistanceTravelled.listeners) do
            if not sub.isPaused then
                local effectiveLast = sub.pausedDistanceOffset or sub.lastTriggerDistance
                if data.distance - effectiveLast >= sub.triggerDistance then
                    sub.callback(data)
                    sub.lastTriggerDistance = data.distance
                    sub.pausedDistanceOffset = nil
                end
            else
                sub.pausedDistanceOffset = sub.lastTriggerDistance
            end
        end
    end

    KCDUtils.Events.DistanceTravelled.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end