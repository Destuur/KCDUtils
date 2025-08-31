---@class KCDUtilsTestsPlayer
KCDUtils.Test.Player = KCDUtils.Test.Player or {}

--------------------------------------------------
--- Assertions
--------------------------------------------------
-- #region Assertions

local function assertEqual(actual, expected, message)
    local logger = KCDUtils.Core.Logger.Factory("Tests.Player")
    if actual ~= expected then
        local errorMessage = string.format("Assertion failed: %s (expected: %s, got: %s)", message or "", tostring(expected), tostring(actual))
        logger:Error(errorMessage)
    end
end

local function assertNotNil(value, message)
    local logger = KCDUtils.Core.Logger.Factory("Tests.Player")
    if value == nil then
        local errorMessage = string.format("Assertion failed: %s (value is nil)", message or "")
        logger:Error(errorMessage)
    end
end

local function assertNil(value, message)
    local logger = KCDUtils.Core.Logger.Factory("Tests.Player")
    if value ~= nil then
        local errorMessage = string.format("Assertion failed: %s (value is not nil)", message or "")
        logger:Error(errorMessage)
    end
end

local function assertTrue(value, message)
    local logger = KCDUtils.Core.Logger.Factory("Tests.Player")
    if value ~= true then
        local errorMessage = string.format("Assertion failed: %s (value is not true)", message or "")
        logger:Error(errorMessage)
    end
end

local function assertFalse(value, message)
    local logger = KCDUtils.Core.Logger.Factory("Tests.Player")
    if value ~= false then
        local errorMessage = string.format("Assertion failed: %s (value is not false)", message or "")
        logger:Error(errorMessage)
    end
end

local function assertType(value, expectedType, message)
    local logger = KCDUtils.Core.Logger.Factory("Tests.Player")
    if type(value) ~= expectedType then
        local errorMessage = string.format("Assertion failed: %s (expected type: %s, got: %s)", message or "", expectedType, type(value))
        logger:Error(errorMessage)
    end
end

local function assertFunction(value, message)
    assertType(value, "function", message)
end

local function assertTable(value, message)
    assertType(value, "table", message)
end

local function assertString(value, message)
    assertType(value, "string", message)
end

local function assertNumber(value, message)
    assertType(value, "number", message)
end

local function assertBoolean(value, message)
    assertType(value, "boolean", message)
end

-- #endregion Assertions

local function createTestVariables()
    local logger = KCDUtils.Core.Logger.Factory("Tests.Player")
    if not player then
        return nil
    end

    return {
        testMethod = KCDUtils.Debug.TestMethod,
        logger = logger
    }
end

local function stateTest()
    local testVars = createTestVariables()
    if not testVars then
        return
    end

    
    local testMethod = testVars.testMethod
    local logger = testVars.logger

    logger:Info("Starting Player Stat tests...")

    if not player then
        logger:Error("Player entity not found, aborting tests.")
        return
    end

    if player then
        testMethod(player.soul, "GetState", "health")
        testMethod(player.soul, "GetState", "stamina")
        testMethod(player.soul, "GetState", "exhaust")
        testMethod(player.soul, "GetState", "karma")
        testMethod(player.soul, "GetState", "invalid_state")

        testMethod(player.soul, "SetState", "health", 50)
        testMethod(player.soul, "SetState", "exhaust", 20)
        testMethod(player.soul, "SetState", "invalid_state", 0.5)

        testMethod(player.soul, "DealDamage", 40)
    end

    logger:Info("Player Stat tests completed.")
end

