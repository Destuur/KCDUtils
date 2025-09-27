KCDUtils.Menu = KCDUtils.Menu or {}
KCDUtils.Menu._menuConfigs = KCDUtils.Menu._menuConfigs or {}

local buttonX = 1500
local startY = 380
local maxButtons = 7
local buttonWidth = 196

function GetConfigEntries(modName)
    local entries = {}
    local menuConfig = KCDUtils.Menu.Config and KCDUtils.Menu.Config[modName]
    if not menuConfig then return entries end

    for _, key in ipairs(menuConfig._order or {}) do
        local entry = menuConfig[key]
        if entry then
            table.insert(entries, entry)
        end
    end

    return entries
end

local function getVanillaChoiceUIText(choice)
    local lookup = { ["Yes"]="@ui_Yes", ["No"]="@ui_No", ["Off"]="@ui_off", ["On"]="@ui_on" }
    return lookup[choice] or nil
end

local function mapBoolChoice(cfg, direction)
    if not cfg or cfg.type ~= "choice" or not cfg.valueMap then
        return
    end

    if direction == "toIndex" then
        for i, v in ipairs(cfg.valueMap) do
            local val = v
            if type(val) == "string" and (val == "true" or val == "false") then
                val = (val == "true")
            end
            if val == cfg.value then
                cfg._selectedIndex = i - 1
                return
            end
        end
        cfg._selectedIndex = 0
    elseif direction == "toValue" then
        local index = cfg._selectedIndex or 0
        local val = cfg.valueMap[index + 1]
        if type(val) == "string" and (val == "true" or val == "false") then
            cfg.value = (val == "true")
        else
            cfg.value = val
        end
    end
end

function KCDUtils.Menu.RegisterMod(mod, menuDefs)
    if not mod or not menuDefs then return end

    KCDUtils.Menu._registeredMenus = KCDUtils.Menu._registeredMenus or {}
    KCDUtils.Menu._registeredMenus[mod.Name] = {
        mod = mod,
        defs = menuDefs
    }

    -- Defaults vorbereiten, aber keine DB-Werte setzen
    local defaults = {}
    for _, def in ipairs(menuDefs) do
        if def.type == "value" then
            defaults[def.key] = def.default or 0
        elseif def.type == "choice" then
            defaults[def.key] = def.valueMap and (def.default or def.valueMap[1])
                or def.choices[(def.defaultChoiceId or 1)]
        end
    end

    mod._menuDefaults = defaults
end

local function getModsForMenu()
    local mods = {}
    for _, mod in pairs(KCDUtils.RegisteredMods or {}) do
        if mod.Config then
            if not mod.MenuConfig then
                local reg = KCDUtils.Menu._registeredMenus and KCDUtils.Menu._registeredMenus[mod.Name]
                if reg and mod.DB then
                    KCDUtils.Menu.BuildWithDB(mod, reg.defs)
                end
            end
            table.insert(mods, mod)
        end
    end
    return mods
end

function KCDUtils.Menu.BuildWithDB(mod)
    if not mod or not mod.DB then
        return
    end

    local reg = KCDUtils.Menu._registeredMenus and KCDUtils.Menu._registeredMenus[mod.Name]
    if not reg then return end

    -- Defaults vorbereiten + Def-Lookup
    local defaultTable, defLookup = {}, {}
    for _, def in ipairs(reg.defs) do
        defLookup[def.key] = def
        if def.type == "value" then
            defaultTable[def.key] = def.default or 0
        elseif def.type == "choice" then
            defaultTable[def.key] = def.valueMap and (def.default or def.valueMap[1])
                or def.choices[(def.defaultChoiceId or 1)]
        end
    end

    -- DB laden oder Defaults setzen
    mod._dbValues = {}
    for key, _ in pairs(defaultTable) do
        local raw = mod.DB:Get(key)
        if raw ~= nil then
            local def = defLookup[key]
            if def and def.valueMap then
                -- Boolean-Strings casten
                if raw == "true" then
                    mod._dbValues[key] = true
                elseif raw == "false" then
                    mod._dbValues[key] = false
                else
                    mod._dbValues[key] = raw
                end
            else
                mod._dbValues[key] = raw
            end
        end
    end

    -- Create mit Definitions und DB-Werten
    mod.MenuConfig = KCDUtils.Menu.Create(mod, reg.defs)
end

