-- ============================================================================
-- KCDUtils.Events.WorldDayOfWeekReached (Reload-sicher)
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.WorldDayOfWeekReached = KCDUtils.Events.WorldDayOfWeekReached or {}

local WD = KCDUtils.Events.WorldDayOfWeekReached

WD.listeners = WD.listeners or {}
WD.isUpdaterRegistered = WD.isUpdaterRegistered or false
WD.updaterFn = WD.updaterFn or nil

-- =====================================================================
-- Interne Helfer
-- =====================================================================

local function addListener(config, callback)
    config = config or {}

    -- Cleanup alte Listener mit identischem Callback
    for i = #WD.listeners, 1, -1 do
        if WD.listeners[i].callback == callback then
            table.remove(WD.listeners, i)
        end
    end

    local sub = {
        callback = callback,
        targetDay = config.targetDay, -- 0=Monday, 6=Sunday
        once = config.once or false,
        lastTriggered = nil,
        isPaused = false
    }

    table.insert(WD.listeners, sub)

    if not WD.isUpdaterRegistered then
        WD.startUpdater()
        WD.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #WD.listeners, 1, -1 do
        if WD.listeners[i] == sub then
            table.remove(WD.listeners, i)
            break
        end
    end
    if #WD.listeners == 0 and WD.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(WD.updaterFn)
        WD.isUpdaterRegistered = false
    end
end

-- =====================================================================
-- Updater
-- =====================================================================

function WD.startUpdater()
    local fn = function()
        local ok, day = pcall(Calendar.GetWorldDayOfWeek)
        if not ok or not day then return end

        for i = #WD.listeners, 1, -1 do
            local sub = WD.listeners[i]
            if not sub.isPaused then
                if sub.lastTriggered ~= day and (sub.targetDay == nil or sub.targetDay == day) then
                    local success, err = pcall(sub.callback, day)
                    if not success then
                        KCDUtils.Logger.Factory("KCDUtils.Events.WorldDayOfWeekReached"):Error(
                            "Callback error: " .. tostring(err)
                        )
                    end
                    sub.lastTriggered = day
                    if sub.once then
                        removeListener(sub)
                    end
                end
            end
        end
    end

    WD.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

-- =====================================================================
-- Öffentliche API (IntelliSense-kompatibel)
-- =====================================================================

--- WorldDayOfWeekReached Event
--- Fires when the in-game day of the week is reached
---
--- @param config table Configuration for the event:
---               targetDay = number (0=Monday ... 6=Sunday) optional
---               once = boolean (optional, default false)
--- @param callback fun(day:number) Function called when the target day is reached
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
KCDUtils.Events.WorldDayOfWeekReached.Add = function(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.WorldDayOfWeekReached.Remove = function(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.WorldDayOfWeekReached.Pause = function(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.WorldDayOfWeekReached.Resume = function(subscription)
    if subscription then subscription.isPaused = false end
end
