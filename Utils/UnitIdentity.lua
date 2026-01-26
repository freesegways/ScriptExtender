-- Utils/UnitIdentity.lua
-- Utilities for identifying units in Vanilla WoW (1.12) where GUIDs are limited.

ScriptExtender_UnitIdentity = {}

--- Generates a Pseudo-ID for a unit based on its observable properties.
-- Vanilla WoW does not provide unique GUIDs for all units. This helper combines Name, Level, MaxHP,
-- Classification, Sex, and Debuff state to create a "fingerprint".
-- Ideally used to differentiate mobs with the same name (e.g., distinguishing a DoT-ed mob from a fresh one).
-- @param unit The unit ID (e.g., "target", "mouseover").
-- @return string A string identifier.
function ScriptExtender_GetPseudoID(unit)
    if not UnitExists(unit) then return "none" end

    local n = UnitName(unit) or "Unknown"
    local l = UnitLevel(unit) or 0
    local mh = UnitHealthMax(unit) or 0
    local s = UnitSex(unit) or 0
    local c = UnitClassification(unit) or "normal"
    local f = UnitCreatureFamily(unit) or "none"
    local _, cl = UnitClass(unit)
    cl = cl or "none"

    -- Debuff Signature: Capture the first few debuffs to distinguish state
    -- (e.g. Boar A has Corruption, Boar B does not -> Different IDs)
    local dSig = ""
    for i = 1, 5 do
        local d = UnitDebuff(unit, i)
        if d then
            -- Use the file name part of texture as a short hash
            -- texture path: "Interface\\Icons\\Spell_Shadow_Abomination"
            local _, _, textureName = string.find(d, "([^\\]+)$")
            if not textureName then textureName = d end
            dSig = dSig .. "|" .. textureName
        else
            break
        end
    end

    -- Format: Name_Lvl_MaxHP_Sex_Class_Family_UnitClass_Debuffs
    return string.format("%s_%d_%d_%d_%s_%s_%s%s", n, l, mh, s, c, f, cl, dSig)
end
