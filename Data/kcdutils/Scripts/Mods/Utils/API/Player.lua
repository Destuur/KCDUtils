---@class KCDUtils.Player
local Player = {}
Player.__index = Player

function Player:Get()
    return KCDUtils.Entities.Player:Get()
end

function Player:GetHealth()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("health")
end

function Player:GetStamina()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("stamina")
end

function Player:GetExhaust()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("exhaust")
end

function Player:GetHunger()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("hunger")
end

function Player:GetKarma()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("karma")
end

function Player:GetAlcoholism()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("alcoholism")
end

KCDUtils.Player = Player