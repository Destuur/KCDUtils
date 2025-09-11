KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.DistanceTravelled = KCDUtils.Events.DistanceTravelled or {}

local DT = KCDUtils.Events.DistanceTravelled

DT.listeners = DT.listeners or {}
DT.isUpdaterRegistered = DT.isUpdaterRegistered or false
DT.updaterFn = DT.updaterFn or nil

DT._needsReset = true

local function addListener(config, callback)
    config = config or {}

    for i = #DT.listeners, 1, -1 do
        if DT.listeners[i].callback == callback then
            table.remove(DT.listeners, i)
        end
    end

    local sub = {
        callback = callback,
        triggerDistance = config.triggerDistance or 0,
        lastPos = nil,
        accumulatedDistance = 0,
        isPaused = false,
        initialized = false
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

function DT.ResetListeners()
    for i = 1, #DT.listeners do
        local sub = DT.listeners[i]
        sub.lastPos = nil
        sub.accumulatedDistance = 0
        sub.initialized = false
    end
end

function DT.startUpdater()
    local fn = function(deltaTime)
        if not player then return end

        if DT._needsReset then
            DT.ResetListeners()
            DT._needsReset = false
        end

        local pos = KCDUtils.Math.GetPlayerPosition(player)
        if not pos then return end

        for i = #DT.listeners, 1, -1 do
            local sub = DT.listeners[i]
            if not sub.isPaused then
                if not sub.initialized then
                    sub.lastPos = pos
                    sub.accumulatedDistance = 0
                    sub.initialized = true
                else
                    local dist = KCDUtils.Math.CalculateDistance(sub.lastPos, pos, true)
                    sub.accumulatedDistance = sub.accumulatedDistance + dist

                    if sub.accumulatedDistance >= sub.triggerDistance then
                        sub.callback({
                            distance = sub.accumulatedDistance,
                            position = pos
                        })
                        sub.accumulatedDistance = 0
                    end

                    sub.lastPos = pos
                end
            end
        end
    end

    DT.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

--- DistanceTravelled Event
--- Fires when the player has moved a certain distance
---
--- @param config table Configuration for the event:
---               triggerDistance = number Minimum distance to trigger
--- @param callback fun(eventData:{distance:number, position:table}) Function called when triggerDistance is reached
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
KCDUtils.Events.DistanceTravelled.Add = function(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.DistanceTravelled.Remove = function(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.DistanceTravelled.Pause = function(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.DistanceTravelled.Resume = function(subscription)
    if subscription then subscription.isPaused = false end
end
