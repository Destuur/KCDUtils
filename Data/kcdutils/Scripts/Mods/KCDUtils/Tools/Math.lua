---@class KCDUtilsMath
KCDUtils.Math = KCDUtils.Math or {}
KCDUtils.Math.logger = KCDUtils.Logger.Factory("KCDUtilsMath")

--------------------------------------------------
-- Vector Utilities
--------------------------------------------------

--- Converts engine/userdata/table vector to simple Lua table {x=...,y=...,z=...}
--- Returns nil if conversion fails
---@param v any
---@return table|nil
function KCDUtils.Math.ToVec3(v)
    if not v then return nil end
    local x, y, z

    if type(v) == "table" then
        x = (v.x ~= nil) and v.x or v[1]
        y = (v.y ~= nil) and v.y or v[2]
        z = (v.z ~= nil) and v.z or v[3]
    else
        -- userdata / engine object
        x = (v.x ~= nil) and v.x or (v.GetX and v:GetX())
        y = (v.y ~= nil) and v.y or (v.GetY and v:GetY())
        z = (v.z ~= nil) and v.z or (v.GetZ and v:GetZ())
    end

    x = tonumber(x); y = tonumber(y); z = tonumber(z)
    if x and y and z then
        return { x = x, y = y, z = z }
    end

    KCDUtils.Math.logger:Error("ToVec3: Failed to convert vector")
    return nil
end

--------------------------------------------------
-- Distance / Speed
--------------------------------------------------

--- Calculates 3D distance between two vectors
---@param pos1 table|userdata
---@param pos2 table|userdata
---@return number
function KCDUtils.Math.CalculateDistance(pos1, pos2)
    local a = KCDUtils.Math.ToVec3(pos1)
    local b = KCDUtils.Math.ToVec3(pos2)
    if not a or not b then
        KCDUtils.Math.logger:Error("CalculateDistance: invalid vector(s)")
        return 0
    end

    local dx = b.x - a.x
    local dy = b.y - a.y
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
    deltaTime = deltaTime or 1.0
    movedDistance = movedDistance or 0.0

    if movedDistance > 0 and deltaTime > 0 then
        return movedDistance / deltaTime
    end

    local ok, v = pcall(function() return player:GetVelocity() end)
    if not ok or not v then
        KCDUtils.Math.logger:Error("GetPlayerSpeed: GetVelocity() failed or returned nil")
        return 0
    end

    local vx = tonumber(v.x) or 0
    local vy = tonumber(v.y) or 0
    local vz = tonumber(v.z) or 0
    return math.sqrt(vx*vx + vy*vy + vz*vz)
end

--------------------------------------------------
-- Utility: Player Position
--------------------------------------------------

--- Safely returns player world position as vector
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
