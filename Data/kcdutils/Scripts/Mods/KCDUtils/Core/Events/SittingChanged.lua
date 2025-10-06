KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.SittingChanged = KCDUtils.Events.SittingChanged or {}

local CSC = KCDUtils.Events.SittingChanged

CSC.listeners = CSC.listeners or {}
CSC.isUpdaterRegistered = CSC.isUpdaterRegistered or false
CSC.updaterFn = CSC.updaterFn or nil

local function addListener(config, callback)
    config = config or {}
    local trigger = config.trigger or "both"
    local sub = {
        callback = callback,
        once = config.once == true,
        lastState = nil,
        isPaused = false,
        trigger = trigger,
        pausedState = nil
    }

    for i = #CSC.listeners, 1, -1 do
        if CSC.listeners[i].callback == callback then
            table.remove(CSC.listeners, i)
        end
    end

    table.insert(CSC.listeners, sub)

    if not CSC.isUpdaterRegistered then
        CSC.startUpdater()
        CSC.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #CSC.listeners, 1, -1 do
        if CSC.listeners[i] == sub then
            table.remove(CSC.listeners, i)
            break
        end
    end

    if #CSC.listeners == 0 and CSC.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(CSC.updaterFn)
        CSC.isUpdaterRegistered = false
    end
end

function CSC.startUpdater()
    local fn = function(deltaTime)
        if not player or not player.soul then return end

        local isSitting = player.player:IsSitting()
        if isSitting == nil then return end

        for i = #CSC.listeners, 1, -1 do
            local sub = CSC.listeners[i]

            if sub.isPaused then
                sub.pausedState = isSitting
            else
                local effectiveLastState = sub.pausedState or sub.lastState

                if effectiveLastState ~= nil and isSitting ~= effectiveLastState then
                    local shouldTrigger = false
                    if sub.trigger == "both" then
                        shouldTrigger = true
                    elseif sub.trigger == "entry" and isSitting then
                        shouldTrigger = true
                    elseif sub.trigger == "exit" and not isSitting then
                        shouldTrigger = true
                    end

                    if shouldTrigger then
                        sub.callback({
                            isSitting = isSitting,
                            player = player
                        })
                        if sub.once then
                            removeListener(sub)
                        end
                    end
                end

                sub.lastState = isSitting
                sub.pausedState = nil
            end
        end
    end

    CSC.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

--- SittingChanged Event
--- Fires when the player's sitting state changes
---
--- @param config table Configuration for the event:
---               trigger = "entry" | "exit" | "both" (default "both")
---               once = boolean (optional, default false)
--- @param callback fun(eventData:{inCombat:boolean, player:table}) Function called when event triggers
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
function KCDUtils.Events.SittingChanged.Add(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
function KCDUtils.Events.SittingChanged.Remove(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
function KCDUtils.Events.SittingChanged.Pause(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
function KCDUtils.Events.SittingChanged.Resume(subscription)
    if subscription then subscription.isPaused = false end
end