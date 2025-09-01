KCDUtils = KCDUtils or {}
KCDUtils.Core = KCDUtils.Core or {}

---@class KCDUtilsCoreCalendar
KCDUtils.Core.Calendar = KCDUtils.Core.Calendar or {}

--- Sets ratio of world time.
--- @param worldTimeRatio float world time / game time ratio (float) 
function KCDUtils.Core.Calendar.SetWorldTimeRatio(worldTimeRatio)
    local logger = KCDUtils.Core.Logger.Factory("Calendar")
    if type(worldTimeRatio) ~= "number" then
        logger:Error("worldTimeRatio must be a number")
    end
    Calendar.SetWorldTimeRatio(worldTimeRatio)
end

--- Gets the current hour of the day in the game world.
--- @return float current hour of the day (0-23)
function KCDUtils.Core.Calendar.GetWorldHourOfDay()
    return Calendar.GetWorldHourOfDay()
end

--- Returns true in night, false in day. Uses time from TimeOfDay.
--- @return boolean isNightTime is night time
function KCDUtils.Core.Calendar.IsNightTimeOfDay()
    return Calendar.IsNightTimeOfDay()
end

--- Returns game time (whole seconds from start of level)
--- @return float seconds game time in seconds
function KCDUtils.Core.Calendar.GetGameTime()
    return Calendar.GetGameTime()
end

--- Returns number of whole days from start of level.
--- @return float days world day
function KCDUtils.Core.Calendar.GetWorldDay()
    return Calendar.GetWorldDay()
end

--- Returns ordinal number of day in current week. Range is <0,6> monday is 0
--- @return int day of week
function KCDUtils.Core.Calendar.GetWorldDayOfWeek()
    return Calendar.GetWorldDayOfWeek()
end

--- Returns world time (whole seconds from start of level)
--- @return int worldTime
function KCDUtils.Core.Calendar.GetWorldTime()
    return Calendar.GetWorldTime()
end

--- Returns ratio of world time.
--- @return int worldTimeRatio
function KCDUtils.Core.Calendar.GetWorldTimeRatio()
    return Calendar.GetWorldTimeRatio()
end

--- Returns true if world time is paused.
--- @return boolean isPaused
function KCDUtils.Core.Calendar.IsWorldTimePaused()
    return Calendar.IsWorldTimePaused()
end

--- Sets ratio of world time.
--- @param worldTimeRatio int New world time (whole seconds from start of level) to be set. Must not be set backwards. 
function KCDUtils.Core.Calendar.SetWorldTime(worldTimeRatio)
    local logger = KCDUtils.Core.Logger.Factory("Calendar")
    if type(worldTimeRatio) ~= "number" then
        logger:Error("worldTimeRatio must be a number")
    end
    Calendar.SetWorldTime(worldTimeRatio)
end