-- Utils/TargetSafety.lua
-- Utility functions to check target safety (Immunities, Crowd Control)

function ScriptExtender_IsImmune(unit)
    if not UnitExists(unit) then return false end

    -- Check Buffs for Immunity Textures
    for i = 1, 16 do
        local b = UnitBuff(unit, i)
        if not b then break end
        if ScriptExtender_ImmuneTextures then
            for _, t in ipairs(ScriptExtender_ImmuneTextures) do
                if string.find(b, t) then return true end
            end
        end
    end

    return false
end

function ScriptExtender_IsCC(unit)
    if not UnitExists(unit) then return false end

    -- Check Debuffs for CC Textures (Polymorph, Sap, etc.)
    for i = 1, 16 do
        local d = UnitDebuff(unit, i)
        if not d then break end
        if ScriptExtender_CCTextures then
            for _, t in ipairs(ScriptExtender_CCTextures) do
                if string.find(d, t) then return true end
            end
        end
    end

    return false
end
