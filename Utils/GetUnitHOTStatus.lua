-- GetUnitHOTStatus Utility
-- Scans a unit for Renew, Power Word: Shield, and Weakened Soul status.

function GetUnitHOTStatus(u)
    local status = { renew = false, shield = false, weakened = false }
    
    if not UnitExists(u) then return status end

    -- 1. SCAN BUFFS (Check for Renew or existing Shield)
    local i = 1
    while UnitBuff(u, i) do
        local texture = UnitBuff(u, i)
        if string.find(texture, "Spell_Holy_Renew") then
            status.renew = true
        elseif string.find(texture, "PowerWordShield") then
            status.shield = true
        end
        i = i + 1
    end

    -- 2. SCAN DEBUFFS (Check for Weakened Soul)
    -- Texture is usually 'Spell_Shadow_GatherShadows'
    i = 1
    while UnitDebuff(u, i) do
        local texture = UnitDebuff(u, i)
        if string.find(texture, "GatherShadows") then
            status.weakened = true
        end
        i = i + 1
    end

    return status
end
