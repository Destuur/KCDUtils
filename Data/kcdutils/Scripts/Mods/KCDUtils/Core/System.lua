KCDUtils = KCDUtils or {}
--- @class KCDUtils.System
KCDUtils.System = KCDUtils.System or {}

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
    local player = KCDUtils.System.GetEntityByName("dude") or KCDUtils.System.GetEntityByName("Player")
    if not player then
        logger:Warn("Player entity not found.")
    end
    return player
end

function KCDUtils.System.GetEntityByGUID(guid)
    local logger = KCDUtils.Logger.Factory("System")
    local entity = System.GetEntityByGUID(guid)
    if not entity then
        logger:Warn("Entity with GUID '" .. tostring(guid) .. "' not found.")
    end
    return entity
end

function KCDUtils.System.GetEntity(entityId)
    local logger = KCDUtils.Logger.Factory("System")
    local entity = System.GetEntity(entityId)
    if not entity then
        logger:Warn("Entity with ID '" .. tostring(entityId) .. "' not found.")
    end
    return entity
end

--- Zeichnet ein Label im 3D-Raum
---@param vPos table {x,y,z} - Weltposition
---@param fSize number - Textgröße
---@param text string - Inhalt
---@param r number|nil - Rot (0-1), default 1
---@param g number|nil - Grün (0-1), default 1
---@param b number|nil - Blau (0-1), default 1
---@param alpha number|nil - Alpha (0-1), default 1
function KCDUtils.System.DrawLabel(vPos, fSize, text, r, g, b, alpha)
    r = r or 1
    g = g or 1
    b = b or 1
    alpha = alpha or 1

    -- Engine-Funktion aufrufen
    System.DrawLabel(vPos, fSize, text, r, g, b, alpha)
end

function KCDUtils.System.GetPhysicalEntitiesInBoxByClass(center, radius, className)
    local logger = KCDUtils.Logger.Factory("System")
    local entities = System.GetPhysicalEntitiesInBoxByClass(center, radius, className)
    if not entities or #entities == 0 then
        logger:Warn("No physical entities found in box for class '" .. tostring(className) .. "'.")
    end
    return entities
end

function KCDUtils.System.AddCCommand(commandName, callbackName, description)
    local logger = KCDUtils.Logger.Factory("System")
    if type(commandName) ~= "string" then
        logger:Error("Command name must be a string")
        return
    end
    if type(callbackName) ~= "string" then
        logger:Error("Callback name must be a string")
        return
    end
    System.AddCCommand(commandName, callbackName, description or "No description provided")
end

function KCDUtils.System.GetCurrTime()
    return System.GetCurrTime()
end

function KCDUtils.System.GetCurrAsyncTime()
    return System.GetCurrAsyncTime()
end

function KCDUtils.System.GetNearestEntityByName(entityName)
    local logger = KCDUtils.Logger.Factory("System")
    local entity = System.GetNearestEntityByName(entityName)
    if not entity then
        logger:Warn("Entity with name '" .. tostring(entityName) .. "' not found.")
    end
    return entity
end

--- Gets all entities within a sphere.
--- @param centre table Vector {x, y, z} as sphere center
--- @param radius number Radius of the sphere
--- @param class string (optional) Filter by entity class
--- @return table Array of entities found in the sphere
function KCDUtils.System.GetEntitiesInSphere(centre, radius, class)
    local entities = {}
    if class then
        entities = System.GetEntitiesInSphere(centre, radius, class)
    else
        entities = System.GetEntitiesInSphere(centre, radius)
    end
    return entities
end

function KCDUtils.System.SetCVar(cvarName, value)
    local logger = KCDUtils.Logger.Factory("System")
    if type(cvarName) ~= "string" then
        logger:Error("CVar name must be a string")
        return
    end
    if type(value) ~= "string" and type(value) ~= "number" and type(value) ~= "boolean" then
        logger:Error("CVar value must be a string, number, or boolean")
        return
    end
    KCDUtils.SafeCall(System, "SetCVar", false, cvarName, value)
end

--- Retrieves current sky highlight parameters.
--- @return table Sky highlight parameters (size, color, direction, pod)
function KCDUtils.System.GetSkyHighlight()
    local params = {}
    System.GetSkyHighlight(params)
    return params
end

--- Sets sky highlight parameters.
--- @param size number Scale of the sky highlight
--- @param color table Table with {r, g, b, a}
--- @param direction table Direction vector {x, y, z}
--- @param pod table Position vector {x, y, z}
function KCDUtils.System.SetSkyHighlight(size, color, direction, pod)
    local params = {
        size = size or 1.0,
        color = color or {1, 1, 1, 1},
        direction = direction or {x = 0, y = 0, z = 1},
        pod = pod or {x = 0, y = 0, z = 0}
    }

    System.SetSkyHighlight(params)
end

function KCDUtils.System.GetSurfaceTypeNameById(surfaceId)
    local logger = KCDUtils.Logger.Factory("System")
    local surfaceName = System.GetSurfaceTypeNameById(surfaceId)
    if not surfaceName then
        logger:Warn("Surface with ID '" .. tostring(surfaceId) .. "' not found.")
    end
    return surfaceName
end

function KCDUtils.System.GetEntityIdByName(entityName)
    local logger = KCDUtils.Logger.Factory("System")
    local entityId = System.GetEntityIdByName(entityName)
    if not entityId then
        logger:Warn("Entity with name '" .. tostring(entityName) .. "' not found.")
    end
    return entityId
end

--- Retrieves the current sun color as an RGB vector.
--- @return table sunColor The sun color as a table {x = r, y = g, z = b}.
function KCDUtils.System.GetSunColor()
    local logger = KCDUtils.Logger.Factory("System")
    local sunColor = System.GetSunColor()
    if not sunColor then
        logger:Warn("Sun color not found.")
    end
    return sunColor
end

--- Sets the global wind direction and strength.
-- @param wind table Vector {x, y, z} defining wind direction and magnitude
function KCDUtils.System.SetWind(wind)
    wind = wind or {x = 0, y = 0, z = 0}
    System.SetWind(wind)
end

--- Gets the value of a console variable (CVar).
-- @param name string The name of the CVar
-- @return number|string|nil The current value of the CVar (depends on type), or nil if not found
function KCDUtils.System.GetCVar(name)
    if not name then
        System.LogAlways("[KCDUtils] GetCVar: missing name parameter")
        return nil
    end
    return System.GetCVar(name)
end

-- [Function] System.ViewDistanceSet | params: 0 | vararg: false
-- [Function] System.LoadFont | params: 0 | vararg: false
-- [Function] System.SetScreenFx | params: 0 | vararg: false
-- [Function] System.SpawnEntity | params: 0 | vararg: false
-- [Function] System.ShowDebugger | params: 0 | vararg: false
-- [Function] System.EnableMainView | params: 0 | vararg: false
-- [Function] System.ShowConsole | params: 0 | vararg: false
-- [Function] System.Warning | params: 0 | vararg: false
-- [Function] System.DrawLine | params: 0 | vararg: false
-- [Function] System.Draw2DLine | params: 0 | vararg: false
-- [Function] System.CreateDownload | params: 0 | vararg: false
-- [Function] System.ResetPoolEntity | params: 0 | vararg: false
-- [Function] System.CheckHeapValid | params: 0 | vararg: false
-- [Function] System.GetFrameID | params: 0 | vararg: false
-- [Function] System.LogAlways | params: 0 | vararg: false
-- [Function] System.Log | params: 0 | vararg: false
-- [Function] System.ActivatePortal | params: 0 | vararg: false
-- [Function] System.GetViewport | params: 0 | vararg: false
-- [Function] System.EnableHeatVision | params: 0 | vararg: false
-- [Function] System.SetBudget | params: 0 | vararg: false
-- [Function] System.GetArchetypeProperties | params: 0 | vararg: false
-- [Function] System.GetEntitiesByClass | params: 0 | vararg: false
-- [Function] System.LoadTextFile | params: 0 | vararg: false
-- [Function] System.LoadLocalizationXml | params: 0 | vararg: false
-- [Function] System.GetLocalOSTime | params: 0 | vararg: false
-- [Function] System.ReturnEntityToPool | params: 0 | vararg: false
-- [Function] System.SetConsoleImage | params: 0 | vararg: false
-- [Function] System.SetVolumetricFogModifiers | params: 0 | vararg: false
-- [Function] System.RayTraceCheck | params: 0 | vararg: false
-- [Function] System.GetEntityPositionAndDirection | params: 0 | vararg: false
-- [Function] System.DumpMemStats | params: 0 | vararg: false
-- [Function] System.ScreenToTexture | params: 0 | vararg: false
-- [Function] System.ViewDistanceGet | params: 0 | vararg: false
-- [Function] System.ApplyForceToEnvironment | params: 0 | vararg: false
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
-- [Function] System.ProjectToScreen | params: 0 | vararg: false
-- [Function] System.SetSkyColor | params: 0 | vararg: false
-- [Function] System.RemoveEntity | params: 0 | vararg: false
-- [Function] System.EnumDisplayFormats | params: 0 | vararg: false
-- [Function] System.PrepareEntityFromPool | params: 0 | vararg: false
-- [Function] System.Error | params: 0 | vararg: false
-- [Function] System.IsMultiplayer | params: 0 | vararg: false
-- [Function] System.GetEntities | params: 0 | vararg: false
-- [Function] System.ClearConsole | params: 0 | vararg: false
-- [Function] System.BrowseURL | params: 0 | vararg: false
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
-- [Function] System.GetScreenFx | params: 0 | vararg: false
-- [Function] System.GetConfigSpec | params: 0 | vararg: false
-- [Function] System.DumpMemoryCoverage | params: 0 | vararg: false
-- [Function] System.SetGammaDelta | params: 0 | vararg: false
-- [Function] System.GetUserName | params: 0 | vararg: false
-- [Function] System.IsHDRSupported | params: 0 | vararg: false