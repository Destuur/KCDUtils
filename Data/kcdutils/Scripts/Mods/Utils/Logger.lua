---@class KCDUtilsLogger
local FactoryLogger = KCDUtils and KCDUtils.Logger or {}

local cache = {}

---Factory for creating/retrieving a Logger instance for a given mod.
---@param modName string Unique mod identifier
function FactoryLogger.Factory(modName)
    if cache[modName] then
        return cache[modName]
    end

    local instance = {
        Name = modName
    }

    --- Logs a message with the mod name.
    --- @param message string
    function instance:Log(message)
        System.LogAlways("$8[" .. self.Name .. "] $1" .. message)
    end

    --- Logs an info message with the mod name.
    --- @param message string
    function instance:Info(message)
        System.LogAlways("$8[" .. self.Name .. "]$3[INFO] $1" .. message)
    end

    --- Logs a warning message with the mod name.
    --- @param message string
    function instance:Warn(message)
        System.LogAlways("$8[" .. self.Name .. "]$6[WARN] $1" .. message)
    end

    --- Logs an error message with the mod name.
    --- @param message string
    function instance:Error(message)
        System.LogAlways("$8[" .. self.Name .. "]$4[ERROR] $1" .. message)
    end

    cache[modName] = instance
    return instance
end

---@type KCDUtilsLogger
KCDUtils.Logger = FactoryLogger
