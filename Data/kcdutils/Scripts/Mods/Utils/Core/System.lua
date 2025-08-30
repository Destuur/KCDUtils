--- @class KCDUtils.System
KCDUtils.System = KCDUtils and KCDUtils.System or {}

--- Getter for any entity by name
--- @param name (string) The name of the entity to retrieve.
--- @return (any|nil) entity The entity with the specified name, or nil if not found.
function KCDUtils.System.GetEntityByName(name)
    local logger = KCDUtils.Logger.Factory("System")
    local entity = System.GetEntityByName(name)
    if not entity then
        logger:Warn("Entity with name '" .. tostring(name) .. "' not found.")
    end
    return entity
end

--- Getter for the player entity
--- @return (any|nil) player The player entity, or nil if not found.
function KCDUtils.System.GetPlayer()
    local logger = KCDUtils.Logger.Factory("System")
    local player = System.GetEntityByName("dude") or System.GetEntityByName("Player")
    if not player then
        logger:Warn("Player entity not found.")
    end
    return player
end

-- [Function] System.GetEntityByGUID | params: 0 | vararg: false
-- [Function] System.ViewDistanceSet | params: 0 | vararg: false
-- [Function] System.LoadFont | params: 0 | vararg: false
-- [Function] System.GetEntity | params: 0 | vararg: false
-- [Function] System.SetScreenFx | params: 0 | vararg: false
-- [Function] System.SpawnEntity | params: 0 | vararg: false
-- [Function] System.ShowDebugger | params: 0 | vararg: false
-- [Function] System.DrawLabel | params: 0 | vararg: false
-- [Function] System.EnableMainView | params: 0 | vararg: false
-- [Function] System.ShowConsole | params: 0 | vararg: false
-- [Function] System.GetPhysicalEntitiesInBoxByClass | params: 0 | vararg: false
-- [Function] System.Warning | params: 0 | vararg: false
-- [Function] System.DrawLine | params: 0 | vararg: false
-- [Function] System.Draw2DLine | params: 0 | vararg: false
-- [Function] System.CreateDownload | params: 0 | vararg: false
-- [Function] System.ResetPoolEntity | params: 0 | vararg: false
-- [Function] System.AddCCommand | params: 0 | vararg: false
-- [Function] System.GetCurrTime | params: 0 | vararg: false
-- [Function] System.CheckHeapValid | params: 0 | vararg: false
-- [Function] System.GetNearestEntityByName | params: 0 | vararg: false
-- [Function] System.GetFrameID | params: 0 | vararg: false
-- [Function] System.LogAlways | params: 0 | vararg: false
-- [Function] System.GetCurrAsyncTime | params: 0 | vararg: false
-- [Function] System.GetSurfaceTypeNameById | params: 0 | vararg: false
-- [Function] System.SetCVar | params: 0 | vararg: false
-- [Function] System.Log | params: 0 | vararg: false
-- [Function] System.GetSkyHighlight | params: 0 | vararg: false
-- [Function] System.ActivatePortal | params: 0 | vararg: false
-- [Function] System.GetViewport | params: 0 | vararg: false
-- [Function] System.EnableHeatVision | params: 0 | vararg: false
-- [Function] System.SetBudget | params: 0 | vararg: false
-- [Function] System.GetArchetypeProperties | params: 0 | vararg: false
-- [Function] System.GetEntitiesByClass | params: 0 | vararg: false
-- [Function] System.LoadTextFile | params: 0 | vararg: false
-- [Function] System.LoadLocalizationXml | params: 0 | vararg: false
-- [Function] System.SetSkyHighlight | params: 0 | vararg: false
-- [Function] System.GetLocalOSTime | params: 0 | vararg: false
-- [Function] System.ReturnEntityToPool | params: 0 | vararg: false
-- [Function] System.SetConsoleImage | params: 0 | vararg: false
-- [Function] System.SetVolumetricFogModifiers | params: 0 | vararg: false
-- [Function] System.RayTraceCheck | params: 0 | vararg: false
-- [Function] System.GetEntityPositionAndDirection | params: 0 | vararg: false
-- [Function] System.DumpMemStats | params: 0 | vararg: false
-- [Function] System.ScreenToTexture | params: 0 | vararg: false
-- [Function] System.GetEntityIdByName | params: 0 | vararg: false
-- [Function] System.ViewDistanceGet | params: 0 | vararg: false
-- [Function] System.ApplyForceToEnvironment | params: 0 | vararg: false
-- [Function] System.GetSunColor | params: 0 | vararg: false
-- [Function] System.SetWind | params: 0 | vararg: false
-- [Function] System.GetFrameTime | params: 0 | vararg: false
-- [Function] System.GetEntityByTextGUID | params: 0 | vararg: false
-- [Function] System.DrawText | params: 0 | vararg: false
-- [Function] System.SetSunColor | params: 0 | vararg: false
-- [Function] System.IsEditing | params: 0 | vararg: false
-- [Function] System.GetNearestEntityByClass | params: 0 | vararg: false
-- [Function] System.Quit | params: 0 | vararg: false
-- [Function] System.IsDevModeEnable | params: 0 | vararg: false
-- [Function] System.SetOutdoorAmbientColor | params: 0 | vararg: false
-- [Function] System.RayWorldIntersection | params: 0 | vararg: false
-- [Function] System.GetSystemMem | params: 0 | vararg: false
-- [Function] System.EnumAAFormats | params: 0 | vararg: false
-- [Function] System.GetViewCameraAngles | params: 0 | vararg: false
-- [Function] System.GetViewCameraUpDir | params: 0 | vararg: false
-- [Function] System.GetViewCameraPos | params: 0 | vararg: false
-- [Function] System.GetViewCameraDir | params: 0 | vararg: false
-- [Function] System.LogToConsole | params: 0 | vararg: false
-- [Function] System.IsPointVisible | params: 0 | vararg: false
-- [Function] System.DeformTerrain | params: 0 | vararg: false
-- [Function] System.DumpWinHeaps | params: 0 | vararg: false
-- [Function] System.GetViewCameraFov | params: 0 | vararg: false
-- [Function] System.IsValidMapPos | params: 0 | vararg: false
-- [Function] System.Break | params: 0 | vararg: false
-- [Function] System.QuitInNSeconds | params: 0 | vararg: false
-- [Function] System.DeformTerrainUsingMat | params: 0 | vararg: false
-- [Function] System.ApplicationTest | params: 0 | vararg: false
-- [Function] System.SetPostProcessFxParam | params: 0 | vararg: false
-- [Function] System.GetEntityByName | params: 0 | vararg: false
-- [Function] System.ProjectToScreen | params: 0 | vararg: false
-- [Function] System.SetSkyColor | params: 0 | vararg: false
-- [Function] System.RemoveEntity | params: 0 | vararg: false
-- [Function] System.EnumDisplayFormats | params: 0 | vararg: false
-- [Function] System.GetEntitiesInSphere | params: 0 | vararg: false
-- [Function] System.PrepareEntityFromPool | params: 0 | vararg: false
-- [Function] System.Error | params: 0 | vararg: false
-- [Function] System.IsMultiplayer | params: 0 | vararg: false
-- [Function] System.GetEntities | params: 0 | vararg: false
-- [Function] System.ClearConsole | params: 0 | vararg: false
-- [Function] System.BrowseURL | params: 0 | vararg: false
-- [Function] System.GetEntitiesInSphereByClass | params: 0 | vararg: false
-- [Function] System.SetScissor | params: 0 | vararg: false
-- [Function] System.IsFileExist | params: 0 | vararg: false
-- [Function] System.ScanDirectory | params: 0 | vararg: false
-- [Function] System.DumpMMStats | params: 0 | vararg: false
-- [Function] System.SetViewCameraFov | params: 0 | vararg: false
-- [Function] System.SetWaterVolumeOffset | params: 0 | vararg: false
-- [Function] System.ActivateLight | params: 0 | vararg: false
-- [Function] System.GetPhysicalEntitiesInBox | params: 0 | vararg: false
-- [Function] System.ClearKeyState | params: 0 | vararg: false
-- [Function] System.GetSkyColor | params: 0 | vararg: false
-- [Function] System.GetSurfaceTypeIdByName | params: 0 | vararg: false
-- [Function] System.GetWind | params: 0 | vararg: false
-- [Function] System.IsPointIndoors | params: 0 | vararg: false
-- [Function] System.GetEntityClass | params: 0 | vararg: false
-- [Function] System.IsEditor | params: 0 | vararg: false
-- [Function] System.DebugStats | params: 0 | vararg: false
-- [Function] System.GetOutdoorAmbientColor | params: 0 | vararg: false
-- [Function] System.GetPostProcessFxParam | params: 0 | vararg: false
-- [Function] System.EnableOceanRendering | params: 0 | vararg: false
-- [Function] System.GetTerrainElevation | params: 0 | vararg: false
-- [Function] System.GetCVar | params: 0 | vararg: false
-- [Function] System.ExecuteCommand | params: 0 | vararg: false
-- [Function] System.GetScreenFx | params: 0 | vararg: false
-- [Function] System.GetConfigSpec | params: 0 | vararg: false
-- [Function] System.DumpMemoryCoverage | params: 0 | vararg: false
-- [Function] System.SetGammaDelta | params: 0 | vararg: false
-- [Function] System.GetUserName | params: 0 | vararg: false
-- [Function] System.IsHDRSupported | params: 0 | vararg: false