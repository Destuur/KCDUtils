SampleMod = SampleMod or {}

local myDB = DB.Create("SampleMod")

System.LogAlways("SampleMod initializing...")

function SampleMod.Init()
    Script.ReloadScript("Scripts/Mods/Utils/KCDUtils.lua")
    KCDUtils.Init("SampleMod")
    System.LogAlways("SampleMod initialized")
    local msg = KCDUtils.String.GetModNameFromDB(myDB)
    System.LogAlways("Mod Name: " .. tostring(msg))
end

SampleMod.Init()