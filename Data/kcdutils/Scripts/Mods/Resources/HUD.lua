KCDUtils = KCDUtils or {}
KCDUtils.Resources = KCDUtils.Resources or {}

---@class KCDUtilsHUD
-- Defines the header for discovered Points of Interest (POI) UI element
KCDUtils.Resources.HUD = {
    --- @class KCDUtilsDiscoveredPoiType
    --- | 0 # No Header
    --- | 1 # Learned
    --- | 2 # Discovered
    DiscoveredPoi = {
        None = 0,
        Learned = 1,
        Discovered = 2
    },

    --- @class KCDUtilsDiscoveredLocationType
    --- | 0 # Small, Top Right
    --- | 1 # Large, Center
    DiscoveredLocationHeader = {
        Small = 0,
        Large = 1,
    },

    
    --- @class KCDUtilsCrimeState
    --- | 0 # Nothing
    --- | 1 # Searching Bunny
    --- | 2 # Trumpet Bunny
    --- | 3 # Investigating Bunny
    --- | 4 # Ears Down Bunny
    --- | 5 # Ears Down Walking Bunny
    --- | 6 # Get Out Bunny
    --- | 7 # Halt Bunny
    --- | 8 # Attacking Bunny
    --- | 9 # Fighting Bunny
    --- | 10 # Alarming Bunny
    CrimeState = {
        Nothing = 0,
        SearchingBunny = 1,
        TrumpetBunny = 2,
        InvestigatingBunny = 3,
        EarsDownBunny = 4,
        EarsDownWalkingBunny = 5,
        GetOutBunny = 6,
        HaltBunny = 7,
        AttackingBunny = 8,
        FightingBunny = 9,
        AlarmingBunny = 10,
    },

    --- @class KCDUtilsTrespassState
    --- Icon appears only for a few seconds and cant be reactivated for some time. For more appearances, reactivate trespassing with another value. Everything from 4 and above will be treated as a new trespassing state.
    --- 
    --- | 0 # Nothing
    --- | 1 # Trespassing - Red Icon
    --- | 2 # Trespassing - Red Icon
    --- | 3 # Private Area - Blue Icon (First) + Blue Trespassing Icon right of compass
    --- | 4 # Trespassing - Red Icon
    TrespassState = {
        Nothing = 0,
        TrespassingRedShortFirst = 1,
        TrespassingRedShortSecond = 2,
        PrivateAreaBlue = 3,
        TrespassingRedShortNoCooldown = 4,
    },

    --- @class KCDUtilsWantedState
    --- | 0 # Not Wanted
    --- | 1 # Wanted
    WantedState = {
        NotWanted = 0,
        Wanted = 1
    }
}