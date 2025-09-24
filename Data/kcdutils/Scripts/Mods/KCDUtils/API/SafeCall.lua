---@type KCDUtils
KCDUtils = KCDUtils or {}

--- Safe method call wrapper for Lua 5.1
--- @param obj table The object containing the method
--- @param methodName string The name of the method
--- @param useSelf boolean Whether to use the object as the self context
--- @param ... any Optional arguments for the method
--- @return any|nil result The method result or nil if unavailable
function KCDUtils.SafeCall(obj, methodName, useSelf, ...)
    local logger = KCDUtils.Logger.Factory("SafeCall")

    -- Prüfen, ob das Objekt existiert
    if not obj then
        logger:Error("SafeCall failed: object is nil")
        return nil
    end

    -- Prüfen, ob die Methode existiert
    local method = obj[methodName]
    if type(method) ~= "function" then
        logger:Error("SafeCall failed: method '" .. tostring(methodName) .. "' not found on object")
        return nil
    end

    -- Safe call
    local ok, result
    if useSelf then
        ok, result = pcall(method, obj, ...)
    else
        ok, result = pcall(method, ...)
    end

    if ok then
        return result
    else
        logger:Error("SafeCall error calling '" .. tostring(methodName) .. "': " .. tostring(result))
        return nil
    end
end
