---@class KCDUtilsDebug
KCDUtils.Debug = KCDUtils.Debug or {}

function KCDUtils.Debug.TestMethod(obj, name, ...)
    local logger = KCDUtils.Core.Logger.Factory("Debug")
    local method = obj[name]
    if type(method) ~= "function" then
        logger:Error(name .. " is not a function")
        return
    end
    local ok, result = pcall(method, obj, ...)
    if ok then
        logger:Info(name .. " => " .. tostring(result))
    else
        logger:Error(name .. " failed: " .. tostring(result))
    end
end

local function logValue(value, indent, visited)
    local logger = KCDUtils.Core.Logger.Factory("Debug")
    indent = indent or ""
    visited = visited or {}

    if type(value) == "table" then
        if visited[value] then
            logger:Info(indent .. "{ <already visited> }")
            return
        end
        visited[value] = true

        logger:Info(indent .. "{")
        for k, v in pairs(value) do
            logger:Info(indent .. "  [" .. tostring(k) .. "] = ")
            logValue(v, indent .. "  ", visited)
        end
        logger:Info(indent .. "}")
    else
        logger:Info(indent .. tostring(value))
    end
end

-- Wrapper für SetSearchBeam
function KCDUtils.Debug.DebugSetSearchBeam(actor, dir)
    local logger = KCDUtils.Core.Logger.Factory("Debug")
    if not actor or not actor.SetSearchBeam then
        logger:Error("DebugSetSearchBeam: invalid actor or function not available")
        return
    end

    -- call original function
    local results = { actor:SetSearchBeam(dir) }

    -- log all results
    logger:Info("SetSearchBeam returned " .. tostring(#results) .. " values:")
    for i, v in ipairs(results) do
        logger:Info("[" .. i .. "] = ")
        logValue(v, "  ")
    end

    return table.unpack(results) -- gibt die originalen Werte weiter zurück
end