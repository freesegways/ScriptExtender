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

    -- Format: Name_Lvl_MaxHP_Sex_Class_Family_UnitClass
    return string.format("%s_%d_%d_%d_%s_%s_%s", n, l, mh, s, c, f, cl)
end
