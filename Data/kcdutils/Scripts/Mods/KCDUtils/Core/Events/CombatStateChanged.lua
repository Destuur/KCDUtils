-- ============================================================================ 
-- KCDUtils.Events.CombatStateChanged (Reload-sicher)
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.CombatStateChanged = KCDUtils.Events.CombatStateChanged or {}

local CSC = KCDUtils.Events.CombatStateChanged

CSC.listeners = CSC.listeners or {}
CSC.isUpdaterRegistered = CSC.isUpdaterRegistered or false
CSC.updaterFn = CSC.updaterFn or nil

-- Interne Add/Remove Methoden
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

CSC.Pause = function(sub) if sub then sub.isPaused = true end end
CSC.Resume = function(sub) if sub then sub.isPaused = false end end

function CSC.startUpdater()
    local fn = function(deltaTime)
        if not player or not player.soul then return end

        local inCombat = player.soul:IsInCombatDanger()
        if inCombat == nil then return end

        for i = #CSC.listeners, 1, -1 do
            local sub = CSC.listeners[i]

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
                        if sub.once then
                            removeListener(sub)
                        end
                    end
                end

                sub.lastState = inCombat
                sub.pausedState = nil
            end
        end
    end

    CSC.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

-- Reload-sichere Add/Remove Funktionen für Modder
function CSC.Add(config, callback)
    return addListener(config, callback)
end

function CSC.Remove(sub)
    return removeListener(sub)
end
