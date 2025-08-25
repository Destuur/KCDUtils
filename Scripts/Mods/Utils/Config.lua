---@class KCDUtilsConfig
local FactoryConfig = KCDUtils and KCDUtils.Config or {}

local cache = {}

---Factory for creating/retrieving a config instance for a given mod.
---@param modName string Unique mod identifier
function FactoryConfig.Factory(modName)
    if cache[modName] then
        return cache[modName]
    end

    local instance = {
        Name = modName,
        Values = {}, -- holds the actual config values
        Defaults = {}, -- optional: defaults for fallback
        Loaded = false
    }

    --- Sets default values for the config.
    --- @param defaults table A table of default key-value pairs
    function instance:SetDefaults(defaults)
        for k, v in pairs(defaults or {}) do
            self.Defaults[k] = v
        end
    end

    --- Loads configuration values (e.g. from DB or fallback defaults).
    --- For now: tries DB first, then falls back to defaults.
    function instance:Load()
        local db = KCDUtils.DB.Factory(self.Name)
        for key, default in pairs(self.Defaults) do
            local val = db:Get(key)
            if val == nil then
                self.Values[key] = default
                db:Set(key, default) -- persist default into DB
            else
                self.Values[key] = val
            end
        end
        self.Loaded = true
    end

    --- Retrieves a config value.
    --- @param key string
    --- @param fallback any (optional) fallback if neither value nor default exists
    function instance:Get(key, fallback)
        if self.Values[key] ~= nil then
            return self.Values[key]
        end
        if self.Defaults[key] ~= nil then
            return self.Defaults[key]
        end
        return fallback
    end

    --- Sets a config value (and persists it to DB).
    --- @param key string
    --- @param value any
    function instance:Set(key, value)
        self.Values[key] = value
        local db = KCDUtils.DB.Factory(self.Name)
        db:Set(key, value)
    end

    --- Persists the entire current config state into the DB.
    function instance:SetAll()
        local db = KCDUtils.DB.Factory(self.Name)
        for k, v in pairs(self.Values) do
            db:Set(k, v)
        end
    end

    --- Dumps current config values (for debugging/logging).
    function instance:Dump()
        local db = KCDUtils.DB.Factory(self.Name)
        db:Dump()
    end

    cache[modName] = instance
    return instance
end

---@type KCDUtilsConfig
KCDUtils.Config = FactoryConfig
