-- ============================================================================ 
-- KCDUtils.Events.GenericEvent
-- ============================================================================

KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or {}

-- Erstellt ein neues Event
function KCDUtils.Events.CreateEvent(eventName)
    local evt = KCDUtils.Events[eventName] or {}
    KCDUtils.Events[eventName] = evt

    evt.listeners = evt.listeners or {}
    evt.isUpdaterRegistered = evt.isUpdaterRegistered or false
    evt.updaterFn = evt.updaterFn or nil

    -- Fügt einen Listener hinzu
    function evt.Add(config, callback)
        config = config or {}
        if type(callback) ~= "function" then
            KCDUtils.Logger.Factory("KCDUtils.Events."..eventName):Error("Add: callback must be a function")
            return nil
        end

        local sub = {
            callback = callback,
            config = config,
            isPaused = false,
            lastState = nil
        }

        table.insert(evt.listeners, sub)

        if not evt.isUpdaterRegistered and evt.startUpdater then
            evt.startUpdater()
            evt.isUpdaterRegistered = true
        end

        return sub
    end

    -- Entfernt einen Listener
    function evt.Remove(sub)
        for i = #evt.listeners, 1, -1 do
            if evt.listeners[i] == sub then
                table.remove(evt.listeners, i)
                break
            end
        end

        if #evt.listeners == 0 and evt.isUpdaterRegistered then
            KCDUtils.Events.UnregisterUpdater(evt.updaterFn)
            evt.isUpdaterRegistered = false
        end
    end

    -- Pause / Resume
    function evt.Pause(sub) if sub then sub.isPaused = true end end
    function evt.Resume(sub) if sub then sub.isPaused = false end end

    return evt
end


-- Beispiel Anwendung:
-- local WeaponStateChanged = KCDUtils.Events.CreateEvent("WeaponStateChanged")

-- function WeaponStateChanged.startUpdater()
--     local fn = function()
--         local player = KCDUtils.Entities.Player:Get()
--         if not player or not player.human then return end

--         local isDrawn = player.human:IsWeaponDrawn()
--         if isDrawn == nil then return end

--         for i = #WeaponStateChanged.listeners, 1, -1 do
--             local sub = WeaponStateChanged.listeners[i]
--             if not sub.isPaused then
--                 if sub.lastState ~= nil and sub.lastState ~= isDrawn then
--                     local triggerEvent = false
--                     local trigger = sub.config.trigger or "both"
--                     if trigger == "both" then
--                         triggerEvent = true
--                     elseif trigger == "draw" and isDrawn then
--                         triggerEvent = true
--                     elseif trigger == "sheath" and not isDrawn then
--                         triggerEvent = true
--                     end

--                     if triggerEvent then
--                         sub.callback({ isDrawn = isDrawn, player = player })
--                         if sub.config.once then
--                             WeaponStateChanged.Remove(sub)
--                         end
--                     end
--                 end
--                 sub.lastState = isDrawn
--             end
--         end
--     end

--     WeaponStateChanged.updaterFn = fn
--     KCDUtils.Events.RegisterUpdater(fn)
-- end