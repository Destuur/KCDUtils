KCDUtils = KCDUtils or {}
KCDUtils.Core = KCDUtils.Core or {}

---@class KCDUtilsCoreUIAction
KCDUtils.Core.UIAction = KCDUtils.Core.UIAction or {}

--- Calls a function on a UIAction element.
---@param elementName string
---@param functionName string
---@param ... any
---@return any
function KCDUtils.Core.UIAction.CallFunction(elementName, functionName, ...)
    System.LogAlways("UIAction.CallFunction: elementName=" .. tostring(elementName) .. ", functionName=" .. tostring(functionName))
    if elementName == nil then
        System.LogAlways("UIAction.CallFunction: No elementName provided!")
        return nil
    end
    if functionName == nil then
        System.LogAlways("UIAction.CallFunction: No functionName provided!")
        return nil
    end

    if not Action then ---@diagnostic disable-line
        System.LogAlways("UIAction.CallFunction: Action global is not available!")
        return nil
    end

    return UIAction.CallFunction(elementName, -1, functionName, ...)
end

-- _G.UIAction.CallFunction => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.GetRotation => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.UnloadElement => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.RegisterElementListener => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.UnregisterActionListener => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.SetVariable => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.EnableAction => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.SetRotation => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.GetPos => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.SetArray => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.ShowElement => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.GotoAndPlayFrameName => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.RequestHide => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.GetScale => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.RegisterActionListener => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.ReloadElement => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.GetArray => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.EndAction => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.UnregisterEventSystemListener => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.SetScale => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.HideElement => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.GotoAndStopFrameName => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.GetAlpha => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.UnregisterElementListener => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.SetVisible => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.SetAlpha => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.GotoAndPlay => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.DisableAction => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.RegisterEventSystemListener => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.StartAction => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.IsVisible => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.SetPos => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.GetVariable => function (Lua function) params: 0 | vararg: nil
-- _G.UIAction.GotoAndStop => function (Lua function) params: 0 | vararg: nil