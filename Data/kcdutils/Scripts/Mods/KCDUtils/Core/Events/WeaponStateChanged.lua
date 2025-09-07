-- ============================================================================
-- KCDUtils.Events.WeaponStateChanged
-- ============================================================================
-- Event that fires when the player draws or sheaths a weapon.
-- Supports direction-based triggers (draw/sheath/both) and one-time subscriptions.
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.WeaponStateChanged = KCDUtils.Events.WeaponStateChanged or {}

KCDUtils.Events.WeaponStateChanged.listeners = KCDUtils.Events.WeaponStateChanged.listeners or {}
KCDUtils.Events.WeaponStateChanged.isUpdaterRegistered = KCDUtils.Events.WeaponStateChanged.isUpdaterRegistered or false
KCDUtils.Events.WeaponStateChanged.updaterFn = KCDUtils.Events.WeaponStateChanged.updaterFn or nil

--- Adds a subscription to detect weapon draw/sheath events.
---
--- #### Examples:
--- ```lua
--- -- Fires when the weapon is drawn
--- KCDUtils.Events.WeaponStateChanged.Add({ trigger = "draw" }, function(data)
---     System.LogAlways("Weapon drawn!")
--- end)
---
--- -- Fires when the weapon is sheathed
--- KCDUtils.Events.WeaponStateChanged.Add({ trigger = "sheath" }, function(data)
---     System.LogAlways("Weapon sheathed!")
--- end)
---
--- -- Fires on both draw and sheath
--- KCDUtils.Events.WeaponStateChanged.Add({ trigger = "both" }, function(data)
---     if data.isDrawn then
---         System.LogAlways("Weapon drawn")
---     else
---         System.LogAlways("Weapon sheathed")
---     end
--- end)
--- ```
---
---@param config table Configuration table:
---        Fields:
---        config.trigger '"draw"' | '"sheath"' | '"both"' -> When to trigger the callback (default: "both")
---        config.once boolean -> Fire only once? (optional, default: false)
---@param callback fun(data:{isDrawn:boolean, player:table}) Callback invoked on weapon state change.
---@return table? subscription Returns the subscription object that can be removed via Remove()
function KCDUtils.Events.WeaponStateChanged.Add(config, callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.WeaponStateChanged")

    if type(callback) ~= "function" then
        logger:Error("Add: callback must be a function")
        return nil
    end

    config = config or {}
    local trigger = config.trigger or "both"
    if trigger ~= "draw" and trigger ~= "sheath" and trigger ~= "both" then
        logger:Error("Add: invalid trigger. Must be 'draw', 'sheath', or 'both'. Defaulting to 'both'.")
        trigger = "both"
    end

    local sub = {
        callback = callback,
        once = config.once == true,
        lastState = nil,
        isPaused = false,
        trigger = trigger
    }

    table.insert(KCDUtils.Events.WeaponStateChanged.listeners, sub)
    logger:Info("New WeaponStateChanged subscription added with trigger: " .. trigger)

    if not KCDUtils.Events.WeaponStateChanged.isUpdaterRegistered then
        KCDUtils.Events.WeaponStateChanged:startUpdater()
        KCDUtils.Events.WeaponStateChanged.isUpdaterRegistered = true
    end

    return sub
end

function KCDUtils.Events.WeaponStateChanged.Remove(subscription)
    for i = #KCDUtils.Events.WeaponStateChanged.listeners, 1, -1 do
        if KCDUtils.Events.WeaponStateChanged.listeners[i] == subscription then
            table.remove(KCDUtils.Events.WeaponStateChanged.listeners, i)
            break
        end
    end

    if #KCDUtils.Events.WeaponStateChanged.listeners == 0 and KCDUtils.Events.WeaponStateChanged.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(KCDUtils.Events.WeaponStateChanged.updaterFn)
        KCDUtils.Events.WeaponStateChanged.isUpdaterRegistered = false
    end
end

function KCDUtils.Events.WeaponStateChanged.Pause(subscription)
    if subscription then subscription.isPaused = true end
end

function KCDUtils.Events.WeaponStateChanged.Resume(subscription)
    if subscription then subscription.isPaused = false end
end

function KCDUtils.Events.WeaponStateChanged.startUpdater()
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.WeaponStateChanged")
    logger:Info("WeaponStateChanged updater started.")

    local fn = function(deltaTime)
        local player = KCDUtils.Entities.Player:Get()
        if not player or not player.human then return end

        local isDrawn = player.human:IsWeaponDrawn()
        if isDrawn == nil then return end

        for i = #KCDUtils.Events.WeaponStateChanged.listeners, 1, -1 do
            local sub = KCDUtils.Events.WeaponStateChanged.listeners[i]
            if not sub.isPaused then
                local effectiveLast = sub.lastState
                if effectiveLast ~= nil and effectiveLast ~= isDrawn then
                    local shouldTrigger = false
                    if sub.trigger == "both" then
                        shouldTrigger = true
                    elseif sub.trigger == "draw" and isDrawn then
                        shouldTrigger = true
                    elseif sub.trigger == "sheath" and not isDrawn then
                        shouldTrigger = true
                    end

                    if shouldTrigger then
                        sub.callback({ isDrawn = isDrawn, player = player })
                        if sub.once then
                            KCDUtils.Events.WeaponStateChanged.Remove(sub)
                        end
                    end
                end

                sub.lastState = isDrawn
            end
        end
    end

    KCDUtils.Events.WeaponStateChanged.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end