---@class KCDUtilsLogger
local FactoryLogger = KCDUtils and KCDUtils.Logger or {}

local cache = {}

function FactoryLogger.Log(modName, message)
    System.LogAlways("[" .. modName .. "] " .. message)
end

function FactoryLogger.Info(modName, message)
    System.LogAlways("[" .. modName .. "] [INFO] " .. message)
end

function FactoryLogger.Warn(modName, message)
    System.LogAlways("[" .. modName .. "] [WARN] " .. message)
end

function FactoryLogger.Error(modName, message)
    System.LogAlways("[" .. modName .. "] [ERROR] " .. message)
end

function FactoryLogger.Factory(modName)
    if cache[modName] then
        return cache[modName]
    end

    local instance = {}

    --- Logs a message with the mod name.
    --- @param message string
    instance.Log = function(message) return FactoryLogger.Log(modName, message) end

    --- Logs an info message.
    --- @param message string
    instance.Info = function(message) return FactoryLogger.Info(modName, message) end

    --- Logs a warning message.
    --- @param message string
    instance.Warn = function(message) return FactoryLogger.Warn(modName, message) end

    --- Logs an error message.
    --- @param message string
    instance.Error = function(message) return FactoryLogger.Error(modName, message) end

    cache[modName] = instance
    return instance
end

---@type KCDUtilsLogger
KCDUtils.Logger = FactoryLogger