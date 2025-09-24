KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.UnderRoofChanged = KCDUtils.Events.UnderRoofChanged or {}

local URC = KCDUtils.Events.UnderRoofChanged

URC.listeners = URC.listeners or {}
URC.isUpdaterRegistered = URC.isUpdaterRegistered or false
URC.updaterFn = URC.updaterFn or nil

local function addListener(config, callback)
    config = config or {}
    local direction = config.direction or "both"
    local sub = {
        callback = callback,
        once = config.once == true,
        lastState = nil,
        isPaused = false,
        direction = direction
    }

    for i = #URC.listeners, 1, -1 do
        if URC.listeners[i].callback == callback then
            table.remove(URC.listeners, i)
        end
    end

    table.insert(URC.listeners, sub)

    if not URC.isUpdaterRegistered then
        URC.startUpdater()
        URC.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #URC.listeners, 1, -1 do
        if URC.listeners[i] == sub then
            table.remove(URC.listeners, i)
            break
        end
    end

    if #URC.listeners == 0 and URC.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(URC.updaterFn)
        URC.isUpdaterRegistered = false
    end
end

function URC.startUpdater()
    local fn = function(deltaTime)
        if not player then return end
        local pos = player:GetWorldPos()
        local rayStart = { x = pos.x, y = pos.y, z = pos.z + 1.8 }
        local hits = Physics.RayWorldIntersection(rayStart, {x=0, y=0, z=3}, 1, ent_all, player.id)
        local isUnderRoof = hits and #hits > 0 and hits[1].surface

        for i = #URC.listeners, 1, -1 do
            local sub = URC.listeners[i]
            if not sub.isPaused then
                if sub.lastState == nil then
                    sub.lastState = isUnderRoof
                else
                    local triggerEnter = (sub.direction == "enter" or sub.direction == "both") and isUnderRoof and not sub.lastState
                    local triggerLeave = (sub.direction == "leave" or sub.direction == "both") and not isUnderRoof and sub.lastState
                    if triggerEnter or triggerLeave then
                        sub.callback(isUnderRoof)
                        if sub.once then removeListener(sub) end
                    end
                    sub.lastState = isUnderRoof
                end
            end
        end
    end

    URC.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

--- UnderRoofChanged Event
--- Fires when the player goes under or leaves a roof
---
--- @param config table Configuration for the event:
---               direction = "enter" | "leave" | "both" (default "both")
---               once = boolean (optional, default false)
--- @param callback fun(isUnderRoof:boolean) Function called when event triggers
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
function KCDUtils.Events.UnderRoofChanged.Add(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
function KCDUtils.Events.UnderRoofChanged.Remove(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
function KCDUtils.Events.UnderRoofChanged.Pause(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
function KCDUtils.Events.UnderRoofChanged.Resume(subscription)
    if subscription then subscription.isPaused = false end
end
