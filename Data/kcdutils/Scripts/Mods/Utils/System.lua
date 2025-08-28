--- @class KCDUtils.System
KCDUtils.System = KCDUtils and KCDUtils.System or {}

--- Getter for any entity by name
--- @param name (string) The name of the entity to retrieve.
--- @return (any|nil) entity The entity with the specified name, or nil if not found.
function KCDUtils.System.GetEntityByName(name)
    local logger = KCDUtils.Logger.Factory("System")
    local entity = System.GetEntityByName(name)
    if not entity then
        logger:Warn("Entity with name '" .. tostring(name) .. "' not found.")
    end
    return entity
end

--- Getter for the player entity
--- @return (any|nil) player The player entity, or nil if not found.
function KCDUtils.System.GetPlayer()
    local logger = KCDUtils.Logger.Factory("System")
    local player = System.GetEntityByName("dude") or System.GetEntityByName("Player")
    if not player then
        logger:Warn("Player entity not found.")
    end
    return player
end