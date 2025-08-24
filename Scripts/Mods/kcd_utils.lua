SampleMod = SampleMod or {}

local mod = {
    Name = "SampleMod",
    DB = nil,
    Logger = nil,
    Config = nil
}

local function LoadScripts()
    Script.ReloadScript("Scripts/Mods/Utils/KCDUtils.lua")
    KCDUtils.Init(mod.Name)
end

local function LoadUtils()
    mod.DB = KCDUtils.DB.Factory(mod.Name)
    mod.Logger = KCDUtils.Logger.Factory(mod.Name)
end

function SampleMod.Init()
    LoadScripts()
    LoadUtils()
end

SampleMod.Init()