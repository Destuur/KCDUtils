KCDUtils = KCDUtils or {}
--- @class KCDUtilsConfig
KCDUtils.Config = KCDUtils.Config or {}

--- Loads configuration values from the database for the given mod.
--- If a value exists in the database, it overwrites the value in configTable.
function KCDUtils.Config.LoadFromDB(modName, configTable)
    local db = KCDUtils.DB.Factory(modName)
    for key, defaultVal in pairs(configTable) do
        local val = db:Get(key)
        if val ~= nil then
            if val == "true" then
                configTable[key] = true
            elseif val == "false" then
                configTable[key] = false
            else
                configTable[key] = tonumber(val) or val
            end
        else
            configTable[key] = defaultVal
        end
    end
end

--- Saves all configuration values from configTable to the database for the given mod.
function KCDUtils.Config.SaveAll(modName, configTable)
    local db = KCDUtils.DB.Factory(modName)
    for k, v in pairs(configTable) do
        if type(v) == "boolean" then
            db:Set(k, v and "true" or "false")
        else
            db:Set(k, tostring(v))
        end
    end
end

--- Dumps all configuration values for the given mod to the log.
function KCDUtils.Config.Dump(modName)
    KCDUtils.DB.Factory(modName):Dump()
end