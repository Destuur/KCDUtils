KCDUtils.UI = KCDUtils.UI or {}
KCDUtils.UI._menuConfigs = KCDUtils.UI._menuConfigs or {}

local buttonX = 1500
local startY = 380
local maxButtons = 7
local buttonWidth = 196

local function getVanillaChoiceUIText(choice)
    local lookup = { ["Yes"]="@ui_Yes", ["No"]="@ui_No", ["Off"]="@ui_off", ["On"]="@ui_on" }
    return lookup[choice] or choice
end

local function mapBoolChoice(cfg, direction)
    -- direction = "toIndex" -> Bool → Index für Menü
    -- direction = "toValue" -> Index → Bool aus Menü
    if not cfg or cfg.type ~= "choice" or not cfg.valueMap then return end

    if direction == "toIndex" then
        -- cfg.value ist Bool, wir suchen den Index
        for i, v in ipairs(cfg.valueMap) do
            if v == cfg.value then
                cfg._selectedIndex = i - 1 -- 0-basiert für SetChoice
                return
            end
        end
        -- fallback
        cfg._selectedIndex = 0
    elseif direction == "toValue" then
        local index = cfg._selectedIndex or 0
        cfg.value = cfg.valueMap[index + 1] -- Lua 1-basiert
    end
end

local function getModsForMenu()
    local mods = {}
    for _, mod in pairs(KCDUtils.RegisteredMods or {}) do
        if mod.Config then
            if not mod.MenuConfig then
                mod.MenuConfig = KCDUtils.UI.MenuBuilder(mod, mod.Config)
                if mod.DB then
                    KCDUtils.Config.LoadFromDB(mod.Name, mod.MenuConfig)
                end
            end
            table.insert(mods, mod)
        end
    end
    return mods
end

function GetConfigEntries(modName)
    local entries = {}
    local menuConfig = KCDUtils.UI.Config and KCDUtils.UI.Config[modName]
    if not menuConfig then
        return entries
    end

    for _, entry in pairs(menuConfig) do
        table.insert(entries, entry)
    end

    return entries
end

function KCDUtils.UI.MenuBuilder(mod, defs)
    if not mod or not defs then return end

    -- UI-eigener Config Table, unabhängig von mod.Config
    local menuConfig = {}

    for key, def in pairs(defs) do
        local entry = {
            id = key,
            type = def.type,
            tooltip = def.tooltip or "",
            hidden = def.hidden or false
        }

        if def.type == "value" then
            entry.value = def.default or 0
            entry.min = def.min or 0
            entry.max = def.max or 100
        elseif def.type == "choice" then
            entry.choices = def.choices or {}
            entry.valueMap = def.valueMap
            entry.value = def.default  -- direkt den Bool übernehmen

            if entry.valueMap then
                for i, v in ipairs(entry.valueMap) do
                    if v == entry.value then
                        entry._selectedIndex = i - 1 -- 0-basiert für SetChoice
                        break
                    end
                end
                if not entry._selectedIndex then entry._selectedIndex = 0 end
            else
                entry._selectedIndex = (def.defaultChoiceId or 1) - 1
            end
            entry.defaultChoiceId = def.defaultChoiceId or 1
        end

        menuConfig[key] = entry
    end

    -- UI-spezifische Config speichern
    KCDUtils.UI.Config = KCDUtils.UI.Config or {}
    KCDUtils.UI.Config[mod.Name] = menuConfig

    mod.MenuConfig = menuConfig -- optional, nur für Referenz im Menü
    return menuConfig
end

-- local function UpdateConfigFromUI(cfg)
--     if cfg.type == "value" then
--         cfg.value = UIAction.CallFunction("Menu", -1, "GetValue", cfg.id, 0)
--     elseif cfg.type == "choice" then
--         local choiceId = UIAction.CallFunction("Menu", -1, "GetChoice", cfg.id, 0) or 0
--         cfg._selectedIndex = choiceId + 1
--         if cfg.valueMap then
--             cfg.value = cfg.valueMap[cfg._selectedIndex]
--         elseif cfg.choices then
--             local choice = cfg.choices[cfg._selectedIndex]
--             if choice == "Yes" or choice == "On" then
--                 cfg.value = true
--             elseif choice == "No" or choice == "Off" then
--                 cfg.value = false
--             else
--                 cfg.value = choice
--             end
--         else
--             cfg.value = cfg._selectedIndex
--         end
--     end
-- end

-- ==========================
-- Mod-Übersicht
-- ==========================
-- Mod-Übersicht öffnen
function KCDUtils.UI:OpenModOverview()
    local mods = getModsForMenu()
    if not mods or #mods == 0 then
        System.LogAlways("[KCDUtils][OpenModOverview] No mods found, aborting")
        return
    end

    UIAction.CallFunction("Menu", -1, "ClearAll")
    UIAction.CallFunction("Menu", -1, "PreparePage", buttonX, startY, maxButtons, "Mod Overview", buttonWidth)

    for i, mod in ipairs(mods) do
        local uiText = "@ui_" .. (mod.Name or "unknown")
        UIAction.CallFunction("Menu", -1, "AddBasicButton", "mod_"..i, 0, uiText, mod.description or "", false)
    end

    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Back", 1, "@ui_back", "", false)
    UIAction.CallFunction("Menu", -1, "ShowPage")
