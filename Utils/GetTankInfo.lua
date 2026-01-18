-- GetTankInfo Utility
-- Helper to identify the simulated tank in the party.

ScriptExtender_Register("GetTankInfo", "Dev Tool: Returns the identified Tank name and UnitID.")
function GetTankInfo()
    local units = {"player", "party1", "party2", "party3", "party4"}
    
    -- "Instant Win" Buffs
    local tankBuffs = {"DefensiveStance", "BearForm", "SealOfFury"}

    -- Defaults (Fallback to player if everyone is naked/dead)
    local bestName = UnitName("player")
    local bestID = "player"
    local highestHP = 0

    for _, u in ipairs(units) do
        if UnitExists(u) and UnitIsConnected(u) then
            -- 1. Check for Definitive Tank Buffs
            local i = 1
            while UnitBuff(u, i) do
                local b = UnitBuff(u, i)
                for _, t in ipairs(tankBuffs) do
                    if string.find(b, t) then
                        -- FOUND IT! Return immediately.
                        return UnitName(u), u 
                    end
                end
                i = i + 1
            end

            -- 2. Track Max HP (Fallback for Shaman/Lazy Tanks)
            local hp = UnitHealthMax(u)
            if hp > highestHP then
                highestHP = hp
                bestName = UnitName(u)
                bestID = u
            end
        end
    end

    -- Returns Name ("Thex") and ID ("party2")
    return bestName, bestID
end
