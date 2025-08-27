--- @class KCDUtilsSystem
KCDUtils.System = KCDUtils and KCDUtils.System or {}

function KCDUtils.System.GetEntityByName(name)
    local logger = KCDUtils.Logger.Factory("System")
    local entity = System.GetEntityByName(name)
    if not entity then
        logger:Warn("Entity with name '" .. tostring(name) .. "' not found.")
    end
    return entity
end

function KCDUtils.System.GetPlayer()
    local logger = KCDUtils.Logger.Factory("System")
    local player = System.GetEntityByName("dude") or System.GetEntityByName("Player")
    if not player then
        logger:Warn("Player entity not found.")
    end
    return player
end
