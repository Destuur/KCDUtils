---@meta
---@class (exact) KCDUtils*on_handler
---@field public CombatStateChanged fun(data:table) Event fired when the combat state changes
---@field public DistanceTravelled fun(data:table) Event fired when the player travels a certain distance
---@field public MoneyThresholdReached fun(data:table) Event fired when the player's money crosses a certain threshold (up or down)
---@field public MountedStateChanged fun(data:table) Event fired when the player's mounted state changes
---@field public NearbyEntitiesDetected fun(data:table) Event fired when nearby entities are detected
---@field public OnGameplayStarted fun() Event fired when gameplay starts (alias for GameplayStarted)
---@field public RainThresholdReached fun(data:table) Event fired when the rain intensity crosses a certain threshold (up or down)
---@field public SkillLevelReached fun(data:table) Event fired when a skill reaches a certain level
---@field public StateThresholdDetected fun(data:table) Event fired when a game state crosses a certain threshold (up or down)
---@field public TimeOfDayReached fun(data:table) Event fired when a certain time of day is reached
---@field public UnderRoofChanged fun(data:table) Event fired when the player's under-roof state changes
---@field public WeaponStateChanged fun(data:table) Event fired when the player's weapon state changes
---@field public WorldDayOfWeekReached fun(data:table) Event fired when a certain day of the week is reached
---@field public Add fun(self, eventName:string, callback:fun(data:table)):table Subscribe to an event. Returns a subscription handle
---@field public Remove fun(self, subscription:table) Remove a subscription returned by Add
---@field public Pause fun(self, subscription:table) Pause a subscription
---@field public Resume fun(self, subscription:table) Resume a paused subscription

local dummy = {}
return dummy
