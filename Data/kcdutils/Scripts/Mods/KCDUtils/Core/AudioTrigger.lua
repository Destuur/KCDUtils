KCDUtils.AudioTrigger = {
    _currentSounds = {}
}

function KCDUtils.AudioTrigger:Play(modName, player, triggerName)
    if not modName or not player or not triggerName then return end
    local logger = KCDUtils.Logger.Factory(modName or "UnknownMod")

    local triggerId = AudioUtils.LookupTriggerID(triggerName)
    if not triggerId then
        logger:Warn("Could not find audio trigger: "..triggerName)
        return
    end

    local ownerId = player:GetDefaultAuxAudioProxyID()
    self._currentSounds[modName] = self._currentSounds[modName] or {}
    self._currentSounds[modName][triggerId] = ownerId

    player:ExecuteAudioTrigger(triggerId, ownerId)
end

function KCDUtils.AudioTrigger:Stop(modName, triggerId, player)
    local modSounds = self._currentSounds[modName]
    if modSounds and modSounds[triggerId] then
        pcall(function()
            player:StopAudioTrigger(triggerId, modSounds[triggerId])
        end)
        modSounds[triggerId] = nil
    end
end

function KCDUtils.AudioTrigger:StopAll(modName, player)
    local modSounds = self._currentSounds[modName]
    if not modSounds then return end

    for triggerId, ownerId in pairs(modSounds) do
        pcall(function()
            player:StopAudioTrigger(triggerId, ownerId)
        end)
    end

    self._currentSounds[modName] = nil
end

function KCDUtils.AudioTrigger:PlayRandom(modName, entity, triggerList)
    if not entity or type(triggerList) ~= "table" or #triggerList == 0 then return end

    local triggerName = triggerList[math.random(#triggerList)]
    self:Play(modName, entity, triggerName)
end