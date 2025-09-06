KCDUtils = KCDUtils
---@class KCDUtilsEvents
KCDUtils.Events = KCDUtils.Events
KCDUtils.Events.DistanceTravelled = KCDUtils.Events.DistanceTravelled or {}

-- Ein interner Zustand für das Event-Objekt
KCDUtils.Events.DistanceTravelled.listeners = {}
KCDUtils.Events.DistanceTravelled.isUpdaterRegistered = false
KCDUtils.Events.DistanceTravelled.updaterFn = nil

-- Fügt eine neue Subscription hinzu
function KCDUtils.Events.DistanceTravelled.Add(callback, config)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.DistanceTravelled")
    if type(callback) ~= "function" then
        logger:Error("Add: callback must be a function")
        return nil
    end

    local newSubscription = {
        callback = callback,
        isPaused = false,
        lastTriggerDistance = 0,
        triggerDistance = (config and config.triggerDistance) or 0
    }
    
    logger:Info("New DistanceTravelled subscription added with triggerDistance: " .. newSubscription.triggerDistance)
    table.insert(KCDUtils.Events.DistanceTravelled.listeners, newSubscription)
    
    if not KCDUtils.Events.DistanceTravelled.isUpdaterRegistered then
        KCDUtils.Events.DistanceTravelled:startUpdater()
        KCDUtils.Events.DistanceTravelled.isUpdaterRegistered = true
    end

    logger:Info("DistanceTravelled subscription added.")
    return newSubscription
end

-- Entfernt eine Subscription
function KCDUtils.Events.DistanceTravelled.Remove(subscription)
    local listeners = KCDUtils.Events.DistanceTravelled.listeners
    for i, sub in ipairs(listeners) do
        if sub == subscription then
            table.remove(listeners, i)
            break
        end
    end

    -- Stoppt den Updater, wenn keine Subscriber mehr vorhanden sind
    if #listeners == 0 and KCDUtils.Events.DistanceTravelled.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(KCDUtils.Events.DistanceTravelled.updaterFn)
        KCDUtils.Events.DistanceTravelled.isUpdaterRegistered = false
    end
end

-- Interne Methode, die den Updater startet und die Berechnungslogik enthält
function KCDUtils.Events.DistanceTravelled:startUpdater()
    local lastPosition = nil
    local totalDistance = 0
    local minDistanceFilter = 0.05

    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.DistanceTravelled")
    logger:Info("DistanceTravelled updater started.")
    local fn = function(deltaTime)
        deltaTime = deltaTime or 1.0
        local player = KCDUtils.Entities.Player:Get()
        if not player then return end

        local pos = KCDUtils.Math.GetPlayerPosition(player._raw)
        if not pos then return end

        local dist = 0
        if lastPosition then
            dist = KCDUtils.Math.CalculateDistance(lastPosition, pos)
            if dist > minDistanceFilter then
                totalDistance = totalDistance + dist
            end
        end
        lastPosition = pos

        local speed = dist / deltaTime  -- Rohgeschwindigkeit, unabhängig vom Filter
        local data = {
            distance = totalDistance,
            speed = speed,
            position = pos
        }

        for _, subscription in ipairs(self.listeners) do
            if not subscription.isPaused then
                if data.distance - subscription.lastTriggerDistance >= subscription.triggerDistance then
                    subscription.callback(data)
                    subscription.lastTriggerDistance = data.distance
                end
            end
        end
    end

    KCDUtils.Events.DistanceTravelled.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end