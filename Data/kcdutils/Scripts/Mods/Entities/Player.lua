--- @class KCDUtilsEntitiesPlayer
--- @field soul KCDUtilsEntitiesPlayerSoul
--- @field actor KCDUtilsEntitiesPlayerActor
--- @field human KCDUtilsEntitiesPlayerHuman
--- @field inventory KCDUtilsEntitiesPlayerInventory
--- @field player KCDUtilsEntitiesPlayerPlayer
local Player = {}
Player.__index = Player

local _instance = nil

--- Singleton-Getter
function Player:Get()
    if _instance then return _instance end

    local safeCall = KCDUtils.SafeCall
    local raw = KCDUtils.Core.System.GetPlayer()
    if not raw then 
        return nil 
    end

    _instance = { _raw = raw }

    --------------------------------------------------
    --- player
    --------------------------------------------------
    -- #region    
    -- player.__index.OnInit => function (Lua function) params: 0 | vararg: nil
    -- player.__index.ReviveInEditor => function (Lua function) params: 0 | vararg: nil
    -- player.__index.AddLootAction => function (Lua function) params: 0 | vararg: nil
    -- player.__index.GetDogActions => function (Lua function) params: 0 | vararg: nil
    -- player.__index.CheatEngine_time => function (Lua function) params: 0 | vararg: nil
    -- player.__index.CheatEngine => function (Lua function) params: 0 | vararg: nil
    -- player.__index.Client.OnInit => function (Lua function) params: 0 | vararg: nil
    -- player.__index.CheatEngine_animal => function (Lua function) params: 0 | vararg: nil
    -- player.__index.ResetCommon => function (Lua function) params: 0 | vararg: nil
    -- player.__index.PRTelep_unlock => function (Lua function) params: 0 | vararg: nil
    -- player.__index.OnDogRequest => function (Lua function) params: 0 | vararg: nil
    -- player.__index.CheatEngine_skill => function (Lua function) params: 0 | vararg: nil
    -- player.__index.OnSpawn => function (Lua function) params: 0 | vararg: nil
    -- player.__index.SetActorModel => function (Lua function) params: 0 | vararg: nil
    -- player.__index.OnSaveAI => function (Lua function) params: 0 | vararg: nil
    -- player.__index.InitialSetup => function (Lua function) params: 0 | vararg: nil
    -- player.__index.PRTelep => function (Lua function) params: 0 | vararg: nil
    -- player.__index.SetModel => function (Lua function) params: 0 | vararg: nil
    -- player.__index.OnLoadAI => function (Lua function) params: 0 | vararg: nil
    -- player.__index.CheatGiveBow => function (Lua function) params: 0 | vararg: nil
    -- player.__index.OnReset => function (Lua function) params: 0 | vararg: nil
    -- player.__index.CheatEngine_stat => function (Lua function) params: 0 | vararg: nil
    -- player.__index.PRTelepShowMessage => function (Lua function) params: 0 | vararg: nil
    -- player.__index.OnAction => function (Lua function) params: 0 | vararg: nil
    -- player.__index.CheatEngine_equipweapon => function (Lua function) params: 0 | vararg: nil
    -- player.__index.CheatEngine_money => function (Lua function) params: 0 | vararg: nil
    -- player.__index.Server.OnInit => function (Lua function) params: 0 | vararg: nil
    -- player.__index.Reset => function (Lua function) params: 0 | vararg: nil
    -- #endregion

    --------------------------------------------------
    --- player.soul
    --------------------------------------------------
    -- #region 
    --- @class KCDUtilsEntitiesPlayerSoul
    _instance.soul = {}
    local rawSoul = raw.soul

    --- Gets the state of the soul.
    ---
    --- Example:
    --- ```lua
    ---   local hp = player.soul:GetState("health")
    --- ```
    --- Or with KCDUtils.Resources:
    --- ```lua
    ---   local hp = player.soul:GetState(KCDUtils.Resources.SoulStates.Health)
    --- ```
    ---
    ---@param state KCDUtilsSoulStates|string The state to get (e.g., "dirt", "health")
    ---@return number|nil
    function _instance.soul:GetState(state)
        return safeCall(rawSoul, "GetState", true, state)
    end

    --- Sets the given state value.
    --- @param state KCDUtilsSoulStates|string The state to set (e.g., "dirt", "health").
    --- @param value number The value to assign to the state.
    function _instance.soul:SetState(state, value)
        if rawSoul and rawSoul.SetState then
            rawSoul:SetState(state, value)
        end
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Raw soul or SetState method not found.")
        return nil
    end

    --- Returns the current level of the specified stat for the player.
    --- @param stat KCDUtilsSoulStats|KCDUtilsIntermediateStats|string The stat key (e.g., "strength", "vitality").
    --- @return number|nil level The stat level, or nil if not found.
    function _instance.soul:GetStatLevel(stat)
        if rawSoul and rawSoul.GetStatLevel then
            return rawSoul:GetStatLevel(stat)
        end
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Raw soul or GetStatLevel method not found.")
        return nil
    end

    --- Returns the current progress (XP) towards the next level for the specified stat.
    --- @param stat KCDUtilsSoulStats|KCDUtilsIntermediateStats|string The stat key.
    --- @return number|nil value The progress value, or nil if not found.
    function _instance.soul:GetStatProgress(stat)
        if rawSoul and rawSoul.GetStatProgress then
            return rawSoul:GetStatProgress(stat) or nil
        end
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Raw soul or GetStatProgress method not found.")
        return nil
    end

    --- Advances the specified stat to the given level for the player.
    --- @param stat KCDUtilsSoulStats|KCDUtilsIntermediateStats|string The stat key.
    --- @param level number The level to advance to.
    function _instance.soul:AdvanceToStatLevel(stat, level)
        if rawSoul and rawSoul.AdvanceToStatLevel then
            rawSoul:AdvanceToStatLevel(stat, level)
        end
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Raw soul or AdvanceToStatLevel method not found.")
        return nil
    end

    --- Adds experience points to the specified stat for the player.
    --- @param stat KCDUtilsSoulStats|KCDUtilsIntermediateStats|string The stat key.
    --- @param xp number The amount of XP to add.
    function _instance.soul:AddStatXP(stat, xp)
        if rawSoul and rawSoul.AddStatXP then
            rawSoul:AddStatXP(stat, xp)
        end
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Raw soul or AddStatXP method not found.")
        return nil
    end

    --- Returns the XP required for the next level of the specified stat.
    --- @param stat KCDUtilsSoulStats|string The stat key.
    --- @param xp number Current XP (optional, if needed by implementation).
    --- @return number|nil xp The XP required, or nil if not found.
    function _instance.soul:GetNextLevelStatXP(stat, xp)
        if rawSoul and rawSoul.GetNextLevelStatXP then
            return rawSoul:GetNextLevelStatXP(stat, xp)
        end
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Raw soul or GetNextLevelStatXP method not found.")
        return nil
    end

    --- Returns the value of a derived stat for the player.
    --- @param derivedStat KCDUtilsDerivedStats|KCDUtilsIntermediateStats|string The derived stat key.
    --- @return number|nil value The derived stat value, or nil if not found.
    function _instance.soul:GetDerivedStat(derivedStat)
        if rawSoul and rawSoul.GetDerivedStat then
            return rawSoul:GetDerivedStat(derivedStat)
        end
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        logger:Error("Raw soul or GetDerivedStat method not found.")
        return nil
    end

    --- Checks if the player has the specified skill.
    --- @param skill KCDUtilsSoulSkills|string The skill key.
    --- @return boolean|nil hasSkill True if the player has the skill, false/nil otherwise.
    function _instance.soul:HaveSkill(skill)
        return safeCall(rawSoul, "HaveSkill", true, skill)
    end

    --- Returns the current level of the specified skill for the player.
    --- @param skill KCDUtilsSoulSkills|string The skill key.
    --- @return number|nil value The skill level, or nil if not found.
    function _instance.soul:GetSkillLevel(skill)
        return safeCall(rawSoul, "GetSkillLevel", true, skill)
    end

    --- Returns the current progress (XP) towards the next level for the specified skill.
    --- @param skill KCDUtilsSoulSkills|string The skill key.
    --- @return number|nil progress The progress value, or nil if not found.
    function _instance.soul:GetSkillProgress(skill)
        return safeCall(rawSoul, "GetSkillProgress", true, skill)
    end

    --- Checks if the player has the specified ability.
    --- @param ability string The ability key.
    --- @return boolean|nil hasAbility True if the player has the ability, false/nil otherwise.
    function _instance.soul:HasAbility(ability)
        return safeCall(rawSoul, "HasAbility", true, ability)
    end

    --- Advances the specified skill to the given level for the player.
    --- @param skill KCDUtilsSoulSkills|string The skill key.
    --- @param level number The level to advance to.
    function _instance.soul:AdvanceToSkillLevel(skill, level)
        return safeCall(rawSoul, "AdvanceToSkillLevel", true, skill, level)
    end

    --- Adds experience points to the specified skill for the player.
    --- @param skill KCDUtilsSoulSkills|string The skill key.
    --- @param xp number The amount of XP to add.
    function _instance.soul:AddSkillXP(skill, xp)
        return safeCall(rawSoul, "AddSkillXP", true, skill, xp)
    end

    --- Returns the XP required for the next level of the specified skill.
    --- @param skill KCDUtilsSoulSkills|string The skill key.
    --- @return number|nil xp The XP required, or nil if not found.
    function _instance.soul:GetNextLevelSkillXP(skill)
        return safeCall(rawSoul, "GetNextLevelSkillXP", true, skill)
    end

    --- Adds a buff to the player by its ID.
    --- @param buffId string The buff identifier.
    function _instance.soul:AddBuff(buffId)
        return safeCall(rawSoul, "AddBuff", true, buffId)
    end

    --- Removes a specific buff instance from the player.
    --- @param buffInstance any The buff instance to remove.
    function _instance.soul:RemoveBuff(buffInstance)
        return safeCall(rawSoul, "RemoveBuff", true, buffInstance)
    end

    --- Removes all buffs from the player that match the given GUID.
    --- @param buffGuid string The GUID of the buff(s) to remove.
    function _instance.soul:RemoveAllBuffsByGuid(buffGuid)
        return safeCall(rawSoul, "RemoveAllBuffsByGuid", true, buffGuid)
    end

    --- Adds a perk to the player by its ID.
    --- @param perkId string The perk identifier.
    function _instance.soul:AddPerk(perkId)
        return safeCall(rawSoul, "AddPerk", true, perkId)
    end

    --- Checks if the player has the specified perk.
    --- @param perkId string The perk identifier.
    function _instance.soul:HasPerk(perkId)
        return safeCall(rawSoul, "HasPerk", true, perkId)
    end

    --- Removes a perk from the player by its ID.
    --- @param perkId string The perk identifier.
    function _instance.soul:RemovePerk(perkId)
        return safeCall(rawSoul, "RemovePerk", true, perkId)
    end

    --- Adds all codex entries in the players menu.
    function _instance.soul:AddAllCodexPerk()
        return safeCall(rawSoul, "AddAllCodexPerk", true)
    end

    --- Adds a meta role to the player by name.
    --- @param name string The name of the meta role.
    function _instance.soul:AddMetaRoleByName(name)
        return safeCall(rawSoul, "AddMetaRoleByName", true, name)
    end

    --- Removes a meta role from the player by name.
    --- @param name string The name of the meta role.
    function _instance.soul:RemoveMetaRoleByName(name)
        return safeCall(rawSoul, "RemoveMetaRoleByName", true, name)
    end

    --- Modifies the player's reputation for a given chance name, optionally propagating to the faction.
    --- @param repChanceName string The reputation chance name.
    --- @param propagateToFaction boolean Whether to propagate to the faction.
    function _instance.soul:ModifyPlayerReputation(repChanceName, propagateToFaction)
        return safeCall(rawSoul, "ModifyPlayerReputation", true, repChanceName, propagateToFaction)
    end

    --- Gets the relationship value between the player and another soul.
    --- @param otherSoulWuid string The WUID of the other soul.
    --- @return number|nil value The relationship value, or nil if not found.
    function _instance.soul:GetRelationship(otherSoulWuid)
        return safeCall(rawSoul, "GetRelationship", true, otherSoulWuid)
    end

    --- Returns 1 if the soul has maximum dominance, -1 if the shopkeeper has maximum dominance 
    --- @param shopkeeperSoulWuid string The WUID of the shopkeeper's soul.
    --- @return number|nil value The dominance value, or nil if not found.
    function _instance.soul:CalculateBarterDominance(shopkeeperSoulWuid)
        return safeCall(rawSoul, "CalculateBarterDominance", true, shopkeeperSoulWuid)
    end

    --- Checks if the player is currently in combat danger.
    --- @return boolean|nil hasDanger True if in danger, false otherwise.
    function _instance.soul:IsInCombatDanger()
        return safeCall(rawSoul, "IsInCombatDanger", true)
    end

    --- Checks if the player is currently in combat mode.
    --- @return boolean|nil hasCombatMode True if in combat mode, false otherwise.
    function _instance.soul:IsInCombatMode()
        return safeCall(rawSoul, "IsInCombatMode", true)
    end

    --- Checks if the player is currently in a tense circumstance.
    --- @return boolean|nil hasTenseCircumstance True if in a tense circumstance, false otherwise.
    function _instance.soul:IsInTenseCircumstance()
        return safeCall(rawSoul, "IsInTenseCircumstance", true)
    end

    --- Gets the string ID of the player's name.
    --- @return string|nil id The name string ID.
    function _instance.soul:GetNameStringId()
        return safeCall(rawSoul, "GetNameStringId", true)
    end

    --- Gets the text for the read caption object.
    --- @return string|nil text The caption text.
    function _instance.soul:GetReadCaptionObjectText()
        return safeCall(rawSoul, "GetReadCaptionObjectText", true)
    end

    --- Checks if the player is currently a public enemy.
    --- @return boolean|nil isPublicEnemy True if public enemy, false otherwise.
    function _instance.soul:IsPublicEnemy()
        return safeCall(rawSoul, "IsPublicEnemy", true)
    end

    --- Checks if it is legal to loot as the player.
    --- @return boolean|nil isLegalToLoot True if legal, false otherwise.
    function _instance.soul:IsLegalToLoot()
       return safeCall(rawSoul, "IsLegalToLoot", true)
    end

    --- Checks if the player is currently dialog restricted.
    --- @return boolean|nil isDialogRestricted True if dialog restricted, false otherwise.
    function _instance.soul:IsDialogRestricted()
        return safeCall(rawSoul, "IsDialogRestricted", true)
    end

    --- Returns a table=array containing metarole ids. 
    --- @return table|nil metaRoles The meta roles.
    function _instance.soul:GetMetaRoles()
        return safeCall(rawSoul, "GetMetaRoles", true)
    end

    --- Returns a table containing float-encoded times indexed by activities. 
    --- @return table|nil schedule The schedule.
    function _instance.soul:GetSchedule()
        return safeCall(rawSoul, "GetSchedule", true)
    end

    --- Returns social class as a table with Id, Name and Wealth keys.
    --- @return table|nil socialClass The social class.
    function _instance.soul:GetSocialClass()
        return safeCall(rawSoul, "GetSocialClass", true)
    end

    --- Returns a table containing the archetype properties.
    --- @return table|nil archetype The archetype.
    function _instance.soul:GetArchetype()
        return safeCall(rawSoul, "GetArchetype", true)
    end

    --- Gets the player's gender.
    --- @return number|nil gender The gender.
    function _instance.soul:GetGender()
        return safeCall(rawSoul, "GetGender", true)
    end

    --- Gets the player's gather multiplier.
    --- @return number|nil gatherMult The gather multiplier.
    function _instance.soul:GetGatherMult()
        return safeCall(rawSoul, "GetGatherMult", true)
    end

    --- Gets the player's faction ID.
    --- @return string|nil factionID The faction ID.
    function _instance.soul:GetFactionID()
        return safeCall(rawSoul, "GetFactionID", true)
    end

    --- Checks if the player has the specified script context.
    --- @param contextName string The context name.
    --- @return boolean|nil hasScriptContext True if the context exists, false otherwise.
    function _instance.soul:HasScriptContext(contextName)
        return safeCall(rawSoul, "HasScriptContext", true, contextName)
    end

    --- Checks if the player can eat the specified item.
    --- @param itemClassIdDef string The item class ID definition.
    --- @return boolean|nil canEatItem True if the item can be eaten, false otherwise.
    function _instance.soul:CanEatItem(itemClassIdDef)
        return safeCall(rawSoul, "CanEatItem", true, itemClassIdDef)
    end

    --- Makes the player eat the specified item.
    --- @param itemClassIdDef string The item class ID definition.
    function _instance.soul:EatItem(itemClassIdDef)
        return safeCall(rawSoul, "EatItem", true, itemClassIdDef)
    end

    --- Deals damage to a the given soul.
    --- @overload fun(stamina:number, health:number)
    --- @param stamina number The amount of stamina to deal.
    --- @param health number The amount of health to deal.
    --- @param attackerId string|nil (optional) The ID of the attacker. Default is "invalid"
    --- @param suppressHitreaction boolean|nil (optional) Whether to suppress hit reactions. Default is false
    --- @param bodyPart string|nil (optional) The body part to deal damage to. Default is "null"
    function _instance.soul:DealDamage(stamina, health, attackerId, suppressHitreaction, bodyPart)
        return safeCall(rawSoul, "DealDamage", true, stamina, health, attackerId, suppressHitreaction, bodyPart)
    end

    --- ### Currently not working
    --- Handles a companion-related event.
    --- Accepts any number and type of arguments from the engine.
    --- Logs all received parameters before forwarding them to rawSoul.
    function _instance.soul:OnCompanionEvent(...)
        local logger = KCDUtils.Core.Logger.Factory("PlayerAPI")
        local args = { ... }  -- capture all parameters into a table

        -- Log the incoming event call
        logger:Info("[OnCompanionEvent] Called with " .. tostring(#args) .. " argument(s).")
        for i, v in ipairs(args) do
            logger:Info("  arg[" .. i .. "] = " .. tostring(v))
        end

        -- Forward all parameters unchanged to the rawSoul implementation
        return rawSoul:OnCompanionEvent(...)
    end

    --- Set soul to dialog restricted mode so it cannot be speak to (hint will not be shown, and this functionality is implemented in lua, using IsDialogRestricted) Also deletes all unfinished requests 
    --- @param restrict boolean True to restrict, false to unrestrict.
    function _instance.soul:RestrictDialog(restrict)
        return safeCall(rawSoul, "RestrictDialog", true, restrict)
    end

    --- Heals bleeding effect from the player.
    --- @param healing float The amount of healing to apply.
    --- @param bodyPart KCDUtilsBodyPart The body part to heal.
    function _instance.soul:HealBleeding(healing, bodyPart)
        return safeCall(rawSoul, "HealBleeding", true, healing, bodyPart)
    end

    --- Gets the unique identifier of the soul.
    --- @return string|nil id The unique ID of the soul.
    function _instance.soul:GetId()
        return safeCall(rawSoul, "GetId", true)
    end
    -- #endregion

    --------------------------------------------------
    --- player.inventory
    --------------------------------------------------
    -- #region    
    -- player.inventory.__index.RemoveMoney => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.FindItem => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.GetMoney => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.GetCountOfClass => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.HasItem => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.GetCountOfCategory => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.DeleteItemOfClass => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.DeleteItem => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.GetId => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.AddItem => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.Dump => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.GetCount => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.RemoveAllItems => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.MoveItemOfClass => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.GetInventoryTable => function (Lua function) params: 0 | vararg: nil
    -- player.inventory.__index.CreateItem => function (Lua function) params: 0 | vararg: nil
    -- #endregion

    --------------------------------------------------
    --- player.player
    --------------------------------------------------
    -- #region    

    --- @class KCDUtilsEntitiesPlayerPlayer
    _instance.player = {}
    local rawPlayer = raw.player

    --- Checks if the player is currently laying down (e.g., in bed).
    --- @return boolean isLaying True if the player is laying, false otherwise.
    function _instance.player:IsLaying()
        return safeCall(rawPlayer, "IsLaying", true)
    end

    --- Checks if the player can use fast sleep (skip time quickly).
    --- @return boolean canSleepFast True if fast sleep is possible, false otherwise.
    function _instance.player:CanSleepFast()
        return safeCall(rawPlayer, "CanSleepFast", true)
    end

    --- Checks if the player can sleep at the current location.
    --- @return boolean canSleep True if sleeping is possible, false otherwise.
    function _instance.player:CanSleep()
        return safeCall(rawPlayer, "CanSleep", true)
    end

    --- Checks if the player can bond with a horse.
    --- @return boolean canBondHorse True if bonding is possible, false otherwise.
    function _instance.player:CanBondHorse()
        return safeCall(rawPlayer, "CanBondHorse", true)
    end

    --- Gets the player's current horse entity.
    --- @return any horse The player's horse entity, or nil if not available.
    function _instance.player:GetPlayerHorse()
        return safeCall(rawPlayer, "GetPlayerHorse", true)
    end

    --- Checks if the player can sleep and report a problem (e.g., for quest logic).
    --- @return boolean canSleepAndReportProblem True if possible, false otherwise.
    function _instance.player:CanSleepAndReportProblem()
        return safeCall(rawPlayer, "CanSleepAndReportProblem", true)
    end

    --- Checks if the player currently has a running dog objective.
    --- @return boolean hasObjective True if a dog objective is running, false otherwise.
    function _instance.player:HasRunningDogObjective()
        return safeCall(rawPlayer, "HasRunningDogObjective", true)
    end

    --- Checks if the player is currently sitting.
    --- @return boolean isSitting True if the player is sitting, false otherwise.
    function _instance.player:IsSitting()
        return safeCall(rawPlayer, "IsSitting", true)
    end

    --- Checks if the player is the target of combat chat.
    --- @return boolean isCombatChatTarget True if the player is a combat chat target, false otherwise.
    function _instance.player:IsCombatChatTarget()
        return safeCall(rawPlayer, "IsCombatChatTarget", true)
    end

    --- Checks if the player is locked to an opponent (e.g., in combat).
    --- @return boolean isLocked True if locked to an opponent, false otherwise.
    function _instance.player:IsLockedToOpponent()
        return safeCall(rawPlayer, "IsLockedToOpponent", true)
    end

    -- player.player.__index.OnBedInterrupt => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.OnBedStop => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.OnSleeping => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.OnEnterInteractive => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.OnEndInteractive => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.OnBedPrepareForDialog => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.HorseInspect => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.GetHorseId => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.ClearPlayerHorse => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.CanMountHorse => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.SetPlayerHorse => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.SetWhistling => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.RequestDogObjective => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.CancelDogObjective => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.FeedDog => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.PushBack => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.AddSoAction => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.SetAlcoTeleportTarget => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.GetFlyMode => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.SetFlyMode => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.AddLuaActions => function (Lua function) params: 0 | vararg: nil
    -- player.player.__index.EnableFastTravel => function (Lua function) params: 0 | vararg: nil
    -- #endregion

    --------------------------------------------------
    --- player.actor
    --------------------------------------------------
    -- #region
    --- @class KCDUtilsEntitiesPlayerActor
    _instance.actor = {}
    local rawActor = raw.actor

    --- Simuliert CameraShake über SetViewShake
    --- @param amount number Stärke des Shakes
    --- @param duration number Dauer in Sekunden
    --- @param frequency number Frequenz des Shakes
    function _instance.actor:CameraShake(amount, duration, frequency)
        -- Einfacher Mapping-Trick: Shake nur über SetViewShake
        local shakeAngle = { x = amount * 0.02, y = amount * 0.01, z = amount * 0.01 } -- leicht randomisiert
        local shakeShift = { x = 0, y = 0, z = 0 } -- keine Verschiebung
        local randomness = 0.5 -- optional: kann höher für mehr „wildes Wackeln“ sein

        rawActor:SetViewShake(shakeAngle, shakeShift, duration, frequency, randomness)
    end
    
    -- player.actor.__index.RequestStealthKill => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.EquipWeaponPreset => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetMaxHealth => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.EquipInventoryItem => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetHealth => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.IsMoreDirty => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetFrozenAmount => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.HasAcceptedChat => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetMovementRestriction => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.IsFlying => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CanChat => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.OpenItemSelectionSharpening => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.RequestMercyKill => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetSearchBeam => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetCloseColliderParts => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.RequestHuntAttack => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetHeadDir => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CanHuntAttack => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetHeadPos => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.IsWaitingForDialogueReply => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.RequestPutCorpse => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetLinkedEntity => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetAngles => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetViewShake => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.IsFollowing => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.PostPhysicalize => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.IsBodyMoreDirty => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetExtensionParams => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.Revive => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetSpectatorMode => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.WashItems => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetExtensionActivation => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.ClearForcedLookDir => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.RequestItemExchange => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.StartInteractiveActionByName => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CameraShake => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetPhysicalizationProfile => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.MakeLookAsActor => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CleanDirt => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.AddDirt => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetPhysicalizationProfile => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetAngles => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.EquipClothingPreset => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.OpenItemTransferStore => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.OpenItemMultiselectionFilter => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.OpenItemSelectionFilter => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.UnequipInventoryItem => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CanTalk => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.IsCarryingCorpse => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.IsUnconscious => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CanStealthKnockout => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.WashDirtAndBlood => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetDialogAnimationState => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.IsPlayerInButcheringDistance => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetForcedLookDir => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CanBeButchered => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.HasItemsInInventory => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.OpenChat => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.ResetScores => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CreateCodeEvent => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.HasChatRequest => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.ClearForcedLookObjectId => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.EnableAspect => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.DoChat => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.MakeLookAsSoul => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.AttachVulnerabilityEffect => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetMovementControlledByAnimation => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CanDoMercyKill => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.StandUp => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.IsPlayer => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.StartFollow => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SimulateOnAction => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CanHorsePullDown => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CanPutCorpse => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.TrackViewControlled => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetMaxHealth => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CanGrabCorpse => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.AddFrost => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetCurrentAnimationState => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.CanStealthKill => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.IsGhostPit => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetForcedLookObjectId => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.Butcher => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetLookIK => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetSpectatorMode => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.GetMaxArmor => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.SetHealth => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.RenderScore => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.RequestHorsePullDown => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.RequestGrabCorpse => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.AddBlood => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.Fall => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.RequestKnockOut => function (Lua function) params: 0 | vararg: nil
    -- player.actor.__index.ResetVulnerabilityEffects => function (Lua function) params: 0 | vararg: nil
    -- #endregion

    --------------------------------------------------
    --- player.human
    --------------------------------------------------
    -- #region
    --- @class KCDUtilsEntitiesPlayerHuman
    _instance.human = {}
    local rawHuman = raw.human

    --- Checks if the player can currently talk.
    --- @return boolean canTalk True if the player can talk, false otherwise.
    function _instance.human:CanTalk()
        return rawHuman:CanTalk()
    end

    --- Checks if the player can interact with the specified entity.
    --- @param entityId any The entity ID to check.
    --- @return boolean canInteract True if interaction is possible, false otherwise.
    function _instance.human:CanInteractWith(entityId)
        return rawHuman:CanInteractWith(entityId)
    end

    --- Requests a dialog interaction for the player.
    function _instance.human:RequestDialog()
        return rawHuman:RequestDialog()
    end

    --- Interrupts all active dialogs for the player.
    function _instance.human:InterruptDialogs()
        return rawHuman:InterruptDialogs()
    end

    --- Gets the source name for the current dialog request.
    --- @return string name The dialog source name.
    function _instance.human:GetDialogRequestSourceName()
        return rawHuman:GetDialogRequestSourceName()
    end

    --- Toggles the player's weapon (draw/holster).
    function _instance.human:ToggleWeapon()
        return rawHuman:ToggleWeapon()
    end

    --- Draws the player's weapon.
    function _instance.human:DrawWeapon()
        return rawHuman:DrawWeapon()
    end

    --- Holsters the player's weapon.
    function _instance.human:HolsterWeapon()
        return rawHuman:HolsterWeapon()
    end

    --- Checks if the player's weapon is currently drawn.
    --- @return boolean isDrawn True if drawn, false otherwise.
    function _instance.human:IsWeaponDrawn()
        return rawHuman:IsWeaponDrawn()
    end

    --- Toggles the player's weapon set.
    function _instance.human:ToggleWeaponSet()
        return rawHuman:ToggleWeaponSet()
    end

    --- Gets the archetype of the player's torch light.
    --- @return string archetype The torch light archetype.
    function _instance.human:GetTorchLightArchetype()
        return rawHuman:GetTorchLightArchetype()
    end

    --- Makes the player grab onto a ladder.
    --- @param ladderId any The ladder ID.
    function _instance.human:GrabOnLadder(ladderId)
        return rawHuman:GrabOnLadder(ladderId)
    end

    --- Checks if the player is currently on a ladder.
    --- @return boolean isOnLadder True if on a ladder, false otherwise.
    function _instance.human:IsOnLadder()
        return rawHuman:IsOnLadder()
    end

    --- Mounts the specified horse.
    --- @param horseId string The horse ID.
    function _instance.human:Mount(horseId)
        return rawHuman:Mount(horseId)
    end

    --- Dismounts from the current horse.
    function _instance.human:Dismount()
        return rawHuman:Dismount()
    end

    --- Performs bonding with the specified horse.
    --- @param horseId string The horse ID.
    function _instance.human:DoBonding(horseId)
        return rawHuman:DoBonding(horseId)
    end

    --- Gets the mount point for the specified horse.
    --- @param horseId string The horse ID.
    --- @return any mountPoint The mount point.
    function _instance.human:GetHorseMountPoint(horseId)
        return rawHuman:GetHorseMountPoint(horseId)
    end

    --- Forces the player to mount the specified horse.
    --- @param horseId string The horse ID.
    function _instance.human:ForceMount(horseId)
        return rawHuman:ForceMount(horseId)
    end

    --- Forces the player to dismount from the horse.
    function _instance.human:ForceDismount()
        return rawHuman:ForceDismount()
    end

    --- Starts reading the specified book.
    --- @param bookId string The book ID.
    function _instance.human:StartReading(bookId)
        return rawHuman:StartReading(bookId)
    end

    --- Gets the item currently held in the specified hand.
    --- @param handId string The hand ID.
    --- @return any item The item in hand.
    function _instance.human:GetItemInHand(handId)
        return rawHuman:GetItemInHand(handId)
    end

    --- Stops the current animation for the player.
    function _instance.human:StopAnim()
        return rawHuman:StopAnim()
    end

    --- Gets the player's current horse.
    --- @return any horse The horse entity.
    function _instance.human:GetHorse()
        return rawHuman:GetHorse()
    end

    --- Checks if the player is currently mounted on a horse.
    --- @return boolean isMounted True if mounted, false otherwise.
    function _instance.human:IsMounted()
        return rawHuman:IsMounted()
    end

    --- Requests to pickpocket the specified victim.
    --- @param victimEntityId string The victim's entity ID.
    function _instance.human:RequestPickpocketing(victimEntityId)
        return rawHuman:RequestPickpocketing(victimEntityId)
    end

    --- Checks if the player is currently pickpocketing.
    --- @return boolean isPickpocketing True if pickpocketing, false otherwise.
    function _instance.human:IsPickpocketing()
        return rawHuman:IsPickpocketing()
    end
    -- #endregion

    return _instance
end

KCDUtils.Entities.Player = Player
