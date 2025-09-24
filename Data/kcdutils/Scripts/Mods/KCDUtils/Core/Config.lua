KCDUtils = KCDUtils or {}
--- @class KCDUtilsConfig
KCDUtils.Config = KCDUtils.Config or {}

--- Loads configuration values from the database for the given mod.
--- If a value exists in the database, it overwrites the value in configTable.
--- @param modName string The name of the mod.
--- @param configTable table The table containing default config values.
function KCDUtils.Config.LoadFromDB(modName, configTable)
    local db = KCDUtils.DB.Factory(modName)

    for key, defaultVal in pairs(configTable) do
        local val = db:Get(key)
        System.LogAlways("key and value: " .. key .. " = " .. tostring(val))
        configTable[key] = val ~= nil and val or defaultVal
    end
end


--- Saves all configuration values from configTable to the database for the given mod.
--- @param modName string The name of the mod.
--- @param configTable table The table containing config values to save.
function KCDUtils.Config.SaveAll(modName, configTable)
    local db = KCDUtils.DB.Factory(modName)
    for k, v in pairs(configTable) do
        db:Set(k, v)
    end
end

--- Dumps all configuration values for the given mod to the log.
--- @param modName string The name of the mod.
function KCDUtils.Config.Dump(modName)
    KCDUtils.DB.Factory(modName):Dump()
end