function KCDUtils.Menu.Create(mod, defs)
    if not mod or not defs then return end

    local db = KCDUtils.DB.Factory(mod.Name)
    local menuConfig = {}
    local order = {}

    for _, def in ipairs(defs) do
        local key = def.key
        local entry = {
            id = key,
            type = def.type,
            tooltip = def.tooltip or "",
            hidden = def.hidden or false
        }

        local dbVal
        if mod._dbValues and mod._dbValues[key] ~= nil then
            dbVal = mod._dbValues[key]
        elseif def.type == "value" then
            dbVal = def.default or 0
        elseif def.valueMap then
            dbVal = def.default or def.valueMap[1]
        else
            dbVal = def.choices[def.defaultChoiceId or 1]
        end

        if def.type == "value" then
            entry.default = def.default or 0
            entry.min = def.min or 0
            entry.max = def.max or 100
            entry.value = dbVal
        elseif def.type == "choice" then
            entry.choices = def.choices or {}
            entry.valueMap = def.valueMap

            if entry.valueMap then
                entry.default = def.default or entry.valueMap[1]
                entry.value = dbVal
                mapBoolChoice(entry, "toIndex")
            else
                entry.defaultChoiceId = def.defaultChoiceId or 1
                entry.value = dbVal
                entry._selectedIndex = 0
                for i, choice in ipairs(entry.choices) do
                    if choice == entry.value then
                        entry._selectedIndex = i - 1
                        break
                    end
                end
            end
        end

        menuConfig[key] = entry
        table.insert(order, key)
    end

    menuConfig._order = order
    KCDUtils.Menu.Config = KCDUtils.Menu.Config or {}
    KCDUtils.Menu.Config[mod.Name] = menuConfig
    mod.MenuConfig = menuConfig
    return menuConfig
end

function KCDUtils.Menu:OpenModOverview()
    local mods = getModsForMenu()
    if not mods or #mods == 0 then
        System.LogAlways("[KCDUtils][OpenModOverview] No mods found, aborting")
        return
    end

    UIAction.CallFunction("Menu", -1, "ClearAll")
    UIAction.CallFunction("Menu", -1, "PreparePage", buttonX, startY, maxButtons, "@ui_mod_overview", buttonWidth)

    for i, mod in ipairs(mods) do
        local uiText = "@ui_" .. (mod.Name or "unknown")
        UIAction.CallFunction("Menu", -1, "AddBasicButton", "mod_"..i, 0, uiText, mod.description or "", false)
    end

    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Back", 1, "@ui_back", "", false)
    UIAction.CallFunction("Menu", -1, "ShowPage")
end

function KCDUtils.Menu:OpenModConfig(modIndex)
    local mods = getModsForMenu()
    local mod = mods[modIndex]
    if not mod or not mod.Name then return end

    self._currentModIndex = modIndex
    local freshConfig = {}
    for _, cfg in ipairs(GetConfigEntries(mod.Name)) do
        local copy = {}
        for k, v in pairs(cfg) do copy[k] = v end
        table.insert(freshConfig, copy)
    end
    self._activeConfig = { mod = mod, entries = freshConfig }

    UIAction.CallFunction("Menu", -1, "ClearAll")
    UIAction.CallFunction("Menu", -1, "PreparePage", buttonX, startY, maxButtons + 2, "@ui_" .. mod.Name .. "_settings", buttonWidth)

        for _, cfg in ipairs(freshConfig) do
        if not cfg.hidden then
            local uiText = "@ui_" .. mod.Name .. "_" .. cfg.id
            local uiTooltip = "@ui_" .. mod.Name .. "_" .. cfg.id .. "_tooltip"

            if cfg.type == "value" then
                UIAction.CallFunction("Menu", -1, "AddValueButton", cfg.id, 0, uiText, cfg.value, cfg.min, cfg.max, uiTooltip, false)
            elseif cfg.type == "choice" then
                -- Mapping Bool → Index, falls valueMap vorhanden
                mapBoolChoice(cfg, "toIndex")

                -- Button und Optionen hinzufügen
                UIAction.CallFunction("Menu", -1, "AddChoicesButton", cfg.id, 0, uiText, uiTooltip, false)
                for idx, choice in ipairs(cfg.choices or {}) do
                    local choiceText = getVanillaChoiceUIText(choice) or "@ui_" .. mod.Name .. "_" .. cfg.id .. "_" .. idx
                    UIAction.CallFunction("Menu", -1, "AddChoiceOption", idx - 1, cfg.id, 0, choiceText, "", false)
                end

                -- 🟢 Debug-Ausgabe direkt hier einfügen
                System.LogAlways(("[BuildMenu] %s: value=%s, mappedIndex=%s, choiceText=%s"):format(
                    cfg.id,
                    tostring(cfg.value),
                    tostring(cfg._selectedIndex),
                    cfg.choices[(cfg._selectedIndex or 0) + 1] or "nil"
                ))

                -- SetChoice mit 0-basiertem Index
                UIAction.CallFunction("Menu", -1, "SetChoice", cfg.id, 0, cfg._selectedIndex or 0)
            end
        end
    end

    UIAction.CallFunction("Menu", -1, "AddBasicButton", "ModApply", 1, "@ui_apply", "", false)
    UIAction.CallFunction("Menu", -1, "AddBasicButton", "ModReset", 1, "@ui_reset", "", false)
    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Back", 1, "@ui_back", "", false)
    UIAction.CallFunction("Menu", -1, "ShowPage")
