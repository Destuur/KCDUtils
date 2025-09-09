-- ============================================================================ 
-- KCDUtils.Events.UnderRoofChanged (Reload-sicher)
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.UnderRoofChanged = KCDUtils.Events.UnderRoofChanged or {}

local URC = KCDUtils.Events.UnderRoofChanged

URC.listeners = URC.listeners or {}
URC.isUpdaterRegistered = URC.isUpdaterRegistered or false
URC.updaterFn = URC.updaterFn or nil

-- Interne Add/Remove Methoden
local function addListener(config, callback)
    config = config or {}
    local direction = config.direction or "both"
    local sub = {
        callback = callback,
        once = config.once == true,
        lastState = nil,
        isPaused = false,
        direction = direction
    }
    table.insert(URC.listeners, sub)
    if not URC.isUpdaterRegistered then
        URC.startUpdater()
        URC.isUpdaterRegistered = true
    end
    return sub
end

local function removeListener(sub)
    for i = #URC.listeners, 1, -1 do
        if URC.listeners[i] == sub then
            table.remove(URC.listeners, i)
            break
        end
    end
    if #URC.listeners == 0 and URC.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(URC.updaterFn)
        URC.isUpdaterRegistered = false
    end
end

URC.Pause = function(sub) if sub then sub.isPaused = true end end
URC.Resume = function(sub) if sub then sub.isPaused = false end end

function URC.startUpdater()
    local fn = function(deltaTime)
        if not player then return end
        local pos = player:GetWorldPos()
        local rayStart = { x = pos.x, y = pos.y, z = pos.z + 1.8 }
        local hits = Physics.RayWorldIntersection(rayStart, {x=0,y=0,z=3}, 1, ent_all, player.id)
        local isUnderRoof = hits and #hits>0 and hits[1].surface

        for i = #URC.listeners, 1, -1 do
            local sub = URC.listeners[i]
            if not sub.isPaused then
                if sub.lastState == nil then
                    sub.lastState = isUnderRoof
                else
                    local triggerEnter = (sub.direction=="enter" or sub.direction=="both") and isUnderRoof and not sub.lastState
                    local triggerLeave = (sub.direction=="leave" or sub.direction=="both") and not isUnderRoof and sub.lastState
                    if triggerEnter or triggerLeave then
                        sub.callback(isUnderRoof)
                        if sub.once then removeListener(sub) end
                    end
                    sub.lastState = isUnderRoof
                end
            end
        end
    end
    URC.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end

-- ============================================================
-- Statt AddSafe: universelle RegisterListener-Methode verwenden
-- ============================================================
function URC.Add(config, callback)
    return addListener(config, callback)
end

function URC.Remove(sub)
    return removeListener(sub)
end