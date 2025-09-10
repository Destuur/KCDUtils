-- ============================================================================
-- KCDUtils.Events.MoneyThresholdReached (Reload-sicher)
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.MoneyThresholdReached = KCDUtils.Events.MoneyThresholdReached or {}

local MTR = KCDUtils.Events.MoneyThresholdReached

MTR.listeners = MTR.listeners or {}
MTR.isUpdaterRegistered = MTR.isUpdaterRegistered or false
MTR.updaterFn = MTR.updaterFn or nil

-- =====================================================================
-- Interne Helfer
-- =====================================================================

local function addListener(config, callback)
    assert(config.targetAmount, "MoneyThresholdReached requires targetAmount in config")

    -- Cleanup alte Listener mit identischem Callback
    for i = #MTR.listeners, 1, -1 do
        if MTR.listeners[i].callback == callback then
            table.remove(MTR.listeners, i)
        end
    end

    local sub = {
        callback = callback,
        targetAmount = config.targetAmount,
        lastAmount = nil,
        isPaused = false,
        once = config.once or false
    }

    table.insert(MTR.listeners, sub)

    if not MTR.isUpdaterRegistered then
        MTR.startUpdater()
        MTR.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #MTR.listeners, 1, -1 do
        if MTR.listeners[i] == sub then
            table.remove(MTR.listeners, i)
            break
        end
    end
    if #MTR.listeners == 0 and MTR.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(MTR.updaterFn)
        MTR.isUpdaterRegistered = false
    end
end

-- =====================================================================
-- Updater
-- =====================================================================

function MTR.startUpdater()
    local fn = function()
        if not player or not player.inventory then return end

        local ok, money = pcall(player.inventory.GetMoney, player.inventory)
        if not ok or not money then return end

        for i = #MTR.listeners, 1, -1 do
            local sub = MTR.listeners[i]
            if not sub.isPaused then
                if sub.lastAmount == nil then
                    sub.lastAmount = money
                elseif money >= sub.targetAmount and (sub.lastAmount < sub.targetAmount) then
                    local success, err = pcall(sub.callback, {
                        amount = money,
                        previousAmount = sub.lastAmount
                    })
                    if not success then
                        KCDUtils.Logger.Factory("KCDUtils.Events.MoneyThresholdReached"):Error(
                            "Callback error: " .. tostring(err)
                        )
                    end
                    sub.lastAmount = money
                    if sub.once then removeListener(sub) end
                else
                    sub.lastAmount = money
                end
            end
        end
    end

    MTR.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

-- =====================================================================
-- Öffentliche API (IntelliSense-kompatibel)
-- =====================================================================

--- MoneyThresholdReached Event
--- Fires when the player's money reaches or exceeds a target amount
---
--- @param config table Configuration for the event:
---               targetAmount = number Amount to trigger (required)
---               once = boolean Optional, trigger only once
--- @param callback fun(eventData:table) Function called with amount, previousAmount
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
KCDUtils.Events.MoneyThresholdReached.Add = function(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.MoneyThresholdReached.Remove = function(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.MoneyThresholdReached.Pause = function(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.MoneyThresholdReached.Resume = function(subscription)
    if subscription then subscription.isPaused = false end
end
