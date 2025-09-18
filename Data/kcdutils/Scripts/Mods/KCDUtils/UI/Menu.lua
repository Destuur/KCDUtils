KCDUtils.UI = KCDUtils.UI or {}
local buttonX = 1500
local startY = 380
local maxButtons = 7
local buttonWidth = 196

-- Hilfsfunktion: lädt alle registrierten Mods für das Menü
local function getModsForMenu()
    KCDUtils.UI.loadedMods = KCDUtils.UI.loadedMods or {}
    if #KCDUtils.UI.loadedMods == 0 then
        for _, mod in pairs(KCDUtils.RegisteredMods) do
            if mod.Config then
                table.insert(KCDUtils.UI.loadedMods, {
                    name = mod.Name,
                    description = mod.Description or "",
                    config = mod.Config
                })
            end
        end
    end
    return KCDUtils.UI.loadedMods
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
        local entry = {
            id = key,
            type = def.type or "value",
            tooltip = def.tooltip,
            min = def.min,
            max = def.max,
            choices = def.choices,
            valueMap = def.valueMap,
            hidden = def.hidden or false,   -- 👈 NEU
            value = def[1] ~= nil and def[1] or def.value
        }
        cfg[key] = entry
        table.insert(list, entry)
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

-- Öffnet die Mod-Übersichtsseite
function KCDUtils.UI:OpenModSettings()
    local mods = getModsForMenu()
    UIAction.CallFunction("Menu", -1, "ClearAll")
    UIAction.CallFunction("Menu", -1, "PreparePage", buttonX, startY, maxButtons, "Mod Settings", buttonWidth)

    for i, mod in ipairs(mods) do
        UIAction.CallFunction("Menu", -1, "AddBasicButton",
            "mod_"..i, 0, mod.name, mod.description or "", false
        )
    end

    -- Back-Button zum RootMenu
    UIAction.CallFunction("Menu", -1, "AddBasicButton",
        "Settings", 1, "@ui_back", "", false
    )

    UIAction.CallFunction("Menu", -1, "ShowPage")
end

-- Öffnet die Config einer einzelnen Mod
function KCDUtils.UI:OpenModConfig(modIndex)
    local mods = getModsForMenu()
    local mod = mods[modIndex]
    if not mod or not mod.config then return end

    -- Aktuell geöffnete Mod merken
    KCDUtils.UI._currentModIndex = modIndex

    UIAction.CallFunction("Menu", -1, "ClearAll")
    UIAction.CallFunction("Menu", -1, "PreparePage", buttonX, startY, #mod.config, mod.name.." Settings", buttonWidth)

    for _, cfg in ipairs(GetConfigEntries(mod.config)) do
        if not cfg.hidden then
            if cfg.type == "value" then
                UIAction.CallFunction("Menu", -1, "AddValueButton",
                    cfg.id, 0, cfg.id, cfg.value, cfg.min, cfg.max, cfg.tooltip or "", false
                )
            elseif cfg.type == "choice" then
                UIAction.CallFunction("Menu", -1, "AddChoicesButton",
                    cfg.id, 0, cfg.id, cfg.tooltip or "", false
                )
                for idx, choice in ipairs(cfg.choices) do
                    UIAction.CallFunction("Menu", -1, "AddChoiceOption",
                        idx, cfg.id, 0, choice, "", false
                    )
                end
            end
        end
    end

    -- Back-Button zur Mod-Übersicht
    UIAction.CallFunction("Menu", -1, "AddBasicButton",
        "ModSettings", 1, "@ui_back", "", false
    )

    UIAction.CallFunction("Menu", -1, "ShowPage")
end

-- Listener
function KCDUtils.UI:OnMenuButtonEvent(elementName, instanceId, eventName, argTable)
    if eventName == "OnButton" then
        local clickedButton = tostring(argTable[0])
        System.LogAlways("[KCDUtils] Button clicked: " .. clickedButton)

        if clickedButton == "ModSettings" then
            self:OpenModSettings()
        elseif clickedButton:match("^mod_%d+$") then
            local modIndex = tonumber(clickedButton:match("%d+"))
            self:OpenModConfig(modIndex)
        elseif clickedButton == "Back" then
            if KCDUtils.UI._currentModIndex then
                -- Zurück zur Mod-Übersicht
                KCDUtils.UI._currentModIndex = nil
                self:OpenModSettings()
            else
                -- Zurück ins RootMenu
                UIAction.CallFunction("Menu", -1, "Back")
            end
        end
    elseif eventName == "OnInteractiveChoice" then
        local id = tostring(argTable[0])
        local choiceId = tonumber(argTable[1])
        KCDUtils.UI.UpdateConfigChoice(id, choiceId)
    elseif eventName == "OnInteractiveValue" then
        local id = tostring(argTable[0])
        local value = tonumber(argTable[1])
    end
end

-- Listener beim Start registrieren
function KCDUtils.UI:RegisterMenuListener()
    if UIAction and UIAction.RegisterElementListener then
        UIAction.RegisterElementListener(self, "Menu", -1, "", "OnMenuButtonEvent")
        System.LogAlways("[KCDUtils] Registered Menu listener")
    else
        System.LogAlways("[KCDUtils] UIAction not available for Menu registration")
    end
end

function KCDUtils.UI.UpdateConfigChoice(id, choiceId)
    local mods = getModsForMenu()
    for _, mod in ipairs(mods) do
        if mod.config then
            for _, cfg in ipairs(GetConfigEntries(mod.config)) do
                if cfg.id == id and cfg.type == "choice" then
                    if cfg.valueMap then
                        cfg.value = cfg.valueMap[choiceId]
                    else
                        cfg.value = choiceId -- fallback: numerischer Index
                    end
                    mod.config[id] = cfg.value -- sorgt dafür, dass __newindex greift
                    mod._modifiedConfig = mod._modifiedConfig or {}
                    mod._modifiedConfig[id] = true
                    System.LogAlways(("[KCDUtils] Choice updated: %s = %s"):format(id, tostring(cfg.value)))
                    return
                end
            end
        end
    end
end

-- Initialisierung
local function InitializeUI()
    if not KCDUtils.UI._initiated then
        KCDUtils.UI._initiated = true
        KCDUtils.UI:RegisterMenuListener()
        System.LogAlways("[KCDUtils] UI initialization complete")
    end
end

-- Direkt beim Laden aufrufen
InitializeUI()
