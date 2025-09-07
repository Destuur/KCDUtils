-- ============================================================================
-- KCDUtils.Events.UnderRoofChanged
-- ============================================================================
-- Event that fires when the player enters or leaves a roofed area.
-- Supports one-time or recurring subscriptions and direction-based triggers.
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.UnderRoofChanged = KCDUtils.Events.UnderRoofChanged or {}

KCDUtils.Events.UnderRoofChanged.listeners = KCDUtils.Events.UnderRoofChanged.listeners or {}
KCDUtils.Events.UnderRoofChanged.isUpdaterRegistered = KCDUtils.Events.UnderRoofChanged.isUpdaterRegistered or false
KCDUtils.Events.UnderRoofChanged.updaterFn = KCDUtils.Events.UnderRoofChanged.updaterFn or nil

--- Adds a subscription to detect entering or leaving roofed areas.
---
--- #### Examples:
--- ```lua
--- -- Fire when entering a roof
--- KCDUtils.Events.UnderRoofChanged.Add({ direction = "enter" }, function(isUnderRoof)
---     System.LogAlways("Player entered a roofed area")
--- end)
---
--- -- Fire when leaving a roof
--- KCDUtils.Events.UnderRoofChanged.Add({ direction = "leave" }, function(isUnderRoof)
---     System.LogAlways("Player left a roofed area")
--- end)
---
--- -- Fire on both entering and leaving
--- KCDUtils.Events.UnderRoofChanged.Add({ direction = "both" }, function(isUnderRoof)
---     if isUnderRoof then
---         System.LogAlways("Player entered a roof")
---     else
---         System.LogAlways("Player left a roof")
---     end
--- end)
--- ```
---
---@param config table Configuration table:
---        Fields:
---        config.direction '"enter"' | '"leave"' | '"both"' -> When to trigger the callback (default: "both")
---        config.once boolean -> Fire only once? (optional, default: false)
---@param callback fun(isUnderRoof:boolean) Callback invoked when the player enters or leaves a roofed area.
---@return table? subscription Returns the subscription object that can be removed via Remove()
function KCDUtils.Events.UnderRoofChanged.Add(config, callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.UnderRoofChanged")

    if type(callback) ~= "function" then
        logger:Error("Add: callback must be a function")
        return nil
    end

    config = config or {}
    local direction = config.direction or "both"
    if direction ~= "enter" and direction ~= "leave" and direction ~= "both" then
        logger:Error("Add: invalid direction. Must be 'enter', 'leave', or 'both'. Defaulting to 'both'")
        direction = "both"
    end

    local sub = {
        callback = callback,
        once = config.once == true,
        lastState = nil,
        isPaused = false,
        direction = direction
    }

    table.insert(KCDUtils.Events.UnderRoofChanged.listeners, sub)
    logger:Info("New UnderRoofChanged subscription added with direction: " .. direction)

    if not KCDUtils.Events.UnderRoofChanged.isUpdaterRegistered then
        KCDUtils.Events.UnderRoofChanged:startUpdater()
        KCDUtils.Events.UnderRoofChanged.isUpdaterRegistered = true
    end

    return sub
end

function KCDUtils.Events.UnderRoofChanged.Remove(subscription)
    for i = #KCDUtils.Events.UnderRoofChanged.listeners, 1, -1 do
        if KCDUtils.Events.UnderRoofChanged.listeners[i] == subscription then
            table.remove(KCDUtils.Events.UnderRoofChanged.listeners, i)
            break
        end
    end

    if #KCDUtils.Events.UnderRoofChanged.listeners == 0 and KCDUtils.Events.UnderRoofChanged.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(KCDUtils.Events.UnderRoofChanged.updaterFn)
        KCDUtils.Events.UnderRoofChanged.isUpdaterRegistered = false
    end
end

function KCDUtils.Events.UnderRoofChanged.Pause(subscription)
    if subscription then subscription.isPaused = true end
end

function KCDUtils.Events.UnderRoofChanged.Resume(subscription)
    if subscription then subscription.isPaused = false end
end

function KCDUtils.Events.UnderRoofChanged.startUpdater()
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.UnderRoofChanged")
    logger:Info("UnderRoofChanged updater started.")

    local fn = function(deltaTime)
        deltaTime = deltaTime or 1.0
        if not player then return end

        local playerPos = player:GetWorldPos()
        local rayStart = { x = playerPos.x, y = playerPos.y, z = playerPos.z + 1.8 }
        local rayDirection = { x = 0, y = 0, z = 3.0 }
        local hits = Physics.RayWorldIntersection(rayStart, rayDirection, 1, ent_all, player.id)

        local isUnderRoof = false
        if hits and #hits > 0 and hits[1].surface then
            isUnderRoof = true
        end

        for i = #KCDUtils.Events.UnderRoofChanged.listeners, 1, -1 do
            local sub = KCDUtils.Events.UnderRoofChanged.listeners[i]
            if not sub.isPaused then
                if sub.lastState == nil then
                    sub.lastState = isUnderRoof
                else
                    local triggerEnter = (sub.direction == "enter" or sub.direction == "both") and isUnderRoof and not sub.lastState
                    local triggerLeave = (sub.direction == "leave" or sub.direction == "both") and not isUnderRoof and sub.lastState

                    if triggerEnter or triggerLeave then
                        sub.callback(isUnderRoof)
                        if sub.once then
                            KCDUtils.Events.UnderRoofChanged.Remove(sub)
                        end
                    end
                    sub.lastState = isUnderRoof
                end
            end
        end
    end

    KCDUtils.Events.UnderRoofChanged.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end