end

function KCDUtils.Menu:OnApplySettings()
    local active = self._activeConfig
    if not active then return end
    local mod = active.mod
    if not mod then return end

    for _, cfg in ipairs(active.entries) do
        if not cfg.hidden then
            if cfg.type == "value" then
                local val = UIAction.CallFunction("Menu", -1, "GetValue", cfg.id, 0)
                cfg.value = tonumber(string.format("%.0f", val))
            elseif cfg.type == "choice" then
                local choiceId = UIAction.CallFunction("Menu", -1, "GetChoice", cfg.id, 0) or 0
                cfg._selectedIndex = choiceId
                mapBoolChoice(cfg, "toValue")
            end
        end
    end

    mod.OnMenuChanged:Trigger(active.entries)
    self._activeConfig = nil
    self:OpenModOverview()
end

function KCDUtils.Menu:OnResetSettings()
    local mods = getModsForMenu()
    local mod = mods[self._currentModIndex]
    if not mod or not mod.MenuConfig then
        return
    end

    for key, cfg in pairs(mod.MenuConfig) do
        if not cfg.hidden then
            if cfg.type == "value" then
                cfg.value = cfg.default or 0
                UIAction.CallFunction("Menu", -1, "SetValue", cfg.id, 0, cfg.value)

            elseif cfg.type == "choice" then
                if cfg.valueMap then
                    cfg.value = cfg.default
                    mapBoolChoice(cfg, "toIndex")
                else
                    cfg._selectedIndex = (cfg.defaultChoiceId or 1) - 1
                    mapBoolChoice(cfg, "toValue")
                end

                UIAction.CallFunction("Menu", -1, "SetChoice", cfg.id, 0, cfg._selectedIndex or 0)
            end
        end
    end
    mod.OnMenuChanged:Trigger()
end

function KCDUtils.Menu:UpdateConfigValue(id, value)
    local active = self._activeConfig
    if not active then return end
    for _, cfg in ipairs(active.entries) do
        if cfg.id == id and cfg.type == "value" then
            cfg.value = tonumber(value)
            return
        end
    end
end

function KCDUtils.Menu:UpdateConfigChoice(id, choiceId)
    local active = self._activeConfig
    if not active then return end
    for _, cfg in ipairs(active.entries) do
        if cfg.id == id and cfg.type == "choice" then
            cfg._selectedIndex = choiceId
            mapBoolChoice(cfg, "toValue")
            return
        end
    end
end

