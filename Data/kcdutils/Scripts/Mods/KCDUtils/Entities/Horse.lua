KCDUtils = KCDUtils or {}
KCDUtils.Entities = KCDUtils.Entities or {}
KCDUtils.Entities.Horse = KCDUtils.Entities.Horse or {}

function KCDUtils.Entities.Horse.LogTable(tbl, indent, visited)
    indent = indent or 0
    visited = visited or {}

    if visited[tbl] then
        System.LogAlways(string.rep("  ", indent) .. "*cycle*")
        return
    end
    visited[tbl] = true

    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. tostring(k) .. ": "
        if type(v) == "table" then
            System.LogAlways(formatting)
            KCDUtils.Entities.Horse.LogTable(v, indent + 1, visited)
        else
            System.LogAlways(formatting .. tostring(v))
        end
    end
end

-- [Function] Horse.FlowEvents.Inputs.Spawn.1 | params: 0 | vararg: false
-- [Function] Horse.AddLootAction | params: 0 | vararg: false
-- [Function] Horse.Event_SpawnKeep | params: 0 | vararg: false
-- [Function] Horse.Event_Spawned | params: 0 | vararg: false
-- [Function] Horse.OnInspect | params: 0 | vararg: false
-- [Function] Horse.OnDestroy | params: 0 | vararg: false
-- [Function] Horse.OnPropertyChange | params: 0 | vararg: false
-- [Function] Horse.OnLoadAI | params: 0 | vararg: false
-- [Function] Horse.SetInspectableByPlayer | params: 0 | vararg: false
-- [Function] Horse.OnSaveAI | params: 0 | vararg: false
-- [Function] Horse.Expose | params: 0 | vararg: false
-- [Table] Horse.__index
--   (Metatable __index of Horse.__index)
-- [Table] Horse.Server
-- [Function] Horse.Server.OnInit | params: 0 | vararg: false
-- [Function] Horse.NotifyRemoval | params: 0 | vararg: false
-- [Function] Horse.OnSave | params: 0 | vararg: false
-- [Function] Horse.GetReturnToPoolWeight | params: 0 | vararg: false
-- [Function] Horse.OnReset | params: 0 | vararg: false
-- [Function] Horse.GetMountableByPlayer | params: 0 | vararg: false
-- [Function] Horse.IsUsable | params: 0 | vararg: false
-- [Function] Horse.InitialSetup | params: 0 | vararg: false
-- [Function] Horse.SetMountableByPlayer | params: 0 | vararg: false
-- [Function] Horse.OnMount | params: 0 | vararg: false
-- [Function] Horse.GetActions | params: 0 | vararg: false
-- [Function] Horse.OnEditorSetGameMode | params: 0 | vararg: false
-- [Function] Horse.SetMountIsLegal | params: 0 | vararg: false
-- [Function] Horse.IsMountLegal | params: 0 | vararg: false
-- [Function] Horse.ResetCommon | params: 0 | vararg: false
-- [Table] Horse.Editor
-- [Function] Horse.SetMountableByPlayerDisabledFromAI | params: 0 | vararg: false
-- [Function] Horse.OnButcher | params: 0 | vararg: false
-- [Function] Horse.RegisterAI | params: 0 | vararg: false
-- [Function] Horse.OnUsed | params: 0 | vararg: false
-- [Function] Horse.OnLoad | params: 0 | vararg: false
-- [Table] Horse.collisionCapsule
-- [Table] Horse.collisionCapsule.posCarcass
-- [Table] Horse.collisionCapsule.pos
-- [Table] Horse.collisionCapsule.axis
-- [Function] Horse.Event_Spawn | params: 0 | vararg: false
-- [Function] Horse.OnBonding | params: 0 | vararg: false
-- [Function] Horse.OnSpawn | params: 0 | vararg: false
-- [Table] Horse.AI
-- [Function] Horse.GetDogActions | params: 0 | vararg: false
-- [Function] Horse.ResetAIParameters | params: 0 | vararg: false
-- [Table] Horse.Client
-- [Function] Horse.AddAnimalLootAction | params: 0 | vararg: false
-- [Function] Horse.GetFlowgraphForwardingEntity | params: 0 | vararg: false
-- [Function] Horse.OnStartle | params: 0 | vararg: false
-- [Function] Horse.SetActorModel | params: 0 | vararg: false
-- [Function] Horse.Event_Spawn_Internal | params: 0 | vararg: false
-- [Function] Horse.GetInspectableByPlayer | params: 0 | vararg: false
-- [Function] Horse.ReviveInEditor | params: 0 | vararg: false
-- [Function] Horse.ForceUsable | params: 0 | vararg: false