local function statTest()
    local testVars = createTestVariables()
    if not testVars then
        return
    end

    local testMethod = testVars.testMethod
    local logger = testVars.logger

    logger:Info("Starting Player Stat tests...")

    if not player then
        logger:Error("Player entity not found, aborting tests.")
        return
    end

    if player then
        testMethod(player.soul, "GetStatLevel", KCDUtils.Resources.SoulStats.StoryProgress)
        testMethod(player.soul, "GetStatLevel", "agility")
        testMethod(player.soul, "GetStatLevel", "invalid_state")

        testMethod(player.soul, "GetStatProgress", KCDUtils.Resources.SoulStats.StoryProgress)
        testMethod(player.soul, "GetStatProgress", "agility")
        testMethod(player.soul, "GetStatProgress", "invalid_state")

        testMethod(player.soul, "AdvanceToStatLevel", KCDUtils.Resources.SoulStats.StoryProgress, 10)
        testMethod(player.soul, "AdvanceToStatLevel", "agility", 10)
        testMethod(player.soul, "AdvanceToStatLevel", "invalid_state", 0)

        testMethod(player.soul, "AddStatXP", KCDUtils.Resources.SoulStats.StoryProgress, 100000)
        testMethod(player.soul, "AddStatXP", "agility", 50000)
        testMethod(player.soul, "AddStatXP", "invalid_state", 100)

        testMethod(player.soul, "GetNextLevelStatXP", KCDUtils.Resources.SoulStats.StoryProgress)
        testMethod(player.soul, "GetNextLevelStatXP", "agility")
        testMethod(player.soul, "GetNextLevelStatXP", "invalid_state")

        testMethod(player.soul, "GetDerivedStat", KCDUtils.Resources.DerivedStats.Bloodiness)
        testMethod(player.soul, "GetDerivedStat", "bld")
        testMethod(player.soul, "GetDerivedStat", "invalid_state")
    end

    logger:Info("Player Stat tests completed.")
end

local function abilityTest()
    local testVars = createTestVariables()
    if not testVars then
        return
    end

    
    local testMethod = testVars.testMethod
    local logger = testVars.logger

    logger:Info("Starting Player Ability tests...")

    if not player then
        logger:Error("Player entity not found, aborting tests.")
        return
    end

    if player then
        testMethod(player.soul, "HasAbility", "Finticka")
        testMethod(player.soul, "HasAbility", "StealthKill")
        testMethod(player.soul, "HasAbility", "invalid_state")
    end

    logger:Info("Player Ability tests completed.")
end

local function skillTest()
    local testVars = createTestVariables()
    if not testVars then
        return
    end

    
    local testMethod = testVars.testMethod
    local logger = testVars.logger

    logger:Info("Starting Player Skill tests...")

    if not player then
        logger:Error("Player entity not found, aborting tests.")
        return
    end

    if player then
        testMethod(player.soul, "HaveSkill", KCDUtils.Resources.SoulSkills.Alchemy)
        testMethod(player.soul, "HaveSkill", "alchemy")
        testMethod(player.soul, "HaveSkill", "invalid_state")

        testMethod(player.soul, "GetSkillLevel", KCDUtils.Resources.SoulSkills.Alchemy)
        testMethod(player.soul, "GetSkillLevel", "alchemy")
        testMethod(player.soul, "GetSkillLevel", "invalid_state")

        testMethod(player.soul, "GetSkillProgress", KCDUtils.Resources.SoulSkills.Alchemy)
        testMethod(player.soul, "GetSkillProgress", "alchemy")
        testMethod(player.soul, "GetSkillProgress", "invalid_state")

        testMethod(player.soul, "AdvanceToSkillLevel", KCDUtils.Resources.SoulSkills.Alchemy, 10)
        testMethod(player.soul, "AdvanceToSkillLevel", "alchemy", 10)
        testMethod(player.soul, "AdvanceToSkillLevel", "invalid_state", 10)

        testMethod(player.soul, "AddSkillXP", KCDUtils.Resources.SoulSkills.Alchemy, 1000)
        testMethod(player.soul, "AddSkillXP", "alchemy", 1000)
        testMethod(player.soul, "AddSkillXP", "invalid_state", 1000)

        testMethod(player.soul, "GetNextLevelSkillXP", KCDUtils.Resources.SoulSkills.Alchemy)
        testMethod(player.soul, "GetNextLevelSkillXP", "alchemy")
        testMethod(player.soul, "GetNextLevelSkillXP", "invalid_state")
    end

    logger:Info("Player Skill tests completed.")
end

