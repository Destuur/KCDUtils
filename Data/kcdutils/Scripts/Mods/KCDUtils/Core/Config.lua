KCDUtils = KCDUtils or {}
--- @class KCDUtilsConfig
KCDUtils.Config = KCDUtils.Config or {}

--- Loads configuration values from the database for the given mod.
--- If a value exists in the database, it overwrites the value in configTable.
--- If not, the default value from configTable is saved to the database.
--- @param modName string The name of the mod.
--- @param configTable table The table containing default config values.
function KCDUtils.Config.LoadFromDB(modName, configTable)
    local db = KCDUtils.DB.Factory(modName)
    for key, cfg in pairs(configTable) do
        if type(cfg) == "table" and cfg.value ~= nil then
            local val = db:Get(key)
            if val ~= nil then
                cfg.value = val   -- nur den Wert aktualisieren, Referenz bleibt
            else
                db:Set(key, cfg.value)
            end
        end
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