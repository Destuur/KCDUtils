---@class KCDUtilsPlayer
---@field _raw any
---@field soul any
---@field actor any
---@field human any
local PlayerWrapper = {}
PlayerWrapper.__index = PlayerWrapper

-- Wrap Engine-Entity
---@param raw any
---@return KCDUtilsPlayer
local function Wrap(raw)
    local o = setmetatable({}, PlayerWrapper)
    o._raw = raw
    o.actor = raw.actor
    o.soul = raw.soul
    o.human = raw.human
    return o
end

-- Getter
---@return KCDUtilsPlayer|nil
function KCDUtils.Entities.Player:Get()
    local raw = KCDUtils.System.GetPlayer()
    if not raw then return nil end
    return Wrap(raw)
end

-- Wrapper-Methoden
function PlayerWrapper:GetHealth()
    return self._raw and self._raw.soul:GetState("health") or nil
end

-- Export
KCDUtils.Player = KCDUtils.Entities.Player
