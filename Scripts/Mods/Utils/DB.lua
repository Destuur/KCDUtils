---@class KCDUtilsDB
local FactoryDB = KCDUtils and KCDUtils.DB or {}

local cache = {}

function FactoryDB.Get(db, name, key, log)
    if log == nil then log = false end
    local value = db.Get(key)
    if log then
        System.LogAlways("[".. name .. "] Key: " .. key .. ", Value: " .. tostring(value))
    end
    return value
end

function FactoryDB.Set(db, name, key, value, log)
    if log == nil then log = false end
    db.Set(key, value)
    if log then
        System.LogAlways("[".. name .. "] Set Key: " .. key .. ", Value: " .. tostring(value))
    end
end

function FactoryDB.Del(db, name, key, log)
    if log == nil then log = false end
    db.Del(key)
    if log then
        System.LogAlways("[".. name .. "] Deleted Key: " .. key)
    end
end

function FactoryDB.Exi(db, name, key, log)
    if log == nil then log = false end
    local exists = db.Exi(key)
    if log then
        System.LogAlways("[".. name .. "] Exists Key: " .. key .. ", Exists: " .. tostring(exists))
    end
    return exists
end

function FactoryDB.All(db, name, log)
    if log == nil then log = false end
    local all = db.All()
    if log then
        System.LogAlways("[".. name .. "] All Keys: " .. tostring(all))
    end
    return all
end

function FactoryDB.GetG(db, name, key, log)
    if log == nil then log = false end
    local value = db.GetG(key)
    if log then
        System.LogAlways("[".. name .. "] Global Key: " .. key .. ", Value: " .. tostring(value))
    end
    return value
end

function FactoryDB.SetG(db, name, key, value, log)
    if log == nil then log = false end
    db.SetG(key, value)
    if log then
        System.LogAlways("[".. name .. "] Set Global Key: " .. key .. ", Value: " .. tostring(value))
    end
end

function FactoryDB.DelG(db, name, key, log)
    if log == nil then log = false end
    db.DelG(key)
    if log then
        System.LogAlways("[".. name .. "] Deleted Global Key: " .. key)
    end
end

function FactoryDB.ExiG(db, name, key, log)
    if log == nil then log = false end
    local exists = db.ExiG(key)
    if log then
        System.LogAlways("[".. name .. "] Exists Global Key: " .. key .. ", Exists: " .. tostring(exists))
    end
    return exists
end

function FactoryDB.AllG(db, name, log)
    if log == nil then log = false end
    local all = db.AllG()
    if log then
        System.LogAlways("[".. name .. "] All Global Keys: " .. tostring(all))
    end
    return all
end

function FactoryDB.Dump(db)
    db.Dump()
end

--------------------------------------------------------------------------
-- Factory (Singleton pro Mod)
--------------------------------------------------------------------------
function FactoryDB.Factory(modname)
    if cache[modname] then
        return cache[modname]
    end
    
    local db = _G.DB.Create(modname) ---@diagnostic disable-line: undefined-field

    local instance = {
        DB = db,
        Name = modname
    }

    --- Retrieves a value from the database by key. Optionally logs the operation.
    --- @param key string The key to retrieve
    --- @param log? boolean (optional) If true, logs the operation. Default is false
    --- @return any value The value for the given key
    instance.Get = function(key, log) return FactoryDB.Get(instance.DB, instance.Name, key, log) end
    
    --- Sets a value in the database for a given key.
    ---
    --- Accepted value types:
    ---   - string
    ---   - number
    ---   - boolean
    ---   - table
    ---
    --- @param key string The key to set
    --- @param value any The value to set
    --- @param log? boolean|nil (optional) If true, logs the operation. Default is false
        instance.Set = function(key, value, log) return FactoryDB.Set(instance.DB, instance.Name, key, value, log) end

    --- Deletes a key from the database. Optionally logs the operation.
    --- @param key string The key to delete
    --- @param log? boolean|nil (optional) If true, logs the operation. Default is false
    instance.Del = function(key, log) return FactoryDB.Del(instance.DB, instance.Name, key, log) end

    --- Checks if a key exists in the database. Optionally logs the operation.
    --- @param key string The key to check
    --- @param log? boolean|nil (optional) If true, logs the operation. Default is false
    --- @return boolean exists True if the key exists
    instance.Exi = function(key, log) return FactoryDB.Exi(instance.DB, instance.Name, key, log) end

    --- Returns all keys/values from the database. Optionally logs the operation.
    --- @param log? boolean|nil (optional) If true, logs the operation. Default is false
    --- @return table all All key-value pairs in the database
    instance.All = function(log) return FactoryDB.All(instance.DB, instance.Name, log) end

    --- Retrieves a global value from the database by key. Optionally logs the operation.
    --- @param key string The key to retrieve
    --- @param log? boolean|nil (optional) If true, logs the operation. Default is false
    --- @return any value The value for the given global key
    instance.GetG = function(key, log) return FactoryDB.GetG(instance.DB, instance.Name, key, log) end

    --- Sets a global value in the database for a given key. Optionally logs the operation.
    --- @param key string The key to set
    --- @param value any The value to set
    --- @param log? boolean|nil (optional) If true, logs the operation. Default is false
    instance.SetG = function(key, value, log) return FactoryDB.SetG(instance.DB, instance.Name, key, value, log) end

    --- Deletes a global key from the database. Optionally logs the operation.
    --- @param key string The key to delete
    --- @param log? boolean|nil (optional) If true, logs the operation. Default is false
    instance.DelG = function(key, log) return FactoryDB.DelG(instance.DB, instance.Name, key, log) end

    --- Checks if a global key exists in the database. Optionally logs the operation.
    --- @param key string The key to check
    --- @param log? boolean|nil (optional) If true, logs the operation. Default is false
    --- @return boolean exists True if the global key exists
    instance.ExiG = function(key, log) return FactoryDB.ExiG(instance.DB, instance.Name, key, log) end

    --- Returns all global keys/values from the database. Optionally logs the operation.
    --- @param log? boolean|nil (optional) If true, logs the operation. Default is false
    --- @return table all All global key-value pairs in the database
    instance.AllG = function(log) return FactoryDB.AllG(instance.DB, instance.Name, log) end

    --- Dumps the entire database to the log.
    instance.Dump = function() FactoryDB.Dump(instance.DB) end

    cache[modname] = instance
    return instance
end

---@type KCDUtilsDB
KCDUtils.DB = FactoryDB