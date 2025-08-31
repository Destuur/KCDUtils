---@class KCDUtilsString
KCDUtils.String = KCDUtils.String or {}

--- Returns the mod name associated with a given DB instance.
---@param db table The database instance
---@return string|nil The mod name or nil if not found
function KCDUtils.String.GetModNameFromDB(db)
    if db == nil then
        return nil
    end
    local dbInstance = tostring(db)
    local modname = string.match(dbInstance, "^DB Instance: (.+)$")
    if modname then
        return modname
    else
        return nil
    end
end