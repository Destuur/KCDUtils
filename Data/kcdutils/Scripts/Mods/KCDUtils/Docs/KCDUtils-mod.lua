---@meta
---@class (exact) KCDUtils*mod
---@field public Name string Name of the mod
---@field public Logger KCDUtilsLogger Logger object
---@field public DB KCDUtilsDB Database object
---@field public On KCDUtils*on_handler On-Handler for subscribing to events
---@field public Events table Event table (auto-populated)
---@field public Config table Configuration table (empty by default)
---@field public OnGameplayStarted fun() Optional callback fired on gameplay start
---@field public TriggerCustomEvent fun(message:string) Optional custom method to trigger events

---@type KCDUtils*mod
local dummy = {}
return dummy
