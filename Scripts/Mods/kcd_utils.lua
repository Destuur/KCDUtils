SampleMod = SampleMod or {}

local mod = {
    Name = "SampleMod",
    Logger = nil,
    DB = nil,
}

local function LoadScripts()
    Script.ReloadScript("Scripts/Mods/Utils/KCDUtils.lua")
end

local function LoadUtils()
    KCDUtils.Init(mod.Name)
    mod.DB = KCDUtils.DB.Factory(mod.Name)
    mod.Logger = KCDUtils.Logger.Factory(mod.Name)
end

function SampleMod.Init()
    LoadScripts()
    LoadUtils()
end

SampleMod.Init()