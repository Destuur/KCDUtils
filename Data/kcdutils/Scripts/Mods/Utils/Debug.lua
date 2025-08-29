---@class KCDUtils.Debug
local Debug = {}

function Debug.TestMethod(obj, name, ...)
    local logger = KCDUtils.Logger.Factory("Debug")
    local method = obj[name]
    if type(method) ~= "function" then
        logger:Error(name .. " is not a function")
        return
    end
    local ok, result = pcall(method, obj, ...)
    if ok then
        logger:Info(name .. " => " .. tostring(result))
    else
        logger:Error(name .. " failed: " .. tostring(result))
    end
end

KCDUtils.Debug = Debug
