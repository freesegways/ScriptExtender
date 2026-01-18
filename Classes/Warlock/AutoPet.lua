-- Classes/Warlock/AutoPet.lua
-- Main Warlock Pet automation loop using the shared CombatLoop.

function AutoPet()
    local pl = "player"

    -- 1. Passive Checks
    if not UnitExists("pet") or UnitIsDead("pet") then return end
    if not UnitAffectingCombat(pl) and (not UnitExists("target") or UnitIsDead("target")) then
        PetFollow()
        return
    end

    -- 2. Combat Loop
    local actors = {
        {
            analyzer = ScriptExtender_Warlock_PetAnalyze,
            onExecute = ScriptExtender_Warlock_PetSpells
        }
    }

    ScriptExtender_RunCombatLoop(actors)
end

ScriptExtender_Register("AutoPet", "Warlock pet automation: handles target switching, CC safety, and pet spells.")
