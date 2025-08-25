---@class KCDUtilsDB
local FactoryDB = KCDUtils and KCDUtils.DB or {}

local cache = {}

---Factory for creating/retrieving a DB instance for a given mod.
---@param modName string Unique mod identifier
function FactoryDB.Factory(modName)
    if cache[modName] then
        return cache[modName]
    end

    local db = _G.DB.Create(modName) ---@diagnostic disable-line: undefined-field
    local logger = KCDUtils.Logger.Factory(modName)

    local instance = {
        Name = modName,
        DB = db
    }

    --- Retrieves a value by key.
    --- @param key string
    --- @param log? boolean
    function instance:Get(key, log)
        local value = self.DB:Get(key)
        if log then
            logger:Info("Key: " .. key .. ", Value: " .. tostring(value))
        end
        return value
    end

    --- Sets a value by key.
    --- @param key string
    --- @param value any
    --- @param log? boolean
    function instance:Set(key, value, log)
        self.DB:Set(key, value)
        if log then
            logger:Info("Set Key: " .. key .. ", Value: " .. tostring(value))
        end
    end

    --- Deletes a value by key.
    --- @param key string
    --- @param log? boolean
    function instance:Del(key, log)
        self.DB:Del(key)
        if log then
            logger:Info("Deleted Key: " .. key)
        end
    end

    --- Checks if a key exists.
    --- @param key string
    --- @param log? boolean
    function instance:Exi(key, log)
        local exists = self.DB:Exi(key)
        if log then
            logger:Info("Exists Key: " .. key .. " -> " .. tostring(exists))
        end
        return exists
    end

    --- Returns all key-value pairs.
    --- @param log? boolean
    function instance:All(log)
        local all = self.DB:All()
        if log then
            logger:Info("All Keys: " .. tostring(all))
        end
        return all
    end

    ----------------------------------------------------------------------
    -- Global versions
    ----------------------------------------------------------------------
    function instance:GetG(key, log)
        local value = self.DB:GetG(key)
        if log then
            logger:Info("Global Key: " .. key .. ", Value: " .. tostring(value))
        end
        return value
    end

    function instance:SetG(key, value, log)
        self.DB:SetG(key, value)
        if log then
            logger:Info("Set Global Key: " .. key .. ", Value: " .. tostring(value))
        end
    end

    function instance:DelG(key, log)
        self.DB:DelG(key)
        if log then
            logger:Info("Deleted Global Key: " .. key)
        end
    end

    function instance:ExiG(key, log)
        local exists = self.DB:ExiG(key)
        if log then
            logger:Info("Exists Global Key: " .. key .. " -> " .. tostring(exists))
        end
        return exists
    end

    function instance:AllG(log)
        local all = self.DB:AllG()
        if log then
            logger:Info("All Global Keys: " .. tostring(all))
        end
        return all
    end

    --- Dumps the entire DB
    function instance:Dump()
        self.DB:Dump()
    end

    cache[modName] = instance
    return instance
end

---@type KCDUtilsDB
KCDUtils.DB = FactoryDB