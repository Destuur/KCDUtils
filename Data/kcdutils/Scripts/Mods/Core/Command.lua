KCDUtils = KCDUtils or {}
KCDUtils.Core = KCDUtils.Core or {}

---@class KCDUtilsCoreCommand
KCDUtils.Core.Command = KCDUtils.Core.Command or {}

--- Adds a console command for the specified mod
--- @param modName string Unique mod identifier
--- @param command string Command name
--- @param callbackName string Callback function to execute as string
--- @param description string Command description
function KCDUtils.Core.Command.Add(modName, command, callbackName, description)
    local logger = KCDUtils.Core.Logger.Factory(modName)
    if type(command) ~= "string" then
        logger:Error("Command must be a string")
    end
    System.AddCCommand(tostring(modName .. "." .. command), callbackName, description or "No description provided")
end

function KCDUtils.Core.Command.AddFunction(modName, command, func, description)
    local wrapperName = modName .. "_" .. command .. "_wrapper"

    _G[wrapperName] = function(...)
        func(...)
    end

    System.AddCCommand(modName .. "." .. command, wrapperName .. "(%line)", description or "")
end