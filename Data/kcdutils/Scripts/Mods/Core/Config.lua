KCDUtils = KCDUtils or {}
KCDUtils.Core = KCDUtils.Core or {}

--- @class KCDUtilsCoreConfig
KCDUtils.Core.Config = KCDUtils.Core.Config or {}

function KCDUtils.Core.Config.LoadFromDB(modName, configTable)
    local db = KCDUtils.Core.DB.Factory(modName)
    for key, value in pairs(configTable) do
        local val = db:Get(key)
        if val ~= nil then
            configTable[key] = val
        else
            db:Set(key, value)
        end
    end
end

function KCDUtils.Core.Config.SaveAll(modName, configTable)
    local db = KCDUtils.Core.DB.Factory(modName)
    for k, v in pairs(configTable) do
        db:Set(k, v)
    end
end

function KCDUtils.Core.Config.Dump(modName)
    KCDUtils.Core.DB.Factory(modName):Dump()
end