local function buffTest()
    local testVars = createTestVariables()
    if not testVars then
        return
    end

    
    local testMethod = testVars.testMethod
    local logger = testVars.logger

    logger:Info("Starting Player Buff tests...")

    if not player then
        logger:Error("Player entity not found, aborting tests.")
        return
    end

    if player then
        testMethod(player.soul, "AddBuff", "27c2fd6a-9b87-4d1f-b434-44f5ec3fa426") --buff_vitality_potion
        testMethod(player.soul, "AddBuff", "27e0c970-cf34-428a-91ff-35c1da071665") --buff_insomia_potion
        testMethod(player.soul, "AddBuff", "2f76aa98-165f-4105-be87-61b630fe70b8") --buff_painkiller

        testMethod(player.soul, "RemoveBuff", "27c2fd6a-9b87-4d1f-b434-44f5ec3fa426") --buff_vitality_potion
        testMethod(player.soul, "RemoveBuff", "27e0c970-cf34-428a-91ff-35c1da071665") --buff_insomia_potion
        testMethod(player.soul, "RemoveBuff", "2f76aa98-165f-4105-be87-61b630fe70b8") --buff_painkiller

        testMethod(player.soul, "RemoveAllBuffsByGuid", "27c2fd6a-9b87-4d1f-b434-44f5ec3fa426") --buff_vitality_potion
        testMethod(player.soul, "RemoveAllBuffsByGuid", "27e0c970-cf34-428a-91ff-35c1da071665") --buff_insomia_potion
        testMethod(player.soul, "RemoveAllBuffsByGuid", "2f76aa98-165f-4105-be87-61b630fe70b8") --buff_painkiller

    end

    logger:Info("Player Buff tests completed.")
end

local function perkTest()
    local testVars = createTestVariables()
    if not testVars then
        return
    end

    
    local testMethod = testVars.testMethod
    local logger = testVars.logger

    logger:Info("Starting Player Perk tests...")

    if not player then
        logger:Error("Player entity not found, aborting tests.")
        return
    end

    if player then
        testMethod(player.soul, "AddPerk", "11be4b56-6e08-415a-b7c1-1629528806ff") --shy
        testMethod(player.soul, "AddPerk", "6212b0b4-35db-4919-bfcb-f383156c62e1") --numbskull
        testMethod(player.soul, "AddPerk", "7ce6444f-78ab-454c-b008-cdfgefef") --invalid_perk
        
        testMethod(player.soul, "HasPerk", "11be4b56-6e08-415a-b7c1-1629528806ff") --shy
        testMethod(player.soul, "HasPerk", "6212b0b4-35db-4919-bfcb-f383156c62e1") --numbskull
        testMethod(player.soul, "HasPerk", "7ce6444f-78ab-454c-b008-cdfgefef") --invalid_perk

        testMethod(player.soul, "RemovePerk", "11be4b56-6e08-415a-b7c1-1629528806ff") --shy
        testMethod(player.soul, "RemovePerk", "6212b0b4-35db-4919-bfcb-f383156c62e1") --numbskull
        testMethod(player.soul, "RemovePerk", "7ce6444f-78ab-454c-b008-cdfgefef") --invalid_perk

        testMethod(player.soul, "AddAllCodexPerk")
    end

    logger:Info("Player Perk tests completed.")
end