function KCDUtils.Menu:OnMenuButtonEvent(elementName, instanceId, eventName, argTable)
    if eventName ~= "OnButton" and eventName ~= "OnInteractiveChoice" and eventName ~= "OnInteractiveValue" then
        return
    end

    local id = tostring(argTable[0] or "")

    local allowedButtons = {
        Settings = true,
        ModSettings = true,
        Back = true,
        ModApply = true,
        ModReset = true,
    }

    local isAllowed =
        allowedButtons[id] or
        id:match("^mod_%d+$") -- Buttons wie "mod_1", "mod_2", ...
    
    -- Wenn es ein Config-Event ist (Choice/Value), prüfen ob ID zu einem Mod gehört
    if not isAllowed and (eventName == "OnInteractiveChoice" or eventName == "OnInteractiveValue") then
        local mods = getModsForMenu()
        for _, mod in ipairs(mods) do
            for _, cfg in ipairs(GetConfigEntries(mod.Name)) do
                if cfg.id == id then
                    isAllowed = true
                    break
                end
            end
            if isAllowed then break end
        end
    end

    if not isAllowed then
        return
    end

    if eventName == "OnButton" then
        if id == "Settings" and not KCDUtils.HasGameStarted then
            UIAction.CallFunction("Menu", -1, "SetDisable", "ModSettings", 0, "@ui_game_not_started", true)
        elseif id == "ModSettings" then
            self:OpenModOverview()
        elseif id:match("^mod_%d+$") then
            local modIndex = tonumber(id:match("%d+"))
            self:OpenModConfig(modIndex)
        elseif id == "Back" then
            if self._currentModIndex then
                local mods = getModsForMenu()
                local mod = mods[self._currentModIndex]
                if mod and mod.MenuConfig then
                    local hasChanges = UIAction.CallFunction("Menu", -1, "IsSomeButtonChanged")
                    if hasChanges then
                        self:ShowConfirmation("Back", "@ui_ApplyChanges", "@ui_Yes", "@ui_No",
                            function()
                                self:OnApplySettings()
                                self:OpenModOverview()
                                self._currentModIndex = nil
                            end,
                            function()
                                self:OpenModOverview()
                                self._currentModIndex = nil
                            end
                        )
                    else
                        self._currentModIndex = nil
                        self:OpenModOverview()
                    end
                else
                    self._currentModIndex = nil
                    self:OpenModOverview()
                end
            else
                self:OpenModOverview()
            end
    elseif id == "ModApply" then
        self:ShowConfirmation("ModApply", "@ui_ApplyChanges", "@ui_Yes", "@ui_No",
            function() self:OnApplySettings() end,
            function() end
        )
    elseif id == "ModReset" then
        System.LogAlways("[KCDUtils][OnMenuButtonEvent] ModReset button clicked")
        self:ShowConfirmation("ModReset", "@ui_ResetDefault", "@ui_No", "@ui_Yes",
            function() end,
            function() self:OnResetSettings() end
        )
    end
    elseif eventName == "OnInteractiveChoice" then
        local choiceId = tonumber(argTable[1])
        self:UpdateConfigChoice(id, choiceId)
    elseif eventName == "OnInteractiveValue" then
        local value = tonumber(argTable[1])
        self:UpdateConfigValue(id, value)
    end
end


function KCDUtils.Menu:ShowConfirmation(id, question, yesText, noText, callbackYes, callbackNo)
    -- Falls noch ein altes Fenster gesetzt ist, abbrechen und überschreiben
    if self._confirmation then
        System.LogAlways("[KCDUtils][ShowConfirmation] Overwriting existing confirmation: " .. tostring(self._confirmation.id))
        UIAction.CallFunction("Menu", -1, "RemoveConfirmation", self._confirmation.id)
    end

    self._confirmation = { id = id, yes = callbackYes, no = callbackNo }
    UIAction.CallFunction("Menu", -1, "AddConfirmation", id, question, yesText, noText, 0, 1)
end

function KCDUtils.Menu:HandleConfirmation(id, answer)
    System.LogAlways(("[HandleConfirmation] id=%s, answer=%s"):format(id, tostring(answer)))
    if not self._confirmation or self._confirmation.id ~= id then return end
    local cbYes, cbNo = self._confirmation.yes, self._confirmation.no
    UIAction.CallFunction("Menu", -1, "RemoveConfirmation", id)
    self._confirmation = nil
    
    if answer == 0 and cbYes then cbYes()
    elseif answer == 1 and cbNo then cbNo() end
end

function KCDUtils.Menu:OnConfirmationEvent(elementName, instanceId, eventName, argTable)
    if eventName == "OnConfirm" then
        local id, res = tostring(argTable[0]), tonumber(argTable[1])
        self:HandleConfirmation(id, res)
    end
end

-- Listener registrieren
function KCDUtils.Menu:RegisterModListener()
    if UIAction and UIAction.RegisterElementListener then
        UIAction.RegisterElementListener(self, "Menu", -1, "", "OnMenuButtonEvent")
        UIAction.RegisterElementListener(self, "Menu", -1, "", "OnConfirmationEvent")
    end
end

local function InitializeUI()
    if not KCDUtils.Menu._initiated then
        KCDUtils.Menu._initiated = true
        KCDUtils.Menu:RegisterModListener()
    end
end

InitializeUI()
