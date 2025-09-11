KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.NearbyEntitiesDetected = KCDUtils.Events.NearbyEntitiesDetected or {}

local NED = KCDUtils.Events.NearbyEntitiesDetected

NED.listeners = NED.listeners or {}
NED.isUpdaterRegistered = NED.isUpdaterRegistered or false
NED.updaterFn = NED.updaterFn or nil

local function addListener(config, callback)
    config = config or {}

    for i = #NED.listeners, 1, -1 do
        if NED.listeners[i].callback == callback then
            table.remove(NED.listeners, i)
        end
    end

    local sub = {
        callback = callback,
        radius = config.radius or 10.0,
        entityClass = config.entityClass or nil,
        isPaused = false
    }

    table.insert(NED.listeners, sub)

    if not NED.isUpdaterRegistered then
        NED.startUpdater()
        NED.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #NED.listeners, 1, -1 do
        if NED.listeners[i] == sub then
            table.remove(NED.listeners, i)
            break
        end
    end
    if #NED.listeners == 0 and NED.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(NED.updaterFn)
        NED.isUpdaterRegistered = false
    end
end

function NED.startUpdater()
    local fn = function()
        if not player then return end

        local pos = KCDUtils.Math.GetPlayerPosition(player)
        if not pos then return end

        for i = #NED.listeners, 1, -1 do
            local sub = NED.listeners[i]
            if not sub.isPaused then
                local ok, entities
                if sub.entityClass then
                    ok, entities = pcall(System.GetEntitiesInSphereByClass, pos, sub.radius, sub.entityClass)
                else
                    ok, entities = pcall(System.GetEntitiesInSphere, pos, sub.radius)
                end

                entities = (ok and entities) or {}

                local data = {
                    entities = entities,
                    position = pos,
                    radius = sub.radius,
                    entityClass = sub.entityClass
                }

                local success, err = pcall(sub.callback, data)
                if not success then
                    KCDUtils.Logger.Factory("KCDUtils.Events.NearbyEntitiesDetected"):Error(
                        "Callback error: " .. tostring(err)
                    )
                end
            end
        end
    end

    NED.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

--- NearbyEntitiesDetected Event
--- Fires when entities are detected within a radius around the player
---
--- @param config table Configuration for the event:
---               radius = number Detection radius around player
---               entityClass = string Class of entities to detect (optional; nil = all entities)
--- @param callback fun(data:table) Function called when entities are detected.
---                     data.entities = table List of detected entities
---                     data.position = table Player position where scan occurred
---                     data.radius = number Detection radius used
---                     data.entityClass = string Class used for filtering (nil = all entities)
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
KCDUtils.Events.NearbyEntitiesDetected.Add = function(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.NearbyEntitiesDetected.Remove = function(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.NearbyEntitiesDetected.Pause = function(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.NearbyEntitiesDetected.Resume = function(subscription)
    if subscription then subscription.isPaused = false end
end
