--- @class KCDUtilsMath
KCDUtils.Math = KCDUtils.Math or {}
KCDUtils.Math.logger = KCDUtils.Logger.Factory("KCDUtilsMath")

--------------------------------------------------
-- Vector Utilities
--------------------------------------------------
---@param v any
---@return table|nil {x=...,y=...,z=...}
function KCDUtils.Math.ToVec3(v)
    if not v then return nil end
    local x, y, z

    if type(v) == "table" then
        x = (v.x ~= nil) and v.x or v[1]
        y = (v.y ~= nil) and v.y or v[2]
        z = (v.z ~= nil) and v.z or v[3]
    else
        x = (v.x ~= nil) and v.x or (v.GetX and v:GetX())
        y = (v.y ~= nil) and v.y or (v.GetY and v:GetY())
        z = (v.z ~= nil) and v.z or (v.GetZ and v:GetZ())
    end

    x = tonumber(x); y = tonumber(y); z = tonumber(z)
    if x and y then
        return { x = x, y = y, z = z or 0 } -- z default 0 falls nicht vorhanden
    end

    KCDUtils.Math.logger:Error("ToVec3: Failed to convert vector: " .. tostring(v))
    return nil
end

--------------------------------------------------
-- Distance / Speed
--------------------------------------------------

--- Calculates 2D or 3D distance (falls z!=0)
---@param pos1 table|userdata
---@param pos2 table|userdata
---@param ignoreZ boolean Optional, default=false
---@return number
function KCDUtils.Math.CalculateDistance(pos1, pos2, ignoreZ)
    local a = KCDUtils.Math.ToVec3(pos1)
    local b = KCDUtils.Math.ToVec3(pos2)
    if not a or not b then
        KCDUtils.Math.logger:Error("CalculateDistance: invalid vector(s)")
        return 0
    end

    local dx = b.x - a.x
    local dy = b.y - a.y
    if ignoreZ or not a.z or not b.z then
        return math.sqrt(dx*dx + dy*dy)
    end

    local dz = b.z - a.z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

--- Calculates player speed
---@param player any
---@param deltaTime number|nil
---@param movedDistance number|nil
---@return number
function KCDUtils.Math.GetPlayerSpeed(player, deltaTime, movedDistance)
    if not player then return 0 end
    deltaTime = deltaTime or 0
    movedDistance = movedDistance or 0

    if movedDistance > 0 and deltaTime > 0 then
        return movedDistance / deltaTime
    end

    local ok, v = pcall(function() return player:GetVelocity() end)
    if not ok or not v then
        KCDUtils.Math.logger:Error("GetPlayerSpeed: GetVelocity() failed or returned nil")
        return 0
    end

    local vec = KCDUtils.Math.ToVec3(v)
    if not vec then return 0 end

    local speed = math.sqrt(vec.x*vec.x + vec.y*vec.y + vec.z*vec.z)
    return speed
end

--------------------------------------------------
-- Utility: Player Position
--------------------------------------------------
---@param player any
---@return table|nil
function KCDUtils.Math.GetPlayerPosition(player)
    if not player then return nil end
    local ok, pos = pcall(function() return player:GetWorldPos() end)
    if not ok or not pos then
        KCDUtils.Math.logger:Error("GetPlayerPosition: failed to get player position")
        return nil
    end
    return KCDUtils.Math.ToVec3(pos)
end
