---@class KCDUtils.Player
local Player = {}
Player.__index = Player

--- Returns the current player entity.
--- @return any player The player entity instance or nil if not found.
function Player:Get()
    return KCDUtils.Entities.Player:Get()
end

--- Gets the player's current health value.
--- @return number|nil value The player's health or nil if not available.
function Player:GetHealth()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("health")
end

function Player:SetHealth()
end

function Player:AddHealth()
end

function Player:RemoveHealth()
end

--- Gets the player's current stamina value.
--- @return number|nil value The player's stamina or nil if not available.
function Player:GetStamina()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("stamina")
end

--- Gets the player's current exhaustion value.
--- @return number|nil value The player's exhaustion or nil if not available.
function Player:GetExhaust()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("exhaust")
end

--- Gets the player's current hunger value.
--- @return number|nil value The player's hunger or nil if not available.
function Player:GetHunger()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("hunger")
end

--- Gets the player's current karma value.
--- @return number|nil value The player's karma or nil if not available.
function Player:GetKarma()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("karma")
end

--- Gets the player's current alcoholism value.
--- @return number|nil value The player's alcoholism or nil if not available.
function Player:GetAlcoholism()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("alcoholism")
end

function Player:GetPosition()
end

function Player:Teleport(position)
end

KCDUtils.Player = Player