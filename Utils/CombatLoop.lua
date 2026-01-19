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
    local P = "player"
    local inCombat = UnitAffectingCombat(P)

    -- 1. MANUAL TARGET CHECK (Allows OOC pulling)
    if UnitExists("target") and not UnitIsDead("target") and not UnitIsFriend(P, "target") then
        local u = "target"
        local n = UnitName(u)
        for idx, actor in ipairs(actors) do
            local action, type, score = actor.analyzer(u, false, tm) -- Strict=FALSE
            if score and score > best[idx].score then
                best[idx] = { score = score, action = action, type = type, targetName = n, strict = false }
            end
        end
    end

    -- 2. AUTO SCANNING
    if not actors.disableScan then
        for i = 1, 25 do
            TargetNearestEnemy()
            local u = "target"
            local n = UnitName(u)

            -- Safety: If player is in combat, ignore OOC targets completely (unless it's the manual target we just checked)
            local valid = true
            if inCombat and not UnitAffectingCombat(u) then valid = false end

            if valid then
                for idx, actor in ipairs(actors) do
                    -- Pass strict=true to analyzers if in combat
                    local action, type, score = actor.analyzer(u, true, tm)

                    if score and score > best[idx].score then
                        -- Track max priority ...
                        if type == "kill" or type == "dot" or type == "fill" then
                            local prio = ScriptExtender_GetTargetPriority(u)
                            if prio > maxPrioSeen then maxPrioSeen = prio end
                            if prio == 1 and maxPrioSeen >= 2 then score = -999 end
                        end

                        if score > best[idx].score then
                            best[idx] = { score = score, action = action, type = type, targetName = n, strict = true }
                        end
                    end
                end
            end
        end
    end

    -- Phase 2: EXECUTION
    local anyActionExecuted = false
    for idx, actor in ipairs(actors) do
        local b = best[idx]
        if b.action and b.score > -100 then
            local function VerifyTarget()
                -- If strictly required combat, check it. If strict=false (Manual), allow OOC.
                if not b.strict or UnitAffectingCombat("target") then
                    local newAct, _, newScore = actor.analyzer("target", b.strict, tm)
                    if newScore and newScore >= (b.score - 10) and newAct == b.action then
                        return true
                    end
                end
                return false
            end

            -- Re-target if necessary or verify current
            local needScan = false
            if UnitName("target") ~= b.targetName then
                needScan = true
            else
                if not VerifyTarget() then needScan = true end
            end

            if needScan then
                local found = false
                if not actors.disableScan then
                    for i = 1, 25 do
                        TargetNearestEnemy()
                        if UnitName("target") == b.targetName then
                            if VerifyTarget() then
                                found = true; break
                            end
                        end
                    end
                end
                if not found then ClearTarget() end
            end

            -- Final Check
            if UnitName("target") == b.targetName then
                -- Final verification safety wrapper
                if not b.strict or UnitAffectingCombat("target") then
                    actor.onExecute(b.action, b.targetName, tm)
                    anyActionExecuted = true
                end
            end
        end
    end

    -- Cleanup
    if not UnitExists("target") or UnitIsDead("target") then
        ClearTarget()
    elseif actors.untargetIfNoActionExecuted and not anyActionExecuted then
        ClearTarget()
    end
end
