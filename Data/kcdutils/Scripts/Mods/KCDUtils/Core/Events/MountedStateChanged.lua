KCDUtils = KCDUtils or {}
KCDUtils.Events = KCDUtils.Events or { Name = "KCDUtils.Events" }
KCDUtils.Events.MountedStateChanged = KCDUtils.Events.MountedStateChanged or {}

KCDUtils.Events.MountedStateChanged.listeners = KCDUtils.Events.MountedStateChanged.listeners or {}
KCDUtils.Events.MountedStateChanged.isUpdaterRegistered = KCDUtils.Events.MountedStateChanged.isUpdaterRegistered or false
KCDUtils.Events.MountedStateChanged.updaterFn = KCDUtils.Events.MountedStateChanged.updaterFn or nil
KCDUtils.Events.MountedStateChanged.lastState = KCDUtils.Events.MountedStateChanged.lastState or nil

--- ### Registers a listener for mount state changes.
---
--- #### Examples:
--- ```lua
--- -- Fire whenever mounting happens
--- KCDUtils.Events.MountedStateChanged.Add({ direction = "mounted" }, function(data)
---     System.LogAlways("Player mounted horse:", data.isMounted, "wasMounted:", data.wasMounted)
--- end)
---
--- -- Fire whenever dismounting happens
--- KCDUtils.Events.MountedStateChanged.Add({ direction = "dismounted" }, function(data)
---     System.LogAlways("Player dismounted horse:", data.isMounted, "wasMounted:", data.wasMounted)
--- end)
---
--- -- Fire on both transitions, only once
--- KCDUtils.Events.MountedStateChanged.Add({ direction = "both", once = true }, function(data)
---     System.LogAlways("Triggered once:", data.isMounted, "wasMounted:", data.wasMounted)
--- end)
--- ```
---
--- @param config table|function Configuration table or directly the callback function.
---        config.direction '"mounted"'|'"dismounted"'|'"both"' (default: "both")
---        config.once boolean (default: false)
--- @param callback fun(data:{isMounted:boolean, wasMounted:boolean, direction:string})|nil Callback invoked when the state changes.
--- @return table A subscription object that can be removed.
function KCDUtils.Events.MountedStateChanged.Add(config, callback)
    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.MountedStateChanged")

    if type(config) == "function" then
        callback = config
        config = {}
    elseif type(config) ~= "table" then
        logger:Error("Invalid parameters for MountedStateChanged.Add")
        return {}
    end

    if type(callback) ~= "function" then
        logger:Error("Callback must be a function for MountedStateChanged.Add")
        return {}
    end

    local newSub = {
        callback = callback,
        config = {
            direction = config.direction or "both",
            once = config.once or false,
        },
        isPaused = false
    }

    table.insert(KCDUtils.Events.MountedStateChanged.listeners, newSub)

    if not KCDUtils.Events.MountedStateChanged.isUpdaterRegistered then
        KCDUtils.Events.MountedStateChanged:startUpdater()
        KCDUtils.Events.MountedStateChanged.isUpdaterRegistered = true
    end

    return newSub
end

function KCDUtils.Events.MountedStateChanged.Remove(sub)
    for i, s in ipairs(KCDUtils.Events.MountedStateChanged.listeners) do
        if s == sub then
            table.remove(KCDUtils.Events.MountedStateChanged.listeners, i)
            break
        end
    end
    if #KCDUtils.Events.MountedStateChanged.listeners == 0 and KCDUtils.Events.MountedStateChanged.isUpdaterRegistered then
        KCDUtils.Events.UnregisterUpdater(KCDUtils.Events.MountedStateChanged.updaterFn)
        KCDUtils.Events.MountedStateChanged.isUpdaterRegistered = false
        KCDUtils.Events.MountedStateChanged.lastState = nil
    end
end

function KCDUtils.Events.MountedStateChanged.Pause(sub)
    if sub then sub.isPaused = true end
end

function KCDUtils.Events.MountedStateChanged.Resume(sub)
    if sub then sub.isPaused = false end
end

function KCDUtils.Events.MountedStateChanged:startUpdater()
    local fn = function(deltaTime)
        if not player or not player.human then return end

        local current = player.human:IsMounted()

        -- Initialize state on first update
        if KCDUtils.Events.MountedStateChanged.lastState == nil then
            KCDUtils.Events.MountedStateChanged.lastState = current
            return
        end

        if current ~= KCDUtils.Events.MountedStateChanged.lastState then
            for i = #KCDUtils.Events.MountedStateChanged.listeners, 1, -1 do
                local sub = KCDUtils.Events.MountedStateChanged.listeners[i]
                if not sub.isPaused then
                    local directionConfig = sub.config.direction
                    local trigger = false
                    local directionStr = current and "mounted" or "dismounted"

                    if current and (directionConfig == "mounted" or directionConfig == "both") then
                        trigger = true
                    elseif not current and (directionConfig == "dismounted" or directionConfig == "both") then
                        trigger = true
                    end

                    if trigger then
                        sub.callback({
                            isMounted = current,
                            wasMounted = KCDUtils.Events.MountedStateChanged.lastState,
                            direction = directionStr
                        })

                        if sub.config.once then
                            table.remove(KCDUtils.Events.MountedStateChanged.listeners, i)
                        end
                    end
                end
            end

            KCDUtils.Events.MountedStateChanged.lastState = current
        end
    end

    KCDUtils.Events.MountedStateChanged.updaterFn = fn
    KCDUtils.Events.RegisterUpdater(fn)
end
