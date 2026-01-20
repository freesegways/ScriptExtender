-- Classes/Warlock/AutoWarlock.lua
-- Combined Warlock automation: Runs both player and pet logic in a single efficient targeting loop.

function AutoWarlock()
    local tm = GetTime()
    local P = "player"

    -- 1. PASSIVE PET MAINTENANCE (Follow if nothing to do)
    if not UnitAffectingCombat(P) and (not UnitExists("target") or UnitIsDead("target")) then
        if UnitExists("pet") then PetFollow() end
    end

    -- 2. UNIFIED COMBAT LOOP
    -- Analyzers now handle self-needs (like Life Tap) and targeting priority.
    local actors = {
        {
            -- Player Task
            analyzer = ScriptExtender_Warlock_Analyze,
            onExecute = function(action, targetName, tm)
                if ScriptExtender_IsSpellReady(action) then
                    CastSpellByName(action)
                    ScriptExtender_Warlock_UpdateTracker(action, targetName, tm)
                end
            end
        },
        {
            -- Pet Task
            analyzer = ScriptExtender_Warlock_PetAnalyze,
            onExecute = ScriptExtender_Warlock_PetSpells
        }
    }

    ScriptExtender_RunCombatLoop(actors)
end

ScriptExtender_Register("AutoWarlock",
    "Full Warlock & Pet automation in a single targeting pass. Integrated Life Tap logic.")
