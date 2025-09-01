---@class KCDUtilsPlayer
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
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("health")
end

function Player:SetHealth(value)
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    player.soul:SetState("health", value)
end

function Player:AddHealth(amount)
    local health = self:GetHealth()
    if health then
        self:SetHealth(health + amount)
    end
end

function Player:RemoveHealth(amount)
    local health = self:GetHealth()
    if health then
        self:SetHealth(health - amount)
    end
end

--- Gets the player's current stamina value.
--- @return number|nil value The player's stamina or nil if not available.
function Player:GetStamina()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("stamina")
end

--- Sets the player's current stamina value.
--- @param value number The new stamina value to set.
function Player:SetStamina(value)
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    player.soul:SetState("stamina", value)
end

--- Adds the specified amount to the player's stamina.
--- @param amount number The amount to add to the player's stamina.
function Player:AddStamina(amount)
    local stamina = self:GetStamina()
    if stamina then
        self:SetStamina(stamina + amount)
    end
end

--- Removes the specified amount from the player's stamina.
--- @param amount number The amount to remove from the player's stamina.
function Player:RemoveStamina(amount)
    local stamina = self:GetStamina()
    if stamina then
        self:SetStamina(stamina - amount)
    end
end

--- Gets the player's current exhaustion value.
--- @return number|nil value The player's exhaustion or nil if not available.
function Player:GetExhaust()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("exhaust")
end

--- Sets the player's current exhaustion value.
--- @param value number The new exhaustion value to set.
function Player:SetExhaust(value)
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    player.soul:SetState("exhaust", value)
end

--- Adds the specified amount to the player's exhaustion.
--- @param amount number The amount to add to the player's exhaustion.
function Player:AddExhaust(amount)
    local exhaust = self:GetExhaust()
    if exhaust then
        self:SetExhaust(exhaust + amount)
    end
end

--- Removes the specified amount from the player's exhaustion.
--- @param amount number The amount to remove from the player's exhaustion.
function Player:RemoveExhaust(amount)
    local exhaust = self:GetExhaust()
    if exhaust then
        self:SetExhaust(exhaust - amount)
    end
end

--- Gets the player's current hunger value.
--- @return number|nil value The player's hunger or nil if not available.
function Player:GetHunger()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("hunger")
end

--- Sets the player's current hunger value.
--- @param value number The new hunger value to set.
function Player:SetHunger(value)
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    player.soul:SetState("hunger", value)
end

--- Adds the specified amount to the player's hunger.
--- @param amount number The amount to add to the player's hunger.
function Player:AddHunger(amount)
    local hunger = self:GetHunger()
    if hunger then
        self:SetHunger(hunger + amount)
    end
end

--- Removes the specified amount from the player's hunger.
--- @param amount number The amount to remove from the player's hunger.
function Player:RemoveHunger(amount)
    local hunger = self:GetHunger()
    if hunger then
        self:SetHunger(hunger - amount)
    end
end

--- Gets the player's current karma value.
--- @return number|nil value The player's karma or nil if not available.
function Player:GetKarma()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("karma")
end

--- Sets the player's current karma value.
--- @param value number The new karma value to set.
function Player:SetKarma(value)
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    player.soul:SetState("karma", value)
end

--- Adds the specified amount to the player's karma.
--- @param amount number The amount to add to the player's karma.
function Player:AddKarma(amount)
    local karma = self:GetKarma()
    if karma then
        self:SetKarma(karma + amount)
    end
end

--- Removes the specified amount from the player's karma.
--- @param amount number The amount to remove from the player's karma.
function Player:RemoveKarma(amount)
    local karma = self:GetKarma()
    if karma then
        self:SetKarma(karma - amount)
    end
end

--- Gets the player's current alcoholism value.
--- @return number|nil value The player's alcoholism or nil if not available.
function Player:GetAlcoholism()
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    return player.soul:GetState("alcoholism")
end

--- Sets the player's current alcoholism value.
--- @param value number The new alcoholism value to set.
function Player:SetAlcoholism(value)
    local player = self:Get()
    if not player then
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Player entity not found.")
        return nil
    end
    player.soul:SetState("alcoholism", value)
end

--- Adds the specified amount to the player's alcoholism.
--- @param amount number The amount to add to the player's alcoholism.
function Player:AddAlcoholism(amount)
    local alcoholism = self:GetAlcoholism()
    if alcoholism then
        self:SetAlcoholism(alcoholism + amount)
    end
end

--- Removes the specified amount from the player's alcoholism.
--- @param amount number The amount to remove from the player's alcoholism.
function Player:RemoveAlcoholism(amount)
    local alcoholism = self:GetAlcoholism()
    if alcoholism then
        self:SetAlcoholism(alcoholism - amount)
    end
end

--- Gets the player's current world position.
--- @return Vector3|nil position The player's position as a Vector3 or nil if not available.
function Player:GetPosition()
end

--- Teleports the player to the specified world position.
--- @param position Vector3 The target position to teleport the player to.
function Player:Teleport(position)
end

---@type KCDUtilsPlayer
KCDUtils.Player = Player