local function metaRoleTest()
    local testVars = createTestVariables()
    if not testVars then
        return
    end

    
    local testMethod = testVars.testMethod
    local logger = testVars.logger

    logger:Info("Starting Player Meta Role tests...")

    if not player then
        logger:Error("Player entity not found, aborting tests.")
        return
    end

    if player then
        testMethod(player.soul, "AddMetaRoleByName", "ALCHEMY_BIGGER_AMOUNTS_OF_INGREDIENTS_BELLADONA")
        testMethod(player.soul, "AddMetaRoleByName", "HANS_UHER_SBIRA_KYTKY")
        testMethod(player.soul, "AddMetaRoleByName", "role_ALCHYMIE_BODLAKU_BYLO_MOC")
        testMethod(player.soul, "AddMetaRoleByName", "InvalidRole")

        testMethod(player.soul, "RemoveMetaRoleByName", "ALCHEMY_BIGGER_AMOUNTS_OF_INGREDIENTS_BELLADONA")
        testMethod(player.soul, "RemoveMetaRoleByName", "role_ALCHYMIE_BODLAKU_BYLO_MOC")
        testMethod(player.soul, "RemoveMetaRoleByName", "InvalidRole")
        testMethod(player.soul, "RemoveMetaRoleByName", "PLAYER")
        testMethod(player.soul, "AddMetaRoleByName", "PLAYER")

        testMethod(player.soul, "ModifyPlayerReputation", "kutnohorsko_outskirts", 5)
        testMethod(player.soul, "ModifyPlayerReputation", "kutnohorsko_settlements_suchdol_commonFolk_peasants_parcel01", 5)
        testMethod(player.soul, "ModifyPlayerReputation", "invalid_state", 5)

        testMethod(player.soul, "GetRelationship", "kutnohorsko_outskirts")
        testMethod(player.soul, "GetRelationship", "kutnohorsko_settlements_suchdol_commonFolk_peasants_parcel01")
        testMethod(player.soul, "GetRelationship", "invalid_state")

        testMethod(player.soul, "GetMetaRoles")
    end

    logger:Info("Player Meta Role tests completed.")
end

local function envStateTests()
    local testVars = createTestVariables()
    if not testVars then
        return
    end

    
    local testMethod = testVars.testMethod
    local logger = testVars.logger

    logger:Info("Starting Player Environment State tests...")

    if not player then
        logger:Error("Player entity not found, aborting tests.")
        return
    end

    if player then
        testMethod(player.soul, "IsInCombatDanger")
        testMethod(player.soul, "IsInCombatMode")
        testMethod(player.soul, "IsInTenseCircumstance")
        testMethod(player.soul, "GetNameStringId")
        testMethod(player.soul, "GetReadCaptionObjectText")
        testMethod(player.soul, "IsPublicEnemy")
        testMethod(player.soul, "IsLegalToLoot")
        testMethod(player.soul, "IsDialogRestricted")
        testMethod(player.soul, "GetSchedule")
        testMethod(player.soul, "GetSocialClass")
        testMethod(player.soul, "GetArchetype")
        testMethod(player.soul, "GetGender")
        testMethod(player.soul, "GetGatherMult")
        testMethod(player.soul, "GetFactionID")
        testMethod(player.soul, "HasScriptContext")
        testMethod(player.soul, "OnCompanionEvent")
        testMethod(player.soul, "OnCompanionEvent", "OnCompanionEvent")
        testMethod(player.soul, "RestrictDialog")
        testMethod(player.soul, "HealBleeding")
        testMethod(player.soul, "GetId")
    end

    logger:Info("Player Environment State tests completed.")
end

local function itemTests()
    local testVars = createTestVariables()
    if not testVars then
        return
    end

    
    local testMethod = testVars.testMethod
    local logger = testVars.logger

    logger:Info("Starting Player Item tests...")

    if not player then
        logger:Error("Player entity not found, aborting tests.")
        return
    end

    if player then
        testMethod(player.soul, "CanEatItem")
        testMethod(player.soul, "EatItem", "item_id")
        testMethod(player.soul, "AddItem", "item_id", 1)
        testMethod(player.soul, "RemoveItem", "item_id", 1)
        testMethod(player.soul, "GetItemInfo", "item_id")
    end

    logger:Info("Player Item tests completed.")
end

function KCDUtils.Test.Player.Initialize()
    KCDUtils.Core.Event.OnGameplayStarted(KCDUtils.Test.Player)
end

function KCDUtils.Test.Player.OnGameplayStarted()
    local logger = KCDUtils.Core.Logger.Factory("Tests.Player")
    if not KCDUtils.Test.Player.initiated then
        KCDUtils.Test.Player.initiated = true
        if not KCDUtils.Debug then
            logger:Error("KCDUtils.Debug module not found, cannot run tests.")
            return
        end

        stateTest()
        statTest()
        skillTest()
        abilityTest()
        envStateTests()
        itemTests()
        buffTest()
        perkTest()
        metaRoleTest()

    end
    logger:Info("Player tests completed.")
end