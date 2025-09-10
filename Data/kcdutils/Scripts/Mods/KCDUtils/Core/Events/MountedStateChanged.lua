-- ============================================================================
-- KCDUtils.Events.MountedStateChanged (Reload-sicher)
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.MountedStateChanged = KCDUtils.Events.MountedStateChanged or {}

local MSC = KCDUtils.Events.MountedStateChanged

MSC.listeners = MSC.listeners or {}
MSC.isUpdaterRegistered = MSC.isUpdaterRegistered or false
MSC.updaterFn = MSC.updaterFn or nil
MSC.lastState = MSC.lastState or nil

-- =====================================================================
-- Interne Helfer
-- =====================================================================

local function addListener(config, callback)
    config = config or {}
    local sub = {
        callback = callback,
        config = {
            direction = config.direction or "both", -- "mounted" | "dismounted" | "both"
            once = config.once or false
        },
        isPaused = false
    }

    -- Cleanup: alte Listener entfernen
    for i = #MSC.listeners, 1, -1 do
        if MSC.listeners[i].callback == callback then
            table.remove(MSC.listeners, i)
        end
    end

    table.insert(MSC.listeners, sub)

    if not MSC.isUpdaterRegistered then
        MSC.startUpdater()
        MSC.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #MSC.listeners, 1, -1 do
        if MSC.listeners[i] == sub then
            table.remove(MSC.listeners, i)
            break
        end
    end

    if #MSC.listeners == 0 and MSC.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(MSC.updaterFn)
        MSC.isUpdaterRegistered = false
        MSC.lastState = nil
    end
end

-- =====================================================================
-- Updater
-- =====================================================================

function MSC.startUpdater()
    local fn = function(deltaTime)
        if not player or not player.human then return end

        local current = player.human:IsMounted()

        if MSC.lastState == nil then
            MSC.lastState = current
            return
        end

        if current ~= MSC.lastState then
            for i = #MSC.listeners, 1, -1 do
                local sub = MSC.listeners[i]
                if not sub.isPaused then
                    local dirConfig = sub.config.direction
                    local trigger = false
                    local dirStr = current and "mounted" or "dismounted"

                    if current and (dirConfig == "mounted" or dirConfig == "both") then
                        trigger = true
                    elseif not current and (dirConfig == "dismounted" or dirConfig == "both") then
                        trigger = true
                    end

                    if trigger then
                        sub.callback({
                            isMounted = current,
                            wasMounted = MSC.lastState,
                            direction = dirStr
                        })
                        if sub.config.once then removeListener(sub) end
                    end
                end
            end

            MSC.lastState = current
        end
    end

    MSC.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

-- =====================================================================
-- Öffentliche API (mit IntelliSense-kompatiblen Docs!)
-- =====================================================================

--- MountedStateChanged Event
--- Fires when the player's mounted state changes
---
--- @param config table Configuration for the event:
---               direction = "mounted" | "dismounted" | "both" (default "both")
---               once = boolean (optional, default false)
--- @param callback fun(eventData:{isMounted:boolean, wasMounted:boolean, direction:string}) Function called when event triggers
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
KCDUtils.Events.MountedStateChanged.Add = function(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.MountedStateChanged.Remove = function(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.MountedStateChanged.Pause = function(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.MountedStateChanged.Resume = function(subscription)
    if subscription then subscription.isPaused = false end
end
