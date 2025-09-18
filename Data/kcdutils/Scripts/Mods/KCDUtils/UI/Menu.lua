KCDUtils.UI = KCDUtils.UI or {}
local buttonX = 1500
local startY = 380
local maxButtons = 7
local buttonWidth = 196

local function getModsForMenu()
    local mods = {}
    for _, mod in pairs(KCDUtils.RegisteredMods) do
        if mod.Config then
            if not mod.ConfigInstance then
                local ok, instance = pcall(KCDUtils.UI.ConfigBuilder, mod.Config)
                if ok then
                    mod.ConfigInstance = instance
                    if mod.DB then
                        KCDUtils.Config.LoadFromDB(mod.Name, mod.ConfigInstance)
                    end
                else
                    System.LogAlways("[KCDUtils] Failed to build config for mod " .. tostring(mod.Name) .. ": " .. tostring(instance))
                end
            end

            if mod.ConfigInstance then
                table.insert(mods, {
                    name = mod.Name,
                    description = mod.Description or "",
                    config = mod.ConfigInstance,
                    db = mod.DB
                })
            end
        end
    end
    return mods
end


local function GetConfigEntries(config)
    local entries = {}
    for k, v in pairs(config) do
        if type(v) == "table" and v.id then
            table.insert(entries, v)
        end
    end
    return entries
end

function KCDUtils.UI.ConfigBuilder(defs)
    local cfg = {}
    local list = {}

    for key, def in pairs(defs) do
        if type(def) == "table" then  -- ✅ nur Tabellen verarbeiten
            local entry = {
                id = key,
                type = def.type or "value",
                tooltip = def.tooltip,
                min = def.min,
                max = def.max,
                choices = def.choices,
                valueMap = def.valueMap,
                hidden = def.hidden or false,
                value = def[1] ~= nil and def[1] or def.value
            }
            cfg[key] = entry
            table.insert(list, entry)
        else
            System.LogAlways(("[ConfigBuilder] Skipping invalid def for key '%s'"):format(key))
        end
    end

    cfg._list = list

    return setmetatable(cfg, {
        __index = function(t, k)
            local entry = rawget(t, k)
            if entry and type(entry) == "table" and entry.value ~= nil then
                return entry.value
            end
            return rawget(t, k)
        end,
        __newindex = function(t, k, v)
            local entry = rawget(t, k)
            if entry and type(entry) == "table" and entry.value ~= nil then
                entry.value = v
            else
                rawset(t, k, v)
            end
        end
    })
end


function KCDUtils.UI:ShowConfirmation(id, question, yesText, noText, callbackYes, callbackNo)
    self._confirmation = { id = id, yes = callbackYes, no = callbackNo }
    UIAction.CallFunction("Menu", -1, "AddConfirmation", id, question, yesText, noText, 0, 1)
end

function KCDUtils.UI:HandleConfirmation(id, answer)
    if not self._confirmation or self._confirmation.id ~= id then return end
    if answer == 1 and self._confirmation.yes then self._confirmation.yes() end
    if answer == 0 and self._confirmation.no then self._confirmation.no() end
    UIAction.CallFunction("Menu", -1, "RemoveConfirmation", id)
    self._confirmation = nil
end

-- Mod-Übersicht öffnen
function KCDUtils.UI:OpenModSettings()
    local mods = getModsForMenu()
    UIAction.CallFunction("Menu", -1, "ClearAll")
    UIAction.CallFunction("Menu", -1, "PreparePage", buttonX, startY, maxButtons, "Mod Settings", buttonWidth)

    for i, mod in ipairs(mods) do
        local uiText = "@ui_" .. mod.name
        UIAction.CallFunction("Menu", -1, "AddBasicButton", "mod_"..i, 0, uiText, mod.description or "", false)
    end

    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Settings", 1, "@ui_back", "", false)
    UIAction.CallFunction("Menu", -1, "ShowPage")
