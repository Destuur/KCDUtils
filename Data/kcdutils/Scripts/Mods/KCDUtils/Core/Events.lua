KCDUtils = KCDUtils or {}
--- @class KCDUtilsEvents
KCDUtils.Events = KCDUtils.Events or {}
KCDUtils.Events.updaters = KCDUtils.Events.updaters or {}
KCDUtils.Events._OnUsedHooks = KCDUtils.Events._OnUsedHooks or {}
KCDUtils.Events._MethodHooks = KCDUtils.Events._MethodHooks or {}
KCDUtils.Events.watchLoopRunning = KCDUtils.Events.watchLoopRunning or false
KCDUtils.Events.availableEvents = {}

--- Registers an event that fires when <globalName>.<methodName> is called
--- @param globalName string  e.g. "Horse"
--- @param methodName string  e.g. "OnButcher"
--- @param eventName  string  e.g. "ButcherStarted" (listeners attach via mod.On.ButcherStarted = function(ev) end)
--- @param opts table? { phase="before"|"after"|"both" (def "before"), retryMs=500, maxAttempts=120 }
function KCDUtils.Events.RegisterMethodEvent(globalName, methodName, eventName, opts)
  opts = opts or {}
  local phase       = opts.phase or "before"
  local retryMs     = tonumber(opts.retryMs) or 500
  local maxAttempts = tonumber(opts.maxAttempts) or 120

  local evt = KCDUtils.Events.CreateEvent(eventName)
  KCDUtils.Events.RegisterEvent(eventName, KCDUtils.Name,
    ("Fires when %s.%s is called"):format(globalName, methodName),
    {"table","user","slot","name","method","args"})

  local storeKey = ("%s.%s"):format(globalName, methodName)
  local store = KCDUtils.Events._MethodHooks
  if store[storeKey] and store[storeKey].hooked then
    return evt
  end
  store[storeKey] = store[storeKey] or { attempts = 0, hooked = false }

  local logger = KCDUtils.Logger.Factory("KCDUtils.Events."..methodName)
  local function tryHook()
    local s = store[storeKey]; s.attempts = s.attempts + 1
    local t = _G[globalName]
    local fn = t and t[methodName]

    if t and type(fn) == "function" and not t["_orig_"..methodName] then
      local orig = fn
      t["_orig_"..methodName] = orig

      t[methodName] = function(self, user, ...)
        if phase == "before" or phase == "both" then
          evt.Trigger({ table=self, user=user, slot=nil, name=globalName, method=methodName, args={...} })
        end

        local result = orig(self, user, ...)
        if phase == "after" or phase == "both" then
          evt.Trigger({ table=self, user=user, slot=nil, name=globalName, method=methodName, args={...}, result=result })
        end
        return result
      end

      s.hooked = true
      logger:Info(("Hooked %s.%s (%s)"):format(globalName, methodName, phase))
      return
    end

    if s.attempts < maxAttempts then
      Script.SetTimer(retryMs, tryHook)
    else
      logger:Error(("Failed to hook %s.%s after %d attempts"):format(globalName, methodName, maxAttempts))
    end
  end

  tryHook()
  return evt
end

--- Scannt _G und hookt alle Tabellen mit OnButcher; feuert EIN gemeinsames Event.
--- @param eventName string e.g. "ButcherStarted"
--- @param opts table? same opts; phase default "before"
function KCDUtils.Events.RegisterAnyOnButcherEvent(eventName, opts)
  opts = opts or {}
  local phase   = (opts.phase or "after"):lower()
  local retryMs = tonumber(opts.retryMs) or 500
  local logger  = KCDUtils.Logger.Factory("KCDUtils.Events.AnyOnButcher")

  local evt = KCDUtils.Events.CreateEvent(eventName)
  KCDUtils.Events.RegisterEvent(
    eventName, KCDUtils.Name,
    "Fires when BasicAnimal.OnButcher / <subclass>.OnButcher is called",
    {"class","entity","user","method"}
  )

  local classes = {
    "BasicAnimal","Horse","InventoryDummyHorse","WildDog","Raven","Pig","SheepEwe",
    "RedDeerDoe","RedDeerStag","RoeDeerHind","RoeDeerBuck","Hare","InventoryDummyDog",
    "Wolf","Hen","SheepRam","Dog","CattleCow","CattleBull","Boar",
  }

  local function wrapMethod(tbl, methodName, hookedClassName)
    local fn = rawget(tbl, methodName)
    if type(fn) ~= "function" then return false end
    if tbl["_orig_"..methodName] then return false end

    local orig = fn
    tbl["_orig_"..methodName] = orig

    tbl[methodName] = function(self, user, ...)
        local realClass =
            (self and self.class)
            or (self and self.GetName and self:GetName())
            or hookedClassName
            or "Unknown"

        if phase == "before" or phase == "both" then
        evt.Trigger({ class = realClass, entity = self, user = user, method = methodName })
        end

        local ok, res = pcall(orig, self, user, ...)
        if not ok then
        logger:Error(("OnButcher %s crashed: %s"):format(tostring(realClass), tostring(res)))
        end

        if phase == "after" or phase == "both" then
        if not self.__kcdutils_butcherFired then
            self.__kcdutils_butcherFired = true
            evt.Trigger({ class = realClass, entity = self, user = user, method = methodName })
            Script.SetTimer(1500, function()
            if self then self.__kcdutils_butcherFired = nil end
            end)
        end
        end
        return res
    end

    logger:Info(("Hooked %s.%s"):format(hookedClassName or "?", methodName))
    return true
    end

  local consecutiveNoNew = 0
  local function tryHookCore()
    local newCount = 0
    local BA = _G.BasicAnimal
    if BA then
      if wrapMethod(BA, "OnButcher", "BasicAnimal") then newCount = newCount + 1 end
    end
    for _, name in ipairs(classes) do
      local t = _G[name]
      if t then
        if wrapMethod(t, "OnButcher", name) then newCount = newCount + 1 end
      end
    end

    if newCount == 0 then consecutiveNoNew = consecutiveNoNew + 1 else consecutiveNoNew = 0 end
    if consecutiveNoNew < 10 then Script.SetTimer(retryMs, tryHookCore) end
  end

  tryHookCore()
  return evt
end

--- Registers an event, that gets triggered, when <globalName>.OnUsed gets called
--- @param globalName string  (z.B. "Smithery", "AlchemyTable")
--- @param eventName  string  (z.B. "SmitheryStarted", "AlchemyStarted")
--- @param opts       table?  { phase = "before"|"after" (default "before"), retryMs=500, maxAttempts=120 }
function KCDUtils.Events.RegisterOnUsedEvent(globalName, eventName, opts)
    opts = opts or {}
    local phase       = opts.phase or "before"
    local retryMs     = tonumber(opts.retryMs) or 500
    local maxAttempts = tonumber(opts.maxAttempts) or 120

    local evt = KCDUtils.Events.CreateEvent(eventName)
    KCDUtils.Events.RegisterEvent(eventName, KCDUtils.Name, "Fires when "..globalName..".OnUsed is called", {"table","user","slot","name"})

    local store = KCDUtils.Events._OnUsedHooks
    if store[globalName] and store[globalName].hooked then
        return evt
    end
    store[globalName] = store[globalName] or { attempts = 0, hooked = false }

    local logger = KCDUtils.Logger.Factory("KCDUtils.Events.OnUsed")
    local function tryHook()
        local s = store[globalName]
        s.attempts = s.attempts + 1

        local t = _G[globalName]
        if t and type(t.OnUsed) == "function" and not t._orig_OnUsed then
            local orig = t.OnUsed
            t._orig_OnUsed = orig
            t.OnUsed = function(self, user, slot)
                if phase == "before" then
                    evt.Trigger({ table=self, user=user, slot=slot, name=globalName })
                end
                local result = orig(self, user, slot)
                if phase == "after" then
                    evt.Trigger({ table=self, user=user, slot=slot, name=globalName })
                end
                return result
            end
            s.hooked = true
            logger:Info(("Hooked %s.OnUsed (%s)"):format(globalName, phase))
            return
        end

        if s.attempts < maxAttempts then
            Script.SetTimer(retryMs, tryHook)
        else
            logger:Error(("Failed to hook %s.OnUsed after %d attempts"):format(globalName, maxAttempts))
        end
    end

    tryHook()
    return evt
end

--- Creates a new custom event or returns an existing one
--- @param eventName string Name of the event
--- @return table evt Event object with Add, Remove, Pause, Resume, Trigger methods
local function CreateEvent(eventName)
    local evt = KCDUtils.Events[eventName] or {}
    KCDUtils.Events[eventName] = evt

    evt.listeners = evt.listeners or {}
    evt.isUpdaterRegistered = evt.isUpdaterRegistered or false
    evt.updaterFn = evt.updaterFn or nil

    --- Add a new listener to the event
    --- @param config table Optional event-specific configuration
    --- @param callback fun(data:table) Function to be called when event fires
    --- @return table|nil subscription Subscription handle (pass to Remove, Pause, Resume)
    function evt.Add(config, callback)
        config = config or {}

        -- Prüfen, ob Callback eine Funktion ist
        if type(callback) ~= "function" then
            local logger = KCDUtils.Logger.Factory("KCDUtils.Events." .. (eventName or "Unknown"))
            logger:Error("Add: callback must be a function, got: " .. tostring(callback))
            return nil
        end

        -- Doppelten Callback entfernen (optional)
        for i = #evt.listeners, 1, -1 do
            if evt.listeners[i].callback == callback then
                table.remove(evt.listeners, i)
            end
        end

        local subscription = { callback = callback, config = config, isPaused = false }
        table.insert(evt.listeners, subscription)

        -- Optional: Start updater, falls vorhanden
        if not evt.isUpdaterRegistered and evt.startUpdater then
            evt.startUpdater()
            evt.isUpdaterRegistered = true
        end

        return subscription
    end

    --- Remove a previously registered listener
    --- @param subscription table Subscription object returned from Add
    function evt.Remove(subscription)
        for i = #evt.listeners, 1, -1 do
            if evt.listeners[i] == subscription then
                table.remove(evt.listeners, i)
                break
            end
        end
        if #evt.listeners == 0 and evt.isUpdaterRegistered then
            if evt.updaterFn then KCDUtils.Events.UnregisterUpdater(evt.updaterFn) end
            evt.isUpdaterRegistered = false
        end
    end

    --- Temporarily pause a subscription without removing it
    --- @param subscription table Subscription object returned from Add
    function evt.Pause(subscription) if subscription then subscription.isPaused = true end end

    --- Resume a paused subscription
    --- @param subscription table Subscription object returned from Add
    function evt.Resume(subscription) if subscription then subscription.isPaused = false end end

    --- Fire/trigger the event manually
    --- @param data table Optional data passed to all listeners
    function evt.Trigger(data)
        for _, subscription in ipairs(evt.listeners) do
            if not subscription.isPaused then subscription.callback(data or {}) end
        end
    end

    return evt
end

--- Utility to subscribe a method as listener to a system event
--- @param target table Object that contains the callback method
--- @param methodName string Name of the method on the target
--- @param eventName string|nil Name of the system event (default = methodName)
function KCDUtils.Events.SubscribeSystemEvent(target, methodName, eventName)
    local name = target.Name or ("Table@" .. tostring(target))
    local logger = KCDUtils.Logger.Factory(name)
    eventName = eventName or methodName
    if not target[methodName] or type(target[methodName]) ~= "function" then
        logger:Error("Target does not have a method named '" .. methodName .. "'")
        return
    end
    UIAction.RegisterEventSystemListener(target, "System", eventName, methodName)
    logger:Info("Subscribed " .. tostring(methodName) .. " to system event '" .. eventName .. "'")
end

--- Utility to subscribe a method as listener to the OnGameplayStarted event
--- 
--- ### Callback method must have the signature:
--- ```lua
--- function MyMod.OnGameplayStarted(actionName, eventName, argTable) -- parameters optional
---     -- handle event
--- end
--- ```
--- 
--- @param target table Object that contains the callback method "OnGameplayStarted"
function KCDUtils.Events.RegisterOnGameplayStarted(target)
    KCDUtils.Events.SubscribeSystemEvent(target, "OnGameplayStarted")
end

--- Registers a function to be called on every watch loop tick
--- @param fn function Function to be registered
function KCDUtils.Events.RegisterUpdater(fn)
    if type(fn) ~= "function" then return end
    table.insert(KCDUtils.Events.updaters, fn)
end

--- Removes a previously registered updater function from the watch loop
--- @param fn function Function previously registered via RegisterUpdater
function KCDUtils.Events.UnregisterUpdater(fn)
    for i = #KCDUtils.Events.updaters, 1, -1 do
        if KCDUtils.Events.updaters[i] == fn then
            table.remove(KCDUtils.Events.updaters, i)
            break
        end
    end
end

--- Starts the global event watch loop that periodically calls all registered updaters
function KCDUtils.Events.WatchLoop()
    if KCDUtils.Events.watchLoopRunning then return end
    KCDUtils.Events.watchLoopRunning = true

    local function loop()
        for _, fn in ipairs(KCDUtils.Events.updaters) do
            pcall(fn, 1/60)
        end
        Script.SetTimer(16, loop)
    end

    loop()
end

--- Registers event metadata for documentation/debug purposes
--- @param eventName string Name of the event
--- @param modName string Name of the mod registering the event
--- @param description string Optional description
--- @param paramList table Optional list of parameters for documentation
function KCDUtils.Events.RegisterEvent(eventName, modName, description, paramList)
    KCDUtils.Events.availableEvents[eventName] = KCDUtils.Events.availableEvents[eventName] or {}
    table.insert(KCDUtils.Events.availableEvents[eventName], {
        modName = modName,
        description = description or "",
        params = paramList or {}
    })
end

--- Lists all available events and their registered mods in the system log
function KCDUtils.Events.ListEvents()
    for eventName, mods in pairs(KCDUtils.Events.availableEvents) do
        System.LogAlways("Event: " .. eventName)
    end
end

KCDUtils.Events.CreateEvent = CreateEvent
KCDUtils.Events.WatchLoop()