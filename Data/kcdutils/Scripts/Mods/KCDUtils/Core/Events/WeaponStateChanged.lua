KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.WeaponStateChanged = KCDUtils.Events.WeaponStateChanged or {}

local WSC = KCDUtils.Events.WeaponStateChanged

WSC.listeners = WSC.listeners or {}
WSC.isUpdaterRegistered = WSC.isUpdaterRegistered or false
WSC.updaterFn = WSC.updaterFn or nil

local function addListener(config, callback)
    config = config or {}

    local sub = {
        callback = callback,
        trigger = config.trigger or "both", -- "draw" | "sheath" | "both"
        once = config.once == true,
        lastState = nil,
        isPaused = false
    }

    for i = #WSC.listeners, 1, -1 do
        if WSC.listeners[i].callback == callback then
            table.remove(WSC.listeners, i)
        end
    end

    table.insert(WSC.listeners, sub)

    if not WSC.isUpdaterRegistered then
        WSC.startUpdater()
        WSC.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #WSC.listeners, 1, -1 do
        if WSC.listeners[i] == sub then
            table.remove(WSC.listeners, i)
            break
        end
    end

    if #WSC.listeners == 0 and WSC.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(WSC.updaterFn)
        WSC.isUpdaterRegistered = false
    end
end

function WSC.startUpdater()
    local fn = function(deltaTime)
        if not player or not player.human then return end

        local isDrawn = player.human:IsWeaponDrawn()
        if isDrawn == nil then return end

        for i = #WSC.listeners, 1, -1 do
            local sub = WSC.listeners[i]
            if not sub.isPaused then
                if sub.lastState ~= nil and sub.lastState ~= isDrawn then
                    local triggerEvent = false
                    if sub.trigger == "both" then
                        triggerEvent = true
                    elseif sub.trigger == "draw" and isDrawn then
                        triggerEvent = true
                    elseif sub.trigger == "sheath" and not isDrawn then
                        triggerEvent = true
                    end

                    if triggerEvent then
                        sub.callback({ isDrawn = isDrawn, player = player })
                        if sub.once then
                            removeListener(sub)
                        end
                    end
                end
                sub.lastState = isDrawn
            end
        end
    end

    WSC.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

--- WeaponStateChanged Event
--- Fires when the player draws or sheaths a weapon
---
--- @param config table Configuration for the event:
---               trigger = "draw" | "sheath" | "both" (default "both")
---               once = boolean (optional, default false)
--- @param callback fun(eventData:{isDrawn:boolean, player:table}) Function called when weapon state changes
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
KCDUtils.Events.WeaponStateChanged.Add = function(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.WeaponStateChanged.Remove = function(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.WeaponStateChanged.Pause = function(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.WeaponStateChanged.Resume = function(subscription)
    if subscription then subscription.isPaused = false end
end