end

local function GetVanillaChoiceUIText(choice)
    local lookup = { ["Yes"]="@ui_Yes", ["No"]="@ui_No", ["Off"]="@ui_off", ["On"]="@ui_on" }
    return lookup[choice] or choice
end

-- Mod-Config öffnen
function KCDUtils.UI:OpenModConfig(modIndex)
    local mods = getModsForMenu()
    local mod = mods[modIndex]
    if not mod or not mod.config then return end

    KCDUtils.UI._currentModIndex = modIndex

    UIAction.CallFunction("Menu", -1, "ClearAll")
    UIAction.CallFunction("Menu", -1, "PreparePage", buttonX, startY, maxButtons + 2, "@ui_" .. mod.name .. "_settings", buttonWidth)

    for _, cfg in ipairs(GetConfigEntries(mod.config)) do
        if not cfg.hidden then

            -- 🔹 ChoiceButton vorbereiten: gespeicherten Wert in Index übersetzen
            if cfg.type == "choice" then
                if cfg.valueMap then
                    for i, v in ipairs(cfg.choices) do
                        if cfg.valueMap[i] == cfg.value then
                            cfg._selectedIndex = i
                            break
                        end
                    end
                else
                    cfg._selectedIndex = cfg.value
                end
            end

            local uiText = "@ui_" .. mod.name .. "_" .. cfg.id

            if cfg.type == "value" then
                UIAction.CallFunction("Menu", -1, "AddValueButton",
                    cfg.id, 0, uiText, cfg.value, cfg.min, cfg.max, cfg.tooltip or "", false
                )
            elseif cfg.type == "choice" then
                UIAction.CallFunction("Menu", -1, "AddChoicesButton",
                    cfg.id, 0, uiText, cfg.tooltip or "", false
                )

                for idx, choice in ipairs(cfg.choices) do
                    local choiceText = GetVanillaChoiceUIText(choice) or "@ui_" .. mod.name .. "_" .. cfg.id .. "_" .. idx
                    UIAction.CallFunction("Menu", -1, "AddChoiceOption",
                        idx, cfg.id, 0, choiceText, "", false
                    )
                end

                -- 🔹 UI auf gespeicherten Index setzen
                UIAction.CallFunction("Menu", -1, "SetChoice", cfg.id, 0, cfg._selectedIndex)
            end
        end
    end


    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Reset", 1, "@ui_reset", "", false)
    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Apply", 1, "@ui_apply", "", false)
    UIAction.CallFunction("Menu", -1, "AddBasicButton", "ModSettings", 1, "@ui_back", "", false)
    UIAction.CallFunction("Menu", -1, "ShowPage")
end

function KCDUtils.UI:OnApplySettings()
    local mods = getModsForMenu()
    local mod = mods[self._currentModIndex]
    if not mod or not mod.config then return end

    for _, cfg in ipairs(GetConfigEntries(mod.config)) do
        if cfg.type == "value" then
            cfg.value = UIAction.CallFunction("Menu", -1, "GetValue", cfg.id, 0)
        elseif cfg.type == "choice" then
            local choiceId = UIAction.CallFunction("Menu", -1, "GetChoice", cfg.id, 0)
            cfg.value = cfg.valueMap and cfg.valueMap[choiceId] or choiceId
            cfg._selectedIndex = choiceId
        end
    end

    KCDUtils.Config.SaveAll(mod.name, mod.config)
    System.LogAlways("[KCDUtils][OnApplySettings] All config values saved for mod " .. mod.name)
end

function KCDUtils.UI.UpdateConfigChoice(id, choiceId)
    local mods = getModsForMenu()
    for _, mod in ipairs(mods) do
        if mod.config then
            for _, cfg in ipairs(GetConfigEntries(mod.config)) do
                if cfg.id == id and cfg.type == "choice" then
                    local oldValue = cfg.value
                    System.LogAlways(("[KCDUtils][UpdateConfigChoice] Before: %s = %s"):format(id, tostring(oldValue)))

                    -- 🔹 UI ist 0-basiert, Lua 1-basiert
                    local luaIndex = choiceId + 1
                    cfg._selectedIndex = luaIndex

                    if cfg.valueMap then
                        cfg.value = cfg.valueMap[luaIndex]
                    else
                        cfg.value = cfg.choices[luaIndex]
                    end

                    System.LogAlways(("[KCDUtils][UpdateConfigChoice] After: %s = %s"):format(id, tostring(cfg.value)))

                    mod.DB:Set(id, cfg.value)
                    System.LogAlways(("[KCDUtils][UpdateConfigChoice] Saved to DB: %s = %s"):format(id, tostring(cfg.value)))
                    return
                end
            end
        end
    end
end


function KCDUtils.UI.UpdateConfigValue(id, value)
    local mods = getModsForMenu()
    for _, mod in ipairs(mods) do
        if mod.config then
            for _, cfg in ipairs(GetConfigEntries(mod.config)) do
                if cfg.id == id and cfg.type == "value" then
                    cfg.value = value
                    mod.db:Set(id, value)
                    return
                end
            end
        end
    end
end

function KCDUtils.UI:OnResetSettings()
    local mods = getModsForMenu()
    local mod = mods[self._currentModIndex]
    if not mod then return end

    for _, cfg in ipairs(GetConfigEntries(mod.config)) do
        if mod.db then
            local stored = mod.db:Get(cfg.id, cfg.value)
            cfg.value = stored

            if cfg.type == "choice" then
                cfg._selectedIndex = stored
                UIAction.CallFunction("Menu", -1, "SetChoice", cfg.id, 0, stored)
            elseif cfg.type == "value" then
                UIAction.CallFunction("Menu", -1, "SetValue", cfg.id, 0, stored)
            end
        end
    end
end

-- Listener
function KCDUtils.UI:OnMenuButtonEvent(elementName, instanceId, eventName, argTable)
    if eventName == "OnButton" then
        local clickedButton = tostring(argTable[0])
        if clickedButton == "ModSettings" then
            self:OpenModSettings()
        elseif clickedButton:match("^mod_%d+$") then
            local modIndex = tonumber(clickedButton:match("%d+"))
            self:OpenModConfig(modIndex)
        elseif clickedButton == "Back" then
            if KCDUtils.UI._currentModIndex then
                KCDUtils.UI._currentModIndex = nil
                self:OpenModSettings()
            else
                UIAction.CallFunction("Menu", -1, "Back")
            end
        elseif clickedButton == "Apply" then
            self:ShowConfirmation("Apply", "@ui_ApplyChanges", "@ui_Yes", "@ui_No", function() self:OnApplySettings() end, function() end)
        elseif clickedButton == "Reset" then
            self:ShowConfirmation("Reset", "@ui_ResetDefault", "@ui_Yes", "@ui_No", function() self:OnResetSettings() end, function() end)
        end
    elseif eventName == "OnInteractiveChoice" then
        local id = tostring(argTable[0])
        local choiceId = tonumber(argTable[1])
        KCDUtils.UI.UpdateConfigChoice(id, choiceId)
    elseif eventName == "OnInteractiveValue" then
        local id = tostring(argTable[0])
        local value = tonumber(argTable[1])
        KCDUtils.UI.UpdateConfigValue(id, value)
    end
end

-- Listener beim Start registrieren
function KCDUtils.UI:RegisterMenuListener()
    if UIAction and UIAction.RegisterElementListener then
        UIAction.RegisterElementListener(self, "Menu", -1, "", "OnMenuButtonEvent")
    end
end

local function InitializeUI()
    if not KCDUtils.UI._initiated then
        KCDUtils.UI._initiated = true
        KCDUtils.UI:RegisterMenuListener()
    end
end

InitializeUI()
