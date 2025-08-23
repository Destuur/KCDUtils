---@class KCDUtilsString
local S = KCDUtils and KCDUtils.String or {}

function S.GetModNameFromDB(db)
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

---@type KCDUtilsString
KCDUtils.String = S