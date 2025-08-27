KCDUtils.Safe = KCDUtils.Safe or {}

--- Safely calls a method on a target object.
--- Wraps the call in pcall and logs errors without crashing.
--- Supports multiple return values.
---
--- Usage:
--- ```lua
---   local ok, result1, result2 = target:SafeCall("MethodName", arg1, arg2)
--- ```
---
---@param target table Object that contains the method
---@param methodName string Name of the method to call
---@param ... any Arguments to pass to the method
---@return boolean ok Whether the call succeeded
---@return any ... Return values of the method
function KCDUtils.Safe.Call(target, methodName, ...)
    if not target or type(target[methodName]) ~= "function" then
        local logger = KCDUtils.Logger.Factory(target.Name or "Unknown")
        logger:Error("Target does not have a method named '" .. tostring(methodName) .. "'")
        return false
    end

    local results = { pcall(target[methodName], target, ...) }
    local ok = table.remove(results, 1)

    if not ok then
        local logger = KCDUtils.Logger.Factory(target.Name or "Unknown")
        logger:Error("Error calling method '" .. tostring(methodName) .. "': " .. tostring(results[1]))
    end

    return ok, table.unpack(results)
end