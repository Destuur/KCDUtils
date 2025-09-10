-- ============================================================================
-- KCDUtils.Events.SkillLevelReached (Reload-sicher)
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.SkillLevelReached = KCDUtils.Events.SkillLevelReached or {}

local SLU = KCDUtils.Events.SkillLevelReached

SLU.listeners = SLU.listeners or {}
SLU.isUpdaterRegistered = SLU.isUpdaterRegistered or false
SLU.updaterFn = SLU.updaterFn or nil

-- =====================================================================
-- Interne Helfer
-- =====================================================================

local function addListener(config, callback)
    assert(config.skillName, "SkillLevelReached requires a skillName in config")

    -- Cleanup alte Listener mit identischem Callback
    for i = #SLU.listeners, 1, -1 do
        if SLU.listeners[i].callback == callback then
            table.remove(SLU.listeners, i)
        end
    end

    local sub = {
        callback = callback,
        skillName = config.skillName,
        targetLevel = config.targetLevel or nil,
        lastLevel = nil,
        isPaused = false,
        once = config.once or false
    }

    table.insert(SLU.listeners, sub)

    if not SLU.isUpdaterRegistered then
        SLU.startUpdater()
        SLU.isUpdaterRegistered = true
    end

    return sub
end

local function removeListener(sub)
    for i = #SLU.listeners, 1, -1 do
        if SLU.listeners[i] == sub then
            table.remove(SLU.listeners, i)
            break
        end
    end
    if #SLU.listeners == 0 and SLU.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(SLU.updaterFn)
        SLU.isUpdaterRegistered = false
    end
end

-- =====================================================================
-- Updater
-- =====================================================================

function SLU.startUpdater()
    local fn = function()
        if not player or not player.soul then return end

        for i = #SLU.listeners, 1, -1 do
            local sub = SLU.listeners[i]
            if not sub.isPaused then
                local ok, level = pcall(player.soul.GetSkillLevel, player.soul, sub.skillName)
                if ok and level then
                    if sub.lastLevel == nil then
                        sub.lastLevel = level
                    elseif level > sub.lastLevel and (not sub.targetLevel or level >= sub.targetLevel) then
                        local success, err = pcall(sub.callback, {
                            skillName = sub.skillName,
                            level = level,
                            previousLevel = sub.lastLevel
                        })
                        if not success then
                            KCDUtils.Logger.Factory("KCDUtils.Events.SkillLevelReached"):Error(
                                "Callback error: " .. tostring(err)
                            )
                        end
                        sub.lastLevel = level
                        if sub.once then removeListener(sub) end
                    else
                        sub.lastLevel = level
                    end
                end
            end
        end
    end

    SLU.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

-- =====================================================================
-- Öffentliche API (IntelliSense-kompatibel)
-- =====================================================================

--- SkillLevelReached Event
--- Fires when the player's skill level increases
---
--- @param config table Configuration for the event:
---               skillName = string Name of the skill to monitor (required)
---               targetLevel = number Optional, trigger only at this level or higher
---               once = boolean Optional, trigger only once
--- @param callback fun(eventData:table) Function called with skillName, level, previousLevel
--- @return table subscription Subscription handle (pass to Remove, Pause, Resume)
KCDUtils.Events.SkillLevelReached.Add = function(config, callback)
    return addListener(config, callback)
end

--- Remove a previously registered subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.SkillLevelReached.Remove = function(subscription)
    return removeListener(subscription)
end

--- Pause a subscription without removing it
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.SkillLevelReached.Pause = function(subscription)
    if subscription then subscription.isPaused = true end
end

--- Resume a paused subscription
--- @param subscription table The subscription object returned from Add()
KCDUtils.Events.SkillLevelReached.Resume = function(subscription)
    if subscription then subscription.isPaused = false end
end