end

function KCDUtils.UI:OpenModConfig(modIndex)
    local mods = getModsForMenu()
    local mod = mods[modIndex]
    if not mod or not mod.Name then return end

    self._currentModIndex = modIndex
    local menuConfig = KCDUtils.UI.Config and KCDUtils.UI.Config[mod.Name]
    if not menuConfig then
        System.LogAlways("[KCDUtils][OpenModConfig] No UI config found for mod: " .. tostring(mod.Name))
        return
    end

    UIAction.CallFunction("Menu", -1, "ClearAll")
    UIAction.CallFunction("Menu", -1, "PreparePage", buttonX, startY, maxButtons + 2, "@ui_" .. mod.Name .. "_settings", buttonWidth)

    for _, cfg in ipairs(GetConfigEntries(mod.Name)) do
        if not cfg.hidden then
            local uiText = "@ui_" .. mod.Name .. "_" .. cfg.id

            if cfg.type == "value" then
                UIAction.CallFunction("Menu", -1, "AddValueButton", cfg.id, 0, uiText, cfg.value, cfg.min, cfg.max, cfg.tooltip or "", false)
            elseif cfg.type == "choice" then
                -- Mapping Bool → Index, falls valueMap vorhanden
                mapBoolChoice(cfg, "toIndex")

                -- Button und Optionen hinzufügen
                UIAction.CallFunction("Menu", -1, "AddChoicesButton", cfg.id, 0, uiText, cfg.tooltip or "", false)
                for idx, choice in ipairs(cfg.choices or {}) do
                    local choiceText = getVanillaChoiceUIText(choice) or "@ui_" .. mod.Name .. "_" .. cfg.id .. "_" .. idx
                    UIAction.CallFunction("Menu", -1, "AddChoiceOption", idx - 1, cfg.id, 0, choiceText, "", false)
                end

                -- SetChoice mit 0-basiertem Index
                UIAction.CallFunction("Menu", -1, "SetChoice", cfg.id, 0, cfg._selectedIndex or 0)
            end
        end
    end

    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Reset", 1, "@ui_reset", "", false)
    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Apply", 1, "@ui_apply", "", false)
    UIAction.CallFunction("Menu", -1, "AddBasicButton", "Back", 1, "@ui_back", "", false)
    UIAction.CallFunction("Menu", -1, "ShowPage")
end

function KCDUtils.UI:OnApplySettings()
    local mods = getModsForMenu()
    local mod = mods[self._currentModIndex]
    if not mod then
        System.LogAlways("[KCDUtils][OnApplySettings] No mod selected, aborting")
        return
    end

    if not mod.MenuConfig then
        System.LogAlways("[KCDUtils][OnApplySettings] Mod.MenuConfig is nil for mod: " .. tostring(mod.Name))
        return
    end

    local entries = {}
    for key, cfg in pairs(mod.MenuConfig) do
        table.insert(entries, cfg)
    end

    for _, cfg in ipairs(entries) do
        if not cfg.hidden then
            if cfg.type == "value" then
                local val = UIAction.CallFunction("Menu", -1, "GetValue", cfg.id, 0)
                cfg.value = val
                if mod.DB then mod.DB:Set(cfg.id, val) end
            elseif cfg.type == "choice" then
                -- 0-basiert direkt vom UI holen, nicht +1
                local choiceId = UIAction.CallFunction("Menu", -1, "GetChoice", cfg.id, 0) or 0
                cfg._selectedIndex = choiceId  -- bleibt 0-basiert
                mapBoolChoice(cfg, "toValue")  -- setzt cfg.value korrekt (true/false)
                if mod.DB then mod.DB:Set(cfg.id, cfg.value) end
            end
        end
    end

    KCDUtils.Events.MenuChanged.Trigger()
    self:OpenModOverview()
end

