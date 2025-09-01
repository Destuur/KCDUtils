KCDUtils = KCDUtils or {}
KCDUtils.Core = KCDUtils.Core or {}

KCDUtils.Core.Logger = KCDUtils.Core.Logger or {}
local cache = {}

---Factory for creating/retrieving a Logger instance for a given mod.
---
---```lua
--- local logger = KCDUtils.Core.Logger.Factory("MyMod", { defaultThrottle = true, defaultInterval = 10 })
--- logger:SetCategory("MyCategory", true, true, 10)
--- logger:LogCategory("MyCategory", "This is a log message.")
--- logger:Info("This is an info message.")
--- logger:Warn("This is a warning message.")
--- logger:Error("This is an error message.")
--- ```
---
---@param modName string Unique mod identifier
---@param options table|nil Optional settings: defaultThrottle = boolean, defaultInterval = number
---@return KCDUtilsCoreLogger
function KCDUtils.Core.Logger.Factory(modName, options)
    if cache[modName] then
        return cache[modName]
    end
    cache[modName] = {}
    options = options or {}

    ---@class KCDUtilsCoreLogger
    local instance = {
        Name = modName,
        defaultThrottle = options.defaultThrottle or false,
        defaultInterval = options.defaultInterval or 5,
        categories = {},  -- categoryName -> { enabled = true, throttle = bool, lastLogTime = 0, interval = number }
        queues = {},      -- categoryName -> latest message (nur für throttelte Kategorien)
        colors = {},
        throttleEnabled = true, -- globaler Schalter für Throttle
    }

    --- Adds or configures a log category for this logger instance.
    --- @param category string Name of the category
    --- @param enabled boolean|nil Whether the category is enabled (default: true)
    --- @param throttle boolean|nil Whether to throttle logs for this category (default: defaultThrottle)
    --- @param interval number|nil Minimum interval in seconds between logs for throttled categories (default: defaultInterval)
    function instance:SetCategory(category, enabled, throttle, interval)
        enabled = enabled ~= false   -- default true
        throttle = throttle == nil and instance.defaultThrottle or throttle
        interval = interval or instance.defaultInterval

        instance.categories[category] = {
            enabled = enabled,
            throttle = throttle,
            lastLogTime = 0,
            interval = interval
        }

        if throttle then
            instance.queues[category] = nil
        end
    end

    --- Enables or disables a log category.
    --- @param category string Name of the category
    --- @param enabled boolean Whether the category should be enabled
    function instance:EnableCategory(category, enabled)
        local cat = instance.categories[category]
        if cat then
            cat.enabled = enabled
        end
    end

    --- Sets the log interval for a specific category (for throttling).
    --- @param category string Name of the category
    --- @param interval number Minimum interval in seconds between logs
    function instance:SetInterval(category, interval)
        local cat = instance.categories[category]
        if cat then
            cat.interval = interval
        end
    end

    --- Adds a message to the queue or logs it immediately, depending on category settings.
    --- For throttled categories, only the latest message is kept until the interval passes.
    --- @param category string Name of the category
    --- @param message string The message to log
    function instance:LogCategory(category, message)
        local cat = instance.categories[category]
        if not cat or not cat.enabled then return end

        local color = instance.colors[category] or "$1"
        if self.throttleEnabled and cat.throttle then
            if not self.queues[category] then
                -- neuer Eintrag
                self.queues[category] = { message = message, color = color }
            else
                -- nur Nachricht aktualisieren, Zeit bleibt gleich
                self.queues[category].message = message
            end
        else
            System.LogAlways("$8[" .. self.Name .. "]" .. color .. "[" .. category .. "] $1" .. message)
        end
    end

    --- Timer loop for processing throttled log categories.
    function instance:ProcessQueue()
        if not self.throttleEnabled then return end -- global ausgeschaltet -> nichts tun

        local now = System.GetCurrTime()
        for category, entry in pairs(self.queues) do
            local cat = self.categories[category]
            if entry and now - cat.lastLogTime >= cat.interval then
                System.LogAlways("$8[" .. self.Name .. "]" .. entry.color .. "[" .. category .. "] $1" .. entry.message)
                cat.lastLogTime = now
                self.queues[category] = nil
            end
        end
    end

    function instance:OnGameplayStarted()
        if not self.defaultThrottle then return end
        self:StartThrottleLoop()
    end

    --- Startet den Throttle-Loop (rekursiver Timer)
    function instance:StartThrottleLoop()
        System.LogAlways("Logger [" .. self.Name .. "]: Throttle loop started")
        local function loop()
            if not self.throttleEnabled then return end -- sofort stoppen, falls deaktiviert
            self:ProcessQueue()
            Script.SetTimer(1000, loop)
        end
        Script.SetTimer(1000, loop)
    end

    --- Globale Steuerung: Throttle aktivieren
    function instance:EnableThrottle()
        if self.throttleEnabled then return end
        self.throttleEnabled = true
        self:StartThrottleLoop()
        System.LogAlways("Logger [" .. self.Name .. "]: Throttle enabled")
    end

    --- Globale Steuerung: Throttle deaktivieren
    function instance:DisableThrottle()
        if not self.throttleEnabled then return end
        self.throttleEnabled = false
        System.LogAlways("Logger [" .. self.Name .. "]: Throttle disabled")
    end

    --- Logs a general message (non-categorized).
    ---
    --- Output:
    --- ```cs
    --- [ModName] This is your message
    --- ```
    ---
    --- @param message string The message to log
    function instance:Log(message)   instance:LogCategory("General", message) end

    --- Logs an info message.
    ---
    --- Output:
    --- ```cs
    --- [ModName][Info] This is your info message
    --- ```
    ---
    --- @param message string The message to log
    function instance:Info(message)  instance:LogCategory("Info", message)    end

    --- Logs a warning message.
    ---
    --- Output:
    --- ```cs
    --- [ModName][Warn] This is your warning message
    --- ```
    ---
    --- @param message string The message to log
    function instance:Warn(message)  instance:LogCategory("Warn", message)    end

    --- Logs an error message.
    ---
    --- Output:
    --- ```cs
    --- [ModName][Error] This is your error message
    --- ```
    ---
    --- @param message string The message to log
    function instance:Error(message) instance:LogCategory("Error", message)   end

    -- Default categories: enabled by default
    instance:SetCategory("General", true)
    instance:SetCategory("Info", true)
    instance:SetCategory("Warn", true)
    instance:SetCategory("Error", true)

    instance.colors = {
        General = "$1", -- Standardfarbe
        Info    = "$3", -- Blau/Info
        Warn    = "$6", -- Gelb/Warnung
        Error   = "$4", -- Rot/Error
    }

    cache[modName] = instance
    return instance
end