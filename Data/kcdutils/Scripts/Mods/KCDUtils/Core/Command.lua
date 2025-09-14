KCDUtils = KCDUtils or {}
---@class KCDUtilsCommand
KCDUtils.Command = KCDUtils.Command or {}

--- Adds a console command for the specified mod.
---
--- Unlike AddFunction(), this version expects the callback as a global function name (string).
---
--- ### Example:
---
--- ```lua
--- -- Define a global callback function
--- function MyMod_Hello()
---     System.LogAlways("Hello from MyMod!")
--- end
---
--- -- Register the command
--- KCDUtils.Command.Add("MyMod", "hello", "MyMod_Hello", "Prints a hello message")
--- ```
---
--- ### Usage:
---
--- Console command `MyMod.hello` writes "Hello from MyMod!" to the log.
---
--- @param modName string Unique mod identifier
--- @param command string Command name
--- @param callbackName string Callback function to execute as string
--- @param description string Command description
function KCDUtils.Command.Add(modName, command, callbackName, description)
    local logger = KCDUtils.Logger.Factory(modName)
    if type(command) ~= "string" then
        logger:Error("Command must be a string")
    end
    System.AddCCommand(tostring(modName .. "_" .. command), callbackName, description or "No description provided")
end

--- Adds a console command for the specified mod with an inline function callback
--- Unlike Add(), this does not require a global function name. Instead, you can
--- directly pass a Lua function, which will be wrapped and registered internally.
--- 
--- ### Example:
--- 
--- ```lua
--- KCDUtils.Command.AddFunction("MyMod", "ping", function()
---    System.LogAlways("Pong!")
--- end, "Ping test")
--- ```
---
--- ### Usage:
---
--- Console command `MyMod_ping` writes "Pong!" to the log.
---
--- @param modName string Unique mod identifier
--- @param command string Command name
--- @param func function Function to execute when the command is called
--- @param description string Command description
function KCDUtils.Command.AddFunction(modName, command, func, description)
    local wrapperName = modName .. "_" .. command .. "_wrapper"

    _G[wrapperName] = function(...)
        func(...)
    end

    System.AddCCommand(modName .. "_" .. command, wrapperName .. "(%line)", description or "")
end

--- Executes a console command directly
--- This allows running any console command from Lua code.
--- @param command string The full console command to execute
function KCDUtils.Command.ExecuteCommand(command)
    System.ExecuteCommand(command)
end