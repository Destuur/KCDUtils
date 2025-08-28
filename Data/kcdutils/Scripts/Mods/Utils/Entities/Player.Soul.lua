---@class KCDUtils.Entities.Player.Soul
local Soul = {}
Soul.__index = Soul

KCDUtils.Entities.Player.Soul = Soul

--- Cleans the dirt from the specified entity (usually the player).
--- If no entity is provided, logs an error.
function Soul:CleanDirt()
    return KCDUtils.Entities.Player:Get().soul:CleanDirt()
end

--- Gets the state of the player's soul.  
---   
--- For commonly used states you might also use:
--- 
--- ```lua
--- KCDUtils.Player:GetHealth()
--- ```
--- 
--- @param state string The state to get (e.g., "dirt", "health")
function Soul:GetState(state)
    return KCDUtils.Entities.Player:Get().soul:GetState(state) or nil
end

--- Returns the current level of the specified stat for the player.
--- @param stat string The stat key (e.g., "strength", "vitality").
--- @return number|nil level The stat level, or nil if not found.
function Soul:GetStatLevel(stat)
    return KCDUtils.Entities.Player:Get().soul:GetStatLevel(stat) or nil
end

--- Returns the current progress (XP) towards the next level for the specified stat.
--- @param stat string The stat key.
--- @return number|nil value The progress value, or nil if not found.
function Soul:GetStatProgress(stat)
    return KCDUtils.Entities.Player:Get().soul:GetStatProgress(stat) or nil
end

--- Advances the specified stat to the given level for the player.
--- @param stat string The stat key.
--- @param level number The level to advance to.
function Soul:AdvanceToStatLevel(stat, level)
    return KCDUtils.Entities.Player:Get().soul:AdvanceToStatLevel(stat, level)
end

--- Adds experience points to the specified stat for the player.
--- @param stat string The stat key.
--- @param xp number The amount of XP to add.
function Soul:AddStatXP(stat, xp)
    return KCDUtils.Entities.Player:Get().soul:AddStatXP(stat, xp)
end

--- Returns the XP required for the next level of the specified stat.
--- @param stat string The stat key.
--- @param xp number Current XP (optional, if needed by implementation).
--- @return number|nil xp The XP required, or nil if not found.
function Soul:GetNextLevelStatXP(stat, xp)
    return KCDUtils.Entities.Player:Get().soul:GetNextLevelStatXP(stat, xp)
end

--- Returns the value of a derived stat for the player.
--- @param derivedStat string The derived stat key.
--- @return number|nil value The derived stat value, or nil if not found.
function Soul:GetDerivedStat(derivedStat)
    return KCDUtils.Entities.Player:Get().soul:GetDerivedStat(derivedStat) or nil
end

--- Checks if the player has the specified skill.
--- @param skill string The skill key.
--- @return boolean|nil hasSkill True if the player has the skill, false/nil otherwise.
function Soul:HaveSkill(skill)
    return KCDUtils.Entities.Player:Get().soul:HaveSkill(skill) or nil
end

--- Returns the current level of the specified skill for the player.
--- @param skill string The skill key.
--- @return number|nil value The skill level, or nil if not found.
function Soul:GetSkillLevel(skill)
    return KCDUtils.Entities.Player:Get().soul:GetSkillLevel(skill) or nil
end

--- Returns the current progress (XP) towards the next level for the specified skill.
--- @param skill string The skill key.
--- @return number|nil progress The progress value, or nil if not found.
function Soul:GetSkillProgress(skill)
    return KCDUtils.Entities.Player:Get().soul:GetSkillProgress(skill) or nil
end

--- Checks if the player has the specified ability.
--- @param ability string The ability key.
--- @return boolean|nil hasAbility True if the player has the ability, false/nil otherwise.
function Soul:HasAbility(ability)
    return KCDUtils.Entities.Player:Get().soul:HasAbility(ability) or nil
end

