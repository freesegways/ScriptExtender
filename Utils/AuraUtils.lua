-- Utils/AuraUtils.lua
-- Utility functions for checking Buffs and Debuffs by texture pattern.

function ScriptExtender_HasBuff(unit, texturePattern)
    -- UnitBuff returns texture path in vanilla 1.12
    for i = 1, 32 do
        local b = UnitBuff(unit, i)
        if not b then break end
        if string.find(b, texturePattern) then
            return true, i
        end
    end
    return false, nil
end

function ScriptExtender_HasDebuff(unit, texturePattern)
    -- UnitDebuff returns texture path in vanilla 1.12
    for i = 1, 16 do
        local d = UnitDebuff(unit, i)
        if not d then break end
        if string.find(d, texturePattern) then
            return true, i
        end
    end
    return false, nil
end

-- Helper: Count Visual Occurrences of a Debuff Texture on Unit
function ScriptExtender_GetVisualDebuffCount(unit, texturePartial)
    local count = 0
    for i = 1, 16 do
        local texture = UnitDebuff(unit, i)
        if not texture then break end
        if string.find(texture, texturePartial) then
            count = count + 1
        end
    end
    return count
end