function KCDUtils.UI:OnResetSettings()
    System.LogAlways("[KCDUtils][OnResetSettings] Resetting settings...")
    local mods = getModsForMenu()
    local mod = mods[self._currentModIndex]
    if not mod or not mod.MenuConfig then 
        System.LogAlways("[KCDUtils][OnResetSettings] No mod or MenuConfig found, aborting")
        return 
    end

    System.LogAlways("[KCDUtils][OnResetSettings] Resetting settings for mod: " .. (mod.Name or "unknown"))

    for _, cfg in ipairs(GetConfigEntries(mod.Name)) do
        if cfg.type == "value" then
            cfg.value = cfg.default or 0  -- default statt defaultValue
            UIAction.CallFunction("Menu", -1, "SetValue", cfg.id, 0, cfg.value)
            if mod.DB then mod.DB:Set(cfg.id, cfg.value) end
            System.LogAlways(("[KCDUtils][OnResetSettings] Reset value: %s = %s"):format(cfg.id, tostring(cfg.value)))

        elseif cfg.type == "choice" then
            if cfg.valueMap then
                -- Boolean-Mapping: direkt den Default-Wert nutzen
                cfg.value = cfg.default
                mapBoolChoice(cfg, "toIndex") -- setzt _selectedIndex passend
            else
                -- normale Choice über defaultChoiceId
                cfg._selectedIndex = (cfg.defaultChoiceId or 1) - 1
                mapBoolChoice(cfg, "toValue")
            end

            UIAction.CallFunction("Menu", -1, "SetChoice", cfg.id, 0, cfg._selectedIndex or 0)
            if mod.DB then mod.DB:Set(cfg.id, cfg.value) end
            System.LogAlways(("[KCDUtils][OnResetSettings] Reset choice: %s = %s (index=%s)"):format(
                cfg.id, tostring(cfg.value), tostring(cfg._selectedIndex)))
        end
    end

    System.LogAlways("[KCDUtils][OnResetSettings] All config values reset and saved for mod " .. mod.Name)
end

function KCDUtils.UI.UpdateConfigValue(id, value)
    local mods = getModsForMenu()
    for _, mod in ipairs(mods) do
        for _, cfg in ipairs(GetConfigEntries(mod.MenuConfig)) do
            if cfg.id == id and cfg.type == "value" then
                cfg.value = value
                return
            end
        end
    end
end

function KCDUtils.UI.UpdateConfigChoice(id, choiceId)
    local mods = getModsForMenu()
    for _, mod in ipairs(mods) do
        for _, cfg in ipairs(GetConfigEntries(mod.MenuConfig)) do
            if cfg.id == id and cfg.type == "choice" then
                cfg._selectedIndex = choiceId  -- UI liefert schon 0-basiert
                local luaIndex = choiceId + 1  -- für valueMap/choices
                if cfg.valueMap then
                    cfg.value = cfg.valueMap[luaIndex]
                else
                    cfg.value = cfg.choices[luaIndex]
                end
                System.LogAlways(("[UpdateConfigChoice] %s -> index=%s, value=%s"):format(
                    id, tostring(cfg._selectedIndex), tostring(cfg.value)))
                return
            end
        end
    end
end

function KCDUtils.UI:OnMenuButtonEvent(elementName, instanceId, eventName, argTable)
    if eventName == "OnButton" then
        local clickedButton = tostring(argTable[0])
        if clickedButton == "ModSettings" then
            self:OpenModOverview()
        elseif clickedButton:match("^mod_%d+$") then
            local modIndex = tonumber(clickedButton:match("%d+"))
            self:OpenModConfig(modIndex)
        elseif clickedButton == "Back" then
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
        elseif clickedButton == "Apply" then
            self:ShowConfirmation("Apply", "@ui_ApplyChanges", "@ui_Yes", "@ui_No",
                function() self:OnApplySettings() end,
                function() end
            )
        elseif clickedButton == "Reset" then
            System.LogAlways("[KCDUtils][OnMenuButtonEvent] Reset button clicked")
            self:ShowConfirmation("Reset", "@ui_ResetDefault", "@ui_No", "@ui_Yes",
                function() end,
                function() self:OnResetSettings() end
            )
        end
    elseif eventName == "OnInteractiveChoice" then
        local id = tostring(argTable[0])
        local choiceId = tonumber(argTable[1])
        self:UpdateConfigChoice(id, choiceId)
    elseif eventName == "OnInteractiveValue" then
        local id = tostring(argTable[0])
        local value = tonumber(argTable[1])
        self:UpdateConfigValue(id, value)
    end
end

function KCDUtils.UI:ShowConfirmation(id, question, yesText, noText, callbackYes, callbackNo)
    if self._confirmation then
        -- Ignoriere neue Confirmation, solange alte aktiv ist
        System.LogAlways("[KCDUtils][ShowConfirmation] Confirmation already active, ignoring new request")
        return
    end
    self._confirmation = { id = id, yes = callbackYes, no = callbackNo }
    UIAction.CallFunction("Menu", -1, "AddConfirmation", id, question, yesText, noText, 0, 1)
end

function KCDUtils.UI:HandleConfirmation(id, answer)
    System.LogAlways(("[HandleConfirmation] id=%s, answer=%s"):format(id, tostring(answer)))
    if not self._confirmation or self._confirmation.id ~= id then return end
    local cbYes, cbNo = self._confirmation.yes, self._confirmation.no
    UIAction.CallFunction("Menu", -1, "RemoveConfirmation", id)
    self._confirmation = nil
    
    if answer == 0 and cbYes then cbYes()
    elseif answer == 1 and cbNo then cbNo() end
end

function KCDUtils.UI:OnConfirmationEvent(elementName, instanceId, eventName, argTable)
    if eventName == "OnConfirm" then
        local id, res = tostring(argTable[0]), tonumber(argTable[1])
        self:HandleConfirmation(id, res)
    end
end

-- Listener registrieren
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
