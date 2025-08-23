---@class KCDUtilsDB
local DB = KCDUtils and KCDUtils.DB or {}

local s = KCDUtils.String

--- Retrieves a value from the database by key. Optionally logs the operation.
--- @param db table The database instance
--- @param key string The key to retrieve
--- @param log? boolean (optional) If true, logs the operation. Default is false
--- @return any value The value for the given key
function DB.Get(db, key, log)
    if log == nil then log = false end
    local value = db.Get(key)
    if log then
        System.LogAlways("[".. s.GetModNameFromDB(db) .. "] Key: " .. key .. ", Value: " .. tostring(value))
    end
    return value
end

--- Sets a value in the database for a given key. Optionally logs the operation.
--- @param db table The database instance
--- @param key string The key to set
--- @param value any The value to set
--- @param log? boolean|nil (optional) If true, logs the operation. Default is false
function DB.Set(db, key, value, log)
    if log == nil then log = false end
    db.Set(key, value)
    if log then
        System.LogAlways("[".. s.GetModNameFromDB(db) .. "] Set Key: " .. key .. ", Value: " .. tostring(value))
    end
end

--- Deletes a key from the database. Optionally logs the operation.
--- @param db table The database instance
--- @param key string The key to delete
--- @param log? boolean|nil (optional) If true, logs the operation. Default is false
function DB.Del(db, key, log)
    if log == nil then log = false end
    db.Del(key)
    if log then
        System.LogAlways("[".. s.GetModNameFromDB(db) .. "] Deleted Key: " .. key)
    end
end

--- Checks if a key exists in the database. Optionally logs the operation.
--- @param db table The database instance
--- @param key string The key to check
--- @param log? boolean|nil (optional) If true, logs the operation. Default is false
--- @return boolean exists True if the key exists
function DB.Exi(db, key, log)
    if log == nil then log = false end
    local exists = db.Exi(key)
    if log then
        System.LogAlways("[".. s.GetModNameFromDB(db) .. "] Exists Key: " .. key .. ", Exists: " .. tostring(exists))
    end
    return exists
end


--- Returns all keys/values from the database. Optionally logs the operation.
--- @param db table The database instance
--- @param log? boolean|nil (optional) If true, logs the operation. Default is false
--- @return table all All key-value pairs in the database
function DB.All(db, log)
    if log == nil then log = false end
    local all = db.All()
    if log then
        System.LogAlways("[".. s.GetModNameFromDB(db) .. "] All Keys: " .. tostring(all))
    end
    return all
end

--- Retrieves a global value from the database by key. Optionally logs the operation.
--- @param db table The database instance
--- @param key string The key to retrieve
--- @param log? boolean|nil (optional) If true, logs the operation. Default is false
--- @return any value The value for the given global key
function DB.GetG(db, key, log)
    if log == nil then log = false end
    local value = db.GetG(key)
    if log then
        System.LogAlways("[".. s.GetModNameFromDB(db) .. "] Global Key: " .. key .. ", Value: " .. tostring(value))
    end
    return value
end

--- Sets a global value in the database for a given key. Optionally logs the operation.
--- @param db table The database instance
--- @param key string The key to set
--- @param value any The value to set
--- @param log? boolean|nil (optional) If true, logs the operation. Default is false
function DB.SetG(db, key, value, log)
    if log == nil then log = false end
    db.SetG(key, value)
    if log then
        System.LogAlways("[".. s.GetModNameFromDB(db) .. "] Set Global Key: " .. key .. ", Value: " .. tostring(value))
    end
end

--- Deletes a global key from the database. Optionally logs the operation.
--- @param db table The database instance
--- @param key string The key to delete
--- @param log? boolean|nil (optional) If true, logs the operation. Default is false
function DB.DelG(db, key, log)
    if log == nil then log = false end
    db.DelG(key)
    if log then
        System.LogAlways("[".. s.GetModNameFromDB(db) .. "] Deleted Global Key: " .. key)
    end
end

--- Checks if a global key exists in the database. Optionally logs the operation.
--- @param db table The database instance
--- @param key string The key to check
--- @param log? boolean|nil (optional) If true, logs the operation. Default is false
--- @return boolean exists True if the global key exists
function DB.ExiG(db, key, log)
    if log == nil then log = false end
    local exists = db.ExiG(key)
    if log then
        System.LogAlways("[".. s.GetModNameFromDB(db) .. "] Exists Global Key: " .. key .. ", Exists: " .. tostring(exists))
    end
    return exists
end

--- Returns all global keys/values from the database. Optionally logs the operation.
--- @param db table The database instance
--- @param log? boolean|nil (optional) If true, logs the operation. Default is false
--- @return table all All global key-value pairs in the database
function DB.AllG(db, log)
    if log == nil then log = false end
    local all = db.AllG()
    if log then
        System.LogAlways("[".. s.GetModNameFromDB(db) .. "] All Global Keys: " .. tostring(all))
    end
    return all
end


--- Dumps the entire database to the log.
--- @param db table The database instance
function DB.Dump(db)
    db.Dump()
end

---@type KCDUtilsDB
KCDUtils.DB = DB