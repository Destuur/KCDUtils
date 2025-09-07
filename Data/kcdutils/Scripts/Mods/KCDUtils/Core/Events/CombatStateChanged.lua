KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or { Name = "KCDUtils.Events" }
KCDUtils.Events.CombatStateChanged = KCDUtils.Events.CombatStateChanged or {}

KCDUtils.Events.CombatStateChanged.listeners = KCDUtils.Events.CombatStateChanged.listeners or {}
KCDUtils.Events.CombatStateChanged.isUpdaterRegistered = KCDUtils.Events.CombatStateChanged.isUpdaterRegistered or false
KCDUtils.Events.CombatStateChanged.updaterFn = KCDUtils.Events.CombatStateChanged.updaterFn or nil

--- ### Adds a listener for combat state changes.
--- 
--- #### Examples:
--- ```lua
--- -- Fires on combat entry
--- KCDUtils.Events.CombatStateChanged.Add({ trigger = "entry" }, function(data)
---     System.LogAlways("Player entered combat!")
--- end)
---
--- -- Fires on combat exit
--- KCDUtils.Events.CombatStateChanged.Add({ trigger = "exit" }, function(data)
---     System.LogAlways("Player left combat!")
--- end)
---
--- -- Fires on both entry and exit
--- KCDUtils.Events.CombatStateChanged.Add({ trigger = "both" }, function(data)
---     if data.inCombat then
---         System.LogAlways("Combat started")
---     else
---         System.LogAlways("Combat ended")
---     end
--- end)
--- ```
--- @param config table Configuration table:
---        config.trigger '"entry"' | '"exit"' | '"both"' (default: "both")
--- @param callback fun(data:{inCombat:boolean, player:table}) Callback invoked when the combat state changes.
function KCDUtils.Events.CombatStateChanged.Add(config, callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.CombatStateChanged")
    if type(config) == "function" then
        callback = config
        config = {}
    end

    if type(callback) ~= "function" then
        logger:Error("Add: callback must be a function")
        return nil
    end

    local trigger = config.trigger or "both"
    if trigger ~= "entry" and trigger ~= "exit" and trigger ~= "both" then
        logger:Error("Add: invalid trigger, must be 'entry', 'exit' or 'both'. Defaulting to 'both'.")
        trigger = "both"
    end

    local newSubscription = {
        callback = callback,
        isPaused = false,
        lastState = nil, 
        pausedState = nil,
        trigger = trigger
    }

    table.insert(KCDUtils.Events.CombatStateChanged.listeners, newSubscription)
    logger:Info("New CombatStateChanged subscription added. Trigger: " .. trigger)

    if not KCDUtils.Events.CombatStateChanged.isUpdaterRegistered then
        KCDUtils.Events.CombatStateChanged:startUpdater()
        KCDUtils.Events.CombatStateChanged.isUpdaterRegistered = true
    end

    return newSubscription
end

function KCDUtils.Events.CombatStateChanged.Remove(subscription)
    for i, sub in ipairs(KCDUtils.Events.CombatStateChanged.listeners) do
        if sub == subscription then
            table.remove(KCDUtils.Events.CombatStateChanged.listeners, i)
            break
        end
    end

    if #KCDUtils.Events.CombatStateChanged.listeners == 0 and KCDUtils.Events.CombatStateChanged.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(KCDUtils.Events.CombatStateChanged.updaterFn)
        KCDUtils.Events.CombatStateChanged.isUpdaterRegistered = false
    end
end

function KCDUtils.Events.CombatStateChanged.Pause(subscription)
    if subscription then
        subscription.isPaused = true
    end
end

function KCDUtils.Events.CombatStateChanged.Resume(subscription)
    if subscription then
        subscription.isPaused = false
    end
end

function KCDUtils.Events.CombatStateChanged:startUpdater()
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.CombatStateChanged")
    logger:Info("CombatStateChanged updater started.")

    local fn = function(deltaTime)
        local player = KCDUtils.Entities.Player:Get()
        if not player or not player.soul then return end

        local inCombat = player.soul:IsInCombatDanger()
        if inCombat == nil then return end

        for _, sub in ipairs(KCDUtils.Events.CombatStateChanged.listeners) do
            if sub.isPaused then
                sub.pausedState = inCombat
            else
                local effectiveLastState = sub.pausedState or sub.lastState

                if effectiveLastState ~= nil and inCombat ~= effectiveLastState then
                    local shouldTrigger = false
                    if sub.trigger == "both" then
                        shouldTrigger = true
                    elseif sub.trigger == "entry" and inCombat then
                        shouldTrigger = true
                    elseif sub.trigger == "exit" and not inCombat then
                        shouldTrigger = true
                    end

                    if shouldTrigger then
                        sub.callback({
                            inCombat = inCombat,
                            player = player
                        })
                    end
                end

                sub.lastState = inCombat
                sub.pausedState = nil
            end
        end
    end

    KCDUtils.Events.CombatStateChanged.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end
