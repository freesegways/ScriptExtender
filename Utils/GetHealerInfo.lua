-- GetHealerInfo Utility
-- Helper to identify the simulated healer in the party.

ScriptExtender_Register("GetHealerInfo", "Dev Tool: Returns the identified Healer name and UnitID.")
function GetHealerInfo()
    local units = {"player", "party1", "party2", "party3", "party4"}
    
    -- Classes capable of healing
    local validClasses = {
        ["PRIEST"] = true, 
        ["SHAMAN"] = true, 
        ["DRUID"] = true, 
        ["PALADIN"] = true
    }
    
    -- Buffs that PROVE they are NOT a healer
    local dpsBuffs = {
        "Shadowform",                -- Shadow Priest
        "Spell_Nature_ForceOfNature" -- Moonkin
    }

    local bestName = UnitName("player")
    local bestID = "player"
    local highestMana = 0

    for _, u in ipairs(units) do
        if UnitExists(u) and UnitIsConnected(u) then
            local _, class = UnitClass(u)
            
            -- 1. Must be a Healing Class AND use Mana (filters out Bear/Cat Druids)
            if validClasses[class] and UnitPowerType(u) == 0 then
                
                -- 2. Check for DPS Forms (Shadow/Moonkin)
                local isDPS = false
                local i = 1
                while UnitBuff(u, i) do
                    local b = UnitBuff(u, i)
                    for _, t in ipairs(dpsBuffs) do
                        if string.find(b, t) then isDPS = true break end
                    end
                    if isDPS then break end
                    i = i + 1
                end
                
                -- 3. Compare Mana Max (Healers stack Int, Ele/Enhance/Ret usually have less)
                if not isDPS then
                    local mana = UnitManaMax(u)
                    if mana > highestMana then
                        highestMana = mana
                        bestName = UnitName(u)
                        bestID = u
                    end
                end
            end
        end
    end

    return bestName, bestID
end
