-- Classes/Warlock/AutoDoT.lua
-- Warlock combat automation entry point using the shared CombatLoop.

function AutoDoT()
    local actors = {
        {
            analyzer = ScriptExtender_Warlock_Analyze,
            onExecute = function(action, targetName, tm)
                CastSpellByName(action)
                ScriptExtender_Warlock_UpdateTracker(action, targetName, tm)
            end
        }
    }

    ScriptExtender_RunCombatLoop(actors)
end

ScriptExtender_Register("AutoDoT", "Warlock combat automation loop: handles DoTs, executes, and target priority.")