--- Advances the specified skill to the given level for the player.
--- @param skill string The skill key.
--- @param level number The level to advance to.
function Soul:AdvanceToSkillLevel(skill, level)
    return KCDUtils.Entities.Player:Get().soul:AdvanceToSkillLevel(skill, level)
end

--- Adds experience points to the specified skill for the player.
--- @param skill string The skill key.
--- @param xp number The amount of XP to add.
function Soul:AddSkillXP(skill, xp)
    return KCDUtils.Entities.Player:Get().soul:AddSkillXP(skill, xp)
end

--- Returns the XP required for the next level of the specified skill.
--- @param skill string The skill key.
--- @param level number The current skill level.
--- @return number|nil xp The XP required, or nil if not found.
function Soul:GetNextLevelSkillXP(skill, level)
    return KCDUtils.Entities.Player:Get().soul:GetNextLevelSkillXP(skill, level)
end

--- Adds a buff to the player by its ID.
--- @param buffId string The buff identifier.
function Soul:AddBuff(buffId)
    return KCDUtils.Entities.Player:Get().soul:AddBuff(buffId)
end

--- Removes a specific buff instance from the player.
--- @param buffInstance any The buff instance to remove.
function Soul:RemoveBuff(buffInstance)
    return KCDUtils.Entities.Player:Get().soul:RemoveBuff(buffInstance)
end

--- Removes all buffs from the player that match the given GUID.
--- @param buffGuid string The GUID of the buff(s) to remove.
function Soul:RemoveAllBuffsByGuid(buffGuid)
    return KCDUtils.Entities.Player:Get().soul:RemoveAllBuffsByGuid(buffGuid)
end

--- Adds a perk to the player by its ID.
--- @param perkId string The perk identifier.
function Soul:AddPerk(perkId)
    return KCDUtils.Entities.Player:Get().soul:AddPerk(perkId)
end

--- Removes a perk from the player by its ID.
--- @param perkId string The perk identifier.
function Soul:RemovePerk(perkId)
    return KCDUtils.Entities.Player:Get().soul:RemovePerk(perkId)
end

--- Adds all codex entries in the players menu.
function Soul:AddAllCodexPerk()
    return KCDUtils.Entities.Player:Get().soul:AddAllCodexPerk()
end

--- Adds a meta role to the player by name.
--- @param name string The name of the meta role.
function Soul:AddMetaRoleByName(name)
    return KCDUtils.Entities.Player:Get().soul:AddMetaRoleByName(name)
end

--- Removes a meta role from the player by name.
--- @param name string The name of the meta role.
function Soul:RemoveMetaRoleByName(name)
    return KCDUtils.Entities.Player:Get().soul:RemoveMetaRoleByName(name)
end

--- Modifies the player's reputation for a given chance name, optionally propagating to the faction.
--- @param repChanceName string The reputation chance name.
--- @param propagateToFaction boolean Whether to propagate to the faction.
function Soul:ModifyPlayerReputation(repChanceName, propagateToFaction)
    return KCDUtils.Entities.Player:Get().soul:ModifyPlayerReputation(repChanceName, propagateToFaction)
end

--- Gets the relationship value between the player and another soul.
--- @param otherSoulWuid string The WUID of the other soul.
--- @return number|nil value The relationship value, or nil if not found.
function Soul:GetRelationship(otherSoulWuid)
    return KCDUtils.Entities.Player:Get().soul:GetRelationship(otherSoulWuid)
end

--- Calculates barter dominance against a shopkeeper.
--- @param shopkeeperSoulWuid string The WUID of the shopkeeper's soul.
--- @return number|nil value The dominance value, or nil if not found.
function Soul:CalculateBarterDominance(shopkeeperSoulWuid)
    return KCDUtils.Entities.Player:Get().soul:CalculateBarterDominance(shopkeeperSoulWuid)
end

--- Checks if the player is currently in combat danger.
--- @return boolean hasDanger True if in danger, false otherwise.
function Soul:IsInCombatDanger()
    return KCDUtils.Entities.Player:Get().soul:IsInCombatDanger()
