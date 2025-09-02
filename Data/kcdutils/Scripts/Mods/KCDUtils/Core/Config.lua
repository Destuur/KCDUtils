KCDUtils = KCDUtils or {}
--- @class KCDUtilsCoreConfig
KCDUtils.Config = KCDUtils.Config or {}

function KCDUtils.Config.LoadFromDB(modName, configTable)
    local db = KCDUtils.DB.Factory(modName)
    for key, value in pairs(configTable) do
        local val = db:Get(key)
        if val ~= nil then
            configTable[key] = val
        else
            db:Set(key, value)
        end
    end
end

function KCDUtils.Config.SaveAll(modName, configTable)
    local db = KCDUtils.DB.Factory(modName)
    for k, v in pairs(configTable) do
        db:Set(k, v)
    end
end

function KCDUtils.Config.Dump(modName)
    KCDUtils.DB.Factory(modName):Dump()
end