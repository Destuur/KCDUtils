---@meta
---@class (exact) KCDUtils*on_handler
---@field public CombatStateChanged fun(data:table)
---@field public DialogStateChanged fun(data:table)
---@field public DistanceTravelled fun(data:table)
---@field public MoneyThresholdReached fun(data:table)
---@field public MountedStateChanged fun(data:table)
---@field public NearbyEntitiesDetected fun(data:table)
---@field public OnGameplayStarted fun()
---@field public RainThresholdReached fun(data:table)
---@field public SkillLevelReached fun(data:table)
---@field public StateThresholdDetected fun(data:table)
---@field public TimeOfDayReached fun(data:table)
---@field public UnderRoofChanged fun(data:table)
---@field public WeaponStateChanged fun(data:table)
---@field public WorldDayOfWeekReached fun(data:table)
---@overload fun(self:KCDUtils*on_handler, eventName:string, callback:fun(data:table))
---@field public Add fun(self:KCDUtils*on_handler, eventName:string, callback:fun(data:table), config:table|nil)
---@field public Remove fun(self:KCDUtils*on_handler, subscription:KCDUtilsEventSubscription)
---@field public Pause fun(self:KCDUtils*on_handler, subscription:KCDUtilsEventSubscription)
---@field public Resume fun(self:KCDUtils*on_handler, subscription:KCDUtilsEventSubscription)

---@class KCDUtilsEventSubscription
---@field callback fun(...):void
---@field once boolean
---@field isPaused boolean

---@class (exact) KCDUtilsEvent
---@field Add fun(self:KCDUtilsEvent, callback:fun(...):void, config:table|nil)
---@field Remove fun(self:KCDUtilsEvent, subscription:KCDUtilsEventSubscription)
---@field Trigger fun(self:KCDUtilsEvent, ...):void
---@field Pause fun(self:KCDUtilsEvent, subscription:KCDUtilsEventSubscription)
---@field Resume fun(self:KCDUtilsEvent, subscription:KCDUtilsEventSubscription)


local dummy = {}
return dummy
