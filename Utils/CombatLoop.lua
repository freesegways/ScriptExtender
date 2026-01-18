-- Utils/CombatLoop.lua
-- A reusable targeting loop that can run multiple analyzers (e.g. Player and Pet) in a single pass.

function ScriptExtender_RunCombatLoop(actors)
    -- actors: Array of { analyzer = function, onExecute = function }
    local tm = GetTime()
    local best = {}
    for i, _ in ipairs(actors) do
        best[i] = { score = -999, action = nil, type = nil, prio = 0, targetName = nil }
    end

    local maxPrioSeen = 0

    -- Phase 1: SCANNING (Single pass through targets)
    for i = 1, 20 do
        TargetNearestEnemy()
        local u = "target"
        local n = UnitName(u)

        for idx, actor in ipairs(actors) do
            local action, type, score = actor.analyzer(u, false, tm)

            if score and score > best[idx].score then
                -- Track max priority for player veto logic (if the analyzer provides it)
                if type == "kill" or type == "dot" or type == "fill" then
                    local prio = ScriptExtender_GetTargetPriority(u)
                    if prio > maxPrioSeen then maxPrioSeen = prio end
                    -- Priority Veto: Don't attack low prio if high prio exists
                    if prio == 1 and maxPrioSeen >= 2 then score = -999 end
                end

                if score > best[idx].score then
                    best[idx] = { score = score, action = action, type = type, targetName = n }
                end
            end
        end
    end

    -- Phase 2: EXECUTION
    for idx, actor in ipairs(actors) do
        local b = best[idx]
        if b.action and b.score > -100 then
            -- Re-target if necessary
            if UnitName("target") ~= b.targetName then
                for i = 1, 20 do
                    TargetNearestEnemy()
                    if UnitName("target") == b.targetName then break end
                end
            end

            if UnitName("target") == b.targetName then
                actor.onExecute(b.action, b.targetName, tm)
            end
        end
    end

    ClearTarget()
end