end

--- Checks if the player is currently in combat mode.
--- @return boolean|nil hasCombatMode True if in combat mode, false otherwise.
function Soul:IsInCombatMode()
    return KCDUtils.Entities.Player:Get().soul:IsInCombatMode()
end

--- Checks if the player is currently in a tense circumstance.
--- @return boolean|nil hasTenseCircumstance True if in a tense circumstance, false otherwise.
function Soul:IsInTenseCircumstance()
    return KCDUtils.Entities.Player:Get().soul:IsInTenseCircumstance()
end

--- Gets the string ID of the player's name.
--- @return string id The name string ID.
function Soul:GetNameStringId()
    return KCDUtils.Entities.Player:Get().soul:GetNameStringId()
end

--- Gets the text for the read caption object.
--- @return string|nil text The caption text.
function Soul:GetReadCaptionObjectText()
    return KCDUtils.Entities.Player:Get().soul:GetReadCaptionObjectText()
end

--- Checks if the player is currently a public enemy.
--- @return boolean|nil isPublicEnemy True if public enemy, false otherwise.
function Soul:IsPublicEnemy()
    return KCDUtils.Entities.Player:Get().soul:IsPublicEnemy()
end

--- Checks if it is legal to loot as the player.
--- @return boolean|nil isLegalToLoot True if legal, false otherwise.
function Soul:IsLegalToLoot()
    return KCDUtils.Entities.Player:Get().soul:IsLegalToLoot()
end

--- Checks if the player is currently dialog restricted.
--- @return boolean|nil isDialogRestricted True if dialog restricted, false otherwise.
function Soul:IsDialogRestricted()
    return KCDUtils.Entities.Player:Get().soul:IsDialogRestricted()
end

--- Gets the list of meta roles for the player.
--- @return table|nil metaRoles The meta roles.
function Soul:GetMetaRoles()
    return KCDUtils.Entities.Player:Get().soul:GetMetaRoles()
end

--- Gets the player's current schedule.
--- @return table|nil schedule The schedule.
function Soul:GetSchedule()
    return KCDUtils.Entities.Player:Get().soul:GetSchedule()
end

--- Gets the player's social class.
--- @return string|nil socialClass The social class.
function Soul:GetSocialClass()
    return KCDUtils.Entities.Player:Get().soul:GetSocialClass()
end

--- Gets the player's archetype.
--- @return string|nil archetype The archetype.
function Soul:GetArchetype()
    return KCDUtils.Entities.Player:Get().soul:GetArchetype()
end

--- Gets the player's gender.
--- @return string|nil gender The gender.
function Soul:GetGender()
    return KCDUtils.Entities.Player:Get().soul:GetGender()
end

--- Gets the player's gather multiplier.
--- @return number|nil gatherMult The gather multiplier.
function Soul:GetGatherMult()
    return KCDUtils.Entities.Player:Get().soul:GetGatherMult()
end

--- Gets the player's faction ID.
--- @return string|nil factionID The faction ID.
function Soul:GetFactionID()
    return KCDUtils.Entities.Player:Get().soul:GetFactionID()
end

--- Checks if the player has the specified script context.
--- @param contextName string The context name.
--- @return boolean|nil hasScriptContext True if the context exists, false otherwise.
function Soul:HasScriptContext(contextName)
    return KCDUtils.Entities.Player:Get().soul:HasScriptContext(contextName)
end

--- Checks if the player can eat the specified item.
--- @param itemClassIdDef string The item class ID definition.
--- @return boolean|nil canEatItem True if the item can be eaten, false otherwise.
function Soul:CanEatItem(itemClassIdDef)
    return KCDUtils.Entities.Player:Get().soul:CanEatItem(itemClassIdDef)
end

--- Makes the player eat the specified item.
--- @param itemClassIdDef string The item class ID definition.
function Soul:EatItem(itemClassIdDef)
    return KCDUtils.Entities.Player:Get().soul:EatItem(itemClassIdDef)
end
