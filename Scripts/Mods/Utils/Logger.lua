---@class KCDUtilsLogger
local FactoryLogger = KCDUtils and KCDUtils.Logger or {}

local cache = {}

function FactoryLogger.Log(modName, message)
    System.LogAlways("$8[" .. modName .. "] $0" .. message)
end

function FactoryLogger.Info(modName, message)
    System.LogAlways("$8[" .. modName .. "]$2[INFO] $0" .. message)
end

function FactoryLogger.Warn(modName, message)
    System.LogAlways("$8[" .. modName .. "]$4[WARN] $0" .. message)
end

function FactoryLogger.Error(modName, message)
    System.LogAlways("$8[" .. modName .. "]$1[ERROR] $0" .. message)
end

function FactoryLogger.Factory(modName)
    if cache[modName] then
        return cache[modName]
    end

    local instance = {}

    --- Logs a message with the mod name.
    --- @param message string
    local function Log(message)
        return FactoryLogger.Log(modName, message)
    end

    --- Logs an info message.
    --- @param message string
    local function Info(message)
        return FactoryLogger.Info(modName, message)
    end

    --- Logs a warning message.
    --- @param message string
    local function Warn(message)
        return FactoryLogger.Warn(modName, message)
    end

    --- Logs an error message.
    --- @param message string
    local function Error(message)
        return FactoryLogger.Error(modName, message)
    end

    instance.Log = Log
    instance.Info = Info
    instance.Warn = Warn
    instance.Error = Error

    cache[modName] = instance
    return instance
end

---@type KCDUtilsLogger
KCDUtils.Logger = FactoryLogger