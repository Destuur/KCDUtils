-- Sicherstellen, dass UI-Tables existieren
KCDUtils.UI = KCDUtils.UI or {}

local buttonX = 1500
local startY = 380
local maxButtons = 7
local buttonWidth = 196

local function getModsForMenu()
    local mods = {}
    for _, mod in pairs(KCDUtils.RegisteredMods or {}) do
        if mod.Config then
            -- Mod ConfigInstance erstellen, falls noch nicht vorhanden
            if not mod.ConfigInstance then
                local ok, instance = pcall(KCDUtils.UI.MenuBuilder, mod, mod.Config)
                if ok then
                    mod.ConfigInstance = instance
                    if mod.DB then
                        KCDUtils.Config.LoadFromDB(mod.Name, mod.ConfigInstance)
                    end
                else
                    System.LogAlways("[KCDUtils] Failed to build config for mod " .. tostring(mod.Name) .. ": " .. tostring(instance))
                end
            end

            -- Nur Mods mit ConfigInstance hinzufügen
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

local function GetVanillaChoiceUIText(choice)
    local lookup = { ["Yes"]="@ui_Yes", ["No"]="@ui_No", ["Off"]="@ui_off", ["On"]="@ui_on" }
    return lookup[choice] or choice
end

function KCDUtils.UI.MenuBuilder(mod, defs)
    if not mod or not defs then return end
    local cfg = mod.Config or {}
    local menuConfig = {}

    System.LogAlways("[KCDUtils][MenuBuilder] Building menu for mod " .. tostring(mod.Name))

    for key, def in pairs(defs) do
        if def.type == "value" then
            menuConfig[key] = {
                id = key,
                type = "value",
                tooltip = def.tooltip,
                min = def.min or 0,
                max = def.max or 100,
                hidden = def.hidden or false,
                value = cfg[key] or def.default or def[1] or 0,
                defaultValue = def.default or def[1] or 0
            }

        elseif def.type == "choice" and not def.keys then
            menuConfig[key] = {
                id = key,
                type = "choice",
                tooltip = def.tooltip,
                choices = def.choices or {},
                hidden = def.hidden or false,
                valueMap = def.valueMap,
                value = cfg[key] or def.default or def[1] or 1,
                defaultChoiceId = def.defaultChoiceId or 1
            }

        elseif def.type == "choice" and def.keys then
            local entry = {
                id = key,
                type = "choice",
                tooltip = def.tooltip,
                choices = {},
                hidden = def.hidden or false,
                keys = def.keys,
            }

            for _, choice in ipairs(def.choices or {}) do
                table.insert(entry.choices, choice.label or "")
            end

            -- Aktuelle Werte aus cfg sammeln
            local currentVals = {}
            for _, k2 in ipairs(def.keys) do
                table.insert(currentVals, cfg[k2])
            end

            -- Index der gewählten Option finden
            local selectedIndex = def.defaultChoiceId or 1
            for i, choice in ipairs(def.choices or {}) do
                local match = true
                for j, v in ipairs(choice.values or {}) do
                    if v ~= currentVals[j] then
                        match = false
                        break
                    end
                end
                if match then
                    selectedIndex = i
                    break
                end
            end

            entry.value = selectedIndex
            entry.apply = function(choiceId)
                if not (def.choices and def.keys) then return end
                if not choiceId or not def.choices[choiceId] then
                    System.LogAlways("[KCDUtils][MenuBuilder] Invalid choiceId: " .. tostring(choiceId))
                    return
                end
                local vals = def.choices[choiceId].values or {}
                for i, k2 in ipairs(def.keys) do
                    cfg[k2] = vals[i] or cfg[k2]
                end
            end

            menuConfig[key] = entry
        end
    end

    mod.MenuConfig = menuConfig
    mod.ConfigInstance = menuConfig -- <<< entscheidend für getModsForMenu
    return menuConfig
end

function KCDUtils.UI:OpenModSettings()
    System.LogAlways("[KCDUtils][OpenModSettings] Start opening mod settings menu")
    local mods = getModsForMenu()
    if not mods or #mods == 0 then
        System.LogAlways("[KCDUtils][OpenModSettings] No mods found, aborting")
        return
    end

    UIAction.CallFunction("Menu", -1, "ClearAll")
    System.LogAlways("[KCDUtils][OpenModSettings] Menu cleared")

    UIAction.CallFunction("Menu", -1, "PreparePage", buttonX, startY, maxButtons, "Mod Settings", buttonWidth)
    System.LogAlways("[KCDUtils][OpenModSettings] Page prepared")

    for i, mod in ipairs(mods) do
        local uiText = "@ui_" .. (mod.name or "unknown")
        UIAction.CallFunction("Menu", -1, "AddBasicButton", "mod_"..i, 0, uiText, mod.description or "", false)
        System.LogAlways(("[KCDUtils][OpenModSettings] Adding button for mod #%d: %s"):format(i, mod.name or "unknown"))
    end

    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Settings", 1, "@ui_back", "", false)
    UIAction.CallFunction("Menu", -1, "ShowPage")
    System.LogAlways("[KCDUtils][OpenModSettings] Menu displayed")
end

function KCDUtils.UI:OpenModConfig(modIndex)
    local mods = getModsForMenu()
    local mod = mods[modIndex]
    if not mod or not mod.config then return end

    KCDUtils.UI._currentModIndex = modIndex

    UIAction.CallFunction("Menu", -1, "ClearAll")
    UIAction.CallFunction("Menu", -1, "PreparePage", buttonX, startY, maxButtons + 2, "@ui_" .. mod.name .. "_settings", buttonWidth)

    for _, cfg in ipairs(GetConfigEntries(mod.config)) do
        if not cfg.hidden then
            -- ChoiceButton vorbereiten: gespeicherten Wert in Index übersetzen
            if cfg.type == "choice" then
                if cfg.valueMap then
                    for i, v in ipairs(cfg.choices or {}) do
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
                for idx, choice in ipairs(cfg.choices or {}) do
                    local choiceText = GetVanillaChoiceUIText(choice) or "@ui_" .. mod.name .. "_" .. cfg.id .. "_" .. idx
                    UIAction.CallFunction("Menu", -1, "AddChoiceOption",
                        idx, cfg.id, 0, choiceText, "", false
                    )
                end
                -- UI auf gespeicherten Index setzen
                UIAction.CallFunction("Menu", -1, "SetChoice", cfg.id, 0, cfg._selectedIndex)
            end
        end
    end

    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Reset", 1, "@ui_reset", "", false)
    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Apply", 1, "@ui_apply", "", false)
    UIAction.CallFunction("Menu", -1, "AddBasicButton", "ModSettings", 1, "@ui_back", "", false)
    UIAction.CallFunction("Menu", -1, "ShowPage")
end

function KCDUtils.UI.UpdateConfigValue(id, value)
    local mods = getModsForMenu()
    for _, mod in ipairs(mods) do
        if mod.config then
            for _, cfg in ipairs(GetConfigEntries(mod.config)) do
                if cfg.id == id and cfg.type == "value" then
                    cfg.value = value
                    return
                end
            end
        end
    end
end

function KCDUtils.UI.UpdateConfigChoice(id, choiceId)
    local mods = getModsForMenu()
    for _, mod in ipairs(mods) do
        if mod.config then
            for _, cfg in ipairs(GetConfigEntries(mod.config)) do
                if cfg.id == id and cfg.type == "choice" then
                    local luaIndex = choiceId + 1
                    cfg._selectedIndex = luaIndex
                    if cfg.valueMap then
                        cfg.value = cfg.valueMap[luaIndex]
                    else
                        cfg.value = cfg.choices[luaIndex]
                    end
                    return
                end
            end
        end
    end
end

function KCDUtils.UI:OnApplySettings()
    local mods = getModsForMenu()
    local mod = mods[self._currentModIndex]
    if not mod or not mod.MenuConfig then return end

    System.LogAlways("[KCDUtils][OnApplySettings] Applying settings for mod: " .. (mod.Name or "unknown"))

    for _, cfg in ipairs(GetConfigEntries(mod.MenuConfig)) do
        if cfg.type == "value" then
            local val = UIAction.CallFunction("Menu", -1, "GetValue", cfg.id, 0)
            cfg.value = val
            mod.Config[cfg.id] = val
            System.LogAlways(("[KCDUtils][OnApplySettings] Value applied: %s = %s"):format(cfg.id, tostring(val)))
            if mod.db then
                mod.db:Save(cfg.id, val)
            end

        elseif cfg.type == "choice" then
            local choiceId = UIAction.CallFunction("Menu", -1, "GetChoice", cfg.id, 0)
            if choiceId then
                choiceId = choiceId + 1 -- Lua 1-based Index
            end

            if cfg.apply then
                -- Multi-Key Choice: cfg.apply aktualisiert mod.Config korrekt
                cfg.apply(choiceId)
                cfg._selectedIndex = choiceId -- UI-Index behalten
                System.LogAlways(("[KCDUtils][OnApplySettings] Multi-Key choice applied: %s -> index %d"):format(cfg.id, choiceId))
            else
                -- Normale Choice
                if cfg.valueMap then
                    cfg.value = cfg.valueMap[choiceId]
                else
                    cfg.value = choiceId
                end
                cfg._selectedIndex = choiceId
                mod.Config[cfg.id] = cfg.value
                System.LogAlways(("[KCDUtils][OnApplySettings] Choice applied: %s = index %d"):format(cfg.id, choiceId))
            end
        end
    end

    -- Alle Änderungen in DB speichern
    KCDUtils.Config.SaveAll(mod.Name, mod.Config)
    System.LogAlways("[KCDUtils][OnApplySettings] All config values saved for mod " .. mod.Name)

    -- Zurück zum Mod-Settings-Menü
    self:OpenModSettings()
end

function KCDUtils.UI:OnResetSettings()
    local mods = getModsForMenu()
    local mod = mods[self._currentModIndex]
    if not mod or not mod.MenuConfig then return end

    System.LogAlways("[KCDUtils][OnResetSettings] Resetting config for mod: " .. (mod.Name or "unknown"))

    -- 1. Mod.Config zurücksetzen auf Default-Werte
    for key, cfg in pairs(mod.MenuConfig) do
        if cfg.type == "value" then
            mod.Config[key] = cfg.defaultValue or 0
        elseif cfg.type == "choice" then
            local defaultId = cfg.defaultChoiceId or 1
            if cfg.keys then
                local vals = cfg.valueMap[defaultId] or {}
                for i, k in ipairs(cfg.keys) do
                    mod.Config[k] = vals[i]
                end
            else
                mod.Config[key] = cfg.valueMap and cfg.valueMap[defaultId] or defaultId
            end
        end
    end

    -- 2. MenuConfig aktualisieren aus Mod.Config
    for key, cfg in pairs(mod.MenuConfig) do
        if cfg.type == "value" then
            cfg.value = mod.Config[key]
            UIAction.CallFunction("Menu", -1, "SetValue", cfg.id, 0, cfg.value)
            System.LogAlways(("[KCDUtils][OnResetSettings] Value reset: %s = %s"):format(cfg.id, tostring(cfg.value)))
        elseif cfg.type == "choice" then
            if cfg.keys then
                for i, k in ipairs(cfg.keys) do
                    cfg._selectedIndex = nil -- wird unten beim SetChoice neu gesetzt
                end
                -- Finde den Index in valueMap, der zu aktuellen Mod.Config passt
                for i, choice in ipairs(cfg.choices or {}) do
                    local vals = cfg.valueMap[i] or {}
                    local match = true
                    for j, k in ipairs(cfg.keys) do
                        if mod.Config[k] ~= vals[j] then
                            match = false
                            break
                        end
                    end
                    if match then
                        cfg._selectedIndex = i
                        break
                    end
                end
            else
                -- normale Choice
                for i, val in ipairs(cfg.valueMap or cfg.choices) do
                    if val == mod.Config[key] then
                        cfg._selectedIndex = i
                        break
                    end
                end
            end

            if cfg._selectedIndex then
                UIAction.CallFunction("Menu", -1, "SetChoice", cfg.id, 0, cfg._selectedIndex)
                System.LogAlways(("[KCDUtils][OnResetSettings] Choice reset: %s = index %d"):format(cfg.id, cfg._selectedIndex))
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
            System.LogAlways("[KCDUtils][OnMenuButtonEvent] User requested config reset")
            self:ShowConfirmation("Reset", "@ui_ResetDefault", "@ui_No", "@ui_Yes",
            function() self:OnResetSettings() end,
            function() end)
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

function KCDUtils.UI:ShowConfirmation(id, question, yesText, noText, callbackYes, callbackNo)
    if self._confirmation then
        UIAction.CallFunction("Menu", -1, "RemoveConfirmation", self._confirmation.id)
        self._confirmation = nil
    end

    System.LogAlways("[KCDUtils][ShowConfirmation] Showing confirmation dialog: " .. tostring(id))
    self._confirmation = { id = id, yes = callbackYes, no = callbackNo }
    UIAction.CallFunction("Menu", -1, "AddConfirmation", id, question, yesText, noText,  0, 1)
end

function KCDUtils.UI:HandleConfirmation(id, answer)
    if not self._confirmation or self._confirmation.id ~= id then return end
    
    local cbYes = self._confirmation.yes
    local cbNo = self._confirmation.no

    -- sofort löschen
    UIAction.CallFunction("Menu", -1, "RemoveConfirmation", id)
    self._confirmation = nil

    -- dann Callback aufrufen
    if answer == 1 and cbYes then cbYes() end
    if answer == 0 and cbNo then cbNo() end
end

function KCDUtils.UI:OnConfirmationEvent(elementName, instanceId, eventName, argTable)
    if eventName == "OnConfirm" then
        local id = tostring(argTable[0])
        local res = tonumber(argTable[1])
        System.LogAlways(("[KCDUtils][OnConfirmationEvent] Confirmation received: %s = %s"):format(id, tostring(res)))
        self:HandleConfirmation(id, res)
    end
end

-- Listener beim Start registrieren
function KCDUtils.UI:RegisterMenuListener()
    if UIAction and UIAction.RegisterElementListener then
        UIAction.RegisterElementListener(self, "Menu", -1, "", "OnMenuButtonEvent")
        UIAction.RegisterElementListener(self, "Menu", -1, "", "OnConfirmationEvent")
    end
end

local function InitializeUI()
    if not KCDUtils.UI._initiated then
        KCDUtils.UI._initiated = true
        KCDUtils.UI:RegisterMenuListener()
    end
end

InitializeUI()
