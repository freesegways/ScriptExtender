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
            local action, type, score = actor.analyzer(u, true, tm) -- ForceOOC=TRUE (Allow manual start)
            if score and score > best[idx].score then
                best[idx] = { score = score, action = action, type = type, targetName = n, strict = false }
            end
        end
    end

    -- 2. AUTO SCANNING
    -- Check if we found a valid manual target action (Manual Override)
    local manualOverride = false
    for idx, b in ipairs(best) do
        if b.targetName and b.targetName == UnitName("target") then
            -- If manual target is OOC, we override scan (Player wants to pull this specific mob)
            -- If manual target is IN COMBAT, we allow scan to proceed (Check for better targets like Healers)
            if not UnitAffectingCombat("target") then
                manualOverride = true
            end
            break
        end
    end

    if not actors.disableScan and not manualOverride then
        for i = 1, 25 do
            TargetNearestEnemy()
            local u = "target"
            local n = UnitName(u)

            -- Safety: Auto-Scan targets MUST be in combat. Never auto-pull OOC mobs.
            -- If we want to pull an OOC mob, we do it via Manual Target (Phase 1 aka manualOverride).
            local valid = UnitAffectingCombat(u)

            if valid then
                for idx, actor in ipairs(actors) do
                    -- Pass ForceOOC=FALSE (Strict) to prevent auto-pulling OOC mobs
                    local action, type, score = actor.analyzer(u, false, tm)

                    if score and score > best[idx].score then
                        -- Track max priority ...
                        if type == "kill" or type == "fill" then
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
                    -- Analyzer expects 'forceOOC'.
                    -- If strict=false (Manual/AllowOOC), forceOOC should be TRUE.
                    -- If strict=true (Scan/CombatOnly), forceOOC should be FALSE.
                    local newAct, _, newScore = actor.analyzer("target", not b.strict, tm)
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
    -- If we engaged no action, and we were in Auto-Scan mode (no manual override),
    -- we might be left targeting a random OOC mob from the scan loop. Clear it.
    if not anyActionExecuted and not manualOverride then
        if UnitExists("target") and not UnitIsDead("target") then
            -- Check if this accidental target is combat-valid?
            -- If it's OOC, we definitely want to drop it to be safe.
            if not UnitAffectingCombat("target") then
                ClearTarget()
            end
        end
    end

    if not UnitExists("target") or UnitIsDead("target") then
        ClearTarget()
    end
end
