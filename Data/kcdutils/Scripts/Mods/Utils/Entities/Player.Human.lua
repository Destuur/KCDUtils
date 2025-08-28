---@class KCDUtils.Entities.Player.Human
local Human = {}
Human.__index = Human
local player = KCDUtils.Entities.Player

--- Checks if the player can currently talk.
--- @return boolean canTalk True if the player can talk, false otherwise.
function Human:CanTalk()
    return player:Get().human:CanTalk()
end

--- Checks if the player can interact with the specified entity.
--- @param entityId any The entity ID to check.
--- @return boolean canInteract True if interaction is possible, false otherwise.
function Human:CanInteractWith(entityId)
    return player:Get().human:CanInteractWith(entityId)
end

--- Requests a dialog interaction for the player.
function Human:RequestDialog()
    return player:Get().human:RequestDialog()
end

--- Interrupts all active dialogs for the player.
function Human:InterruptDialogs()
    return player:Get().human:InterruptDialogs()
end

--- Gets the source name for the current dialog request.
--- @return string name The dialog source name.
function Human:GetDialogRequestSourceName()
    return player:Get().human:GetDialogRequestSourceName()
end

--- Toggles the player's weapon (draw/holster).
function Human:ToggleWeapon()
    return player:Get().human:ToggleWeapon()
end

--- Draws the player's weapon.
function Human:DrawWeapon()
    return player:Get().human:DrawWeapon()
end

--- Holsters the player's weapon.
function Human:HolsterWeapon()
    return player:Get().human:HolsterWeapon()
end

--- Checks if the player's weapon is currently drawn.
--- @return boolean isDrawn True if drawn, false otherwise.
function Human:IsWeaponDrawn()
    return player:Get().human:IsWeaponDrawn()
end

--- Toggles the player's weapon set.
function Human:ToggleWeaponSet()
    return player:Get().human:ToggleWeaponSet()
end

--- Gets the archetype of the player's torch light.
--- @return string archetype The torch light archetype.
function Human:GetTorchLightArchetype()
    return player:Get().human:GetTorchLightArchetype()
end

--- Makes the player grab onto a ladder.
--- @param ladderId any The ladder ID.
function Human:GrabOnLadder(ladderId)
    return player:Get().human:GrabOnLadder(ladderId)
end

--- Checks if the player is currently on a ladder.
--- @return boolean isOnLadder True if on a ladder, false otherwise.
function Human:IsOnLadder()
    return player:Get().human:IsOnLadder()
end

--- Mounts the specified horse.
--- @param horseId string The horse ID.
function Human:Mount(horseId)
    return player:Get().human:Mount(horseId)
end

--- Dismounts from the current horse.
function Human:Dismount()
    return player:Get().human:Dismount()
end

--- Performs bonding with the specified horse.
--- @param horseId string The horse ID.
function Human:DoBonding(horseId)
    return player:Get().human:DoBonding(horseId)
end

--- Gets the mount point for the specified horse.
--- @param horseId string The horse ID.
--- @return any mountPoint The mount point.
function Human:GetHorseMountPoint(horseId)
    return player:Get().human:GetHorseMountPoint(horseId)
end

--- Forces the player to mount the specified horse.
--- @param horseId string The horse ID.
function Human:ForceMount(horseId)
    return player:Get().human:ForceMount(horseId)
end

--- Forces the player to dismount from the horse.
function Human:ForceDismount()
    return player:Get().human:ForceDismount()
end

--- Starts reading the specified book.
--- @param bookId string The book ID.
function Human:StartReading(bookId)
    return player:Get().human:StartReading(bookId)
end

--- Gets the item currently held in the specified hand.
--- @param handId string The hand ID.
--- @return any item The item in hand.
function Human:GetItemInHand(handId)
    return player:Get().human:GetItemInHand(handId)
end

--- Stops the current animation for the player.
function Human:StopAnim()
    return player:Get().human:StopAnim()
end

--- Gets the player's current horse.
--- @return any horse The horse entity.
function Human:GetHorse()
    return player:Get().human:GetHorse()
end

--- Checks if the player is currently mounted on a horse.
--- @return boolean isMounted True if mounted, false otherwise.
function Human:IsMounted()
    return player:Get().human:IsMounted()
end

--- Requests to pickpocket the specified victim.
--- @param victimEntityId string The victim's entity ID.
function Human:RequestPickpocketing(victimEntityId)
    return player:Get().human:RequestPickpocketing(victimEntityId)
end

--- Checks if the player is currently pickpocketing.
--- @return boolean isPickpocketing True if pickpocketing, false otherwise.
function Human:IsPickpocketing()
    return player:Get().human:IsPickpocketing()
end

KCDUtils.Entities.Player.Human = Human
