KCDUtils.Safe = KCDUtils.Safe or {}

--- Safe method call wrapper
--- @param obj table The object containing the method
--- @param methodName string The name of the method
--- @param useSelf boolean Whether to use the object as the self context
--- @param ... any Optional arguments for the method
--- @return any|nil result The method result or nil if unavailable
function KCDUtils.Safe.Call(obj, methodName, useSelf, ...)
    local logger = KCDUtils.Logger.Factory("SafeCall")
    if not obj then return nil end
    local method = obj[methodName]
    if type(method) ~= "function" then return nil end

    local ok, result
    if useSelf then
        ok, result = pcall(method, obj, ...)
    else
        ok, result = pcall(method, ...)
    end

    if ok then
        return result
    else
        logger:Error("Error calling " .. methodName .. ": " .. result)
        return nil
    end
end
