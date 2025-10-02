KCDUtils = KCDUtils or {}
--- @class KCDUtilsConfig
KCDUtils.Config = KCDUtils.Config or {}

-- JSON-ähnliche Serializer
local function encode(val)
    local t = type(val)
    if t == "table" then
        local parts = {}
        table.insert(parts, "{")
        local first = true
        for k, v in pairs(val) do
            if not first then
                table.insert(parts, ",")
            end
            first = false
            table.insert(parts, '"' .. tostring(k) .. '":' .. encode(v))
        end
        table.insert(parts, "}")
        return table.concat(parts)
    elseif t == "string" then
        return '"' .. val .. '"'
    elseif t == "boolean" then
        return val and "true" or "false"
    else
        return tostring(val)
    end
end

local function decode(str)
    local function parseObject(s)
        local result = {}
        s = s:gsub("^%s*{", ""):gsub("}%s*$", "")
        for pair in s:gmatch('("[^"]+":[^,}]+)') do
            local k, v = pair:match('"(.-)":(.+)')
            if k and v then
                v = v:match("^%s*(.-)%s*$")
                if v == "true" then
                    result[k] = true
                elseif v == "false" then
                    result[k] = false
                elseif v:sub(1,1) == "{" then
                    result[k] = parseObject(v)
                elseif v:sub(1,1) == '"' then
                    result[k] = v:sub(2, -2)
                else
                    result[k] = tonumber(v) or v
                end
            end
        end
        return result
    end
    if str and str:sub(1,1) == "{" then
        return parseObject(str)
    end
    return str
end

--- Loads configuration values from the database for the given mod.
--- If a value exists in the database, it overwrites the value in configTable.
function KCDUtils.Config.LoadFromDB(modName, configTable)
    local db = KCDUtils.DB.Factory(modName)
    for key, defaultVal in pairs(configTable) do
        local val = db:Get(key)
        if val ~= nil then
            if type(defaultVal) == "table" then
                configTable[key] = decode(val)
            elseif val == "true" or val == "false" then
                configTable[key] = (val == "true")
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
        if type(v) == "table" then
            db:Set(k, encode(v))
        elseif type(v) == "boolean" then
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