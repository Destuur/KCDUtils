--- @class KCDUtilsSoul
KCDUtils.Soul = KCDUtils and KCDUtils.Soul or {}

--- Cleans the dirt from the specified entity (usually the player).
--- If no entity is provided, logs an error.
--- @param who table The entity to clean (e.g., player)
function KCDUtils.Soul.CleanDirt(who)
    if who then
        who:CleanDirt()
    else
        local logger = KCDUtils.Logger.Factory("KCDUtils.Soul")
        logger:Error("No valid player entity provided to CleanDirt.")
    end
end