-- Combat/AutCombat/AutoCombat.lua
-- A reusable targeting loop that can run multiple analyzers (e.g. Player and Pet) in a single pass.

function ScriptExtender_AutoCombat_Run(actors)
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

        -- Get Context for Manual Unit
        local ctx = ScriptExtender_GetCombatContext(u)

        for idx, actor in ipairs(actors) do
            local action, type, score = actor.analyzer(u, true, ctx) -- Pass Context!
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
            local n = UnitName(u) or "Unknown"

            -- Safety: Auto-Scan targets MUST be in combat. Never auto-pull OOC mobs.
            local valid = UnitExists(u) and UnitAffectingCombat(u) and not UnitIsFriend(P, u) and not UnitIsDead(u)

            if valid then
                -- Get Context for Scanned Unit
                local ctx = ScriptExtender_GetCombatContext(u, true)

                for idx, actor in ipairs(actors) do
                    -- Pass ForceOOC=FALSE (Strict) to prevent auto-pulling OOC mobs
                    local action, type, score = actor.analyzer(u, false, ctx)

                    if score and score > best[idx].score then
                        -- Track max priority ...
                        if type == "kill" or type == "fill" then
                            local prio = ScriptExtender_GetTargetPriority(u)
                            if prio > maxPrioSeen then maxPrioSeen = prio end
                            if prio == 1 and maxPrioSeen >= 2 then score = -999 end
                        end

                        if score > best[idx].score then
                            best[idx] = {
                                score = score,
                                action = action,
                                type = type,
                                targetName = n,
                                targetLevel = UnitLevel(u),
                                targetMaxHP = UnitHealthMax(u),
                                strict = true
                            }
                        end
                    end
                end
            end
        end
    end

    -- Debug: Print what we found
    for idx, b in ipairs(best) do
        if b.action then
            print("DEBUG BEST[" ..
                idx ..
                "]: " ..
                b.action ..
                " on " .. tostring(b.targetName) .. " (score: " .. b.score .. ", strict: " .. tostring(b.strict) .. ")")
        end
    end

    -- Phase 2: EXECUTION
    -- Heuristic: After scanning, if we found good actions and have ANY valid target, execute.
    -- We don't need perfect name matching - trust the scan results.

    -- If we found actions but don't have a target, grab one
    local anyBestAction = false
    for idx, _ in ipairs(actors) do
        if best[idx].action and best[idx].score > -100 then
            anyBestAction = true
            break
        end
    end

    if anyBestAction and not (UnitExists("target") and UnitAffectingCombat("target") and not UnitIsDead("target") and not UnitIsFriend(P, "target")) then
        TargetNearestEnemy() -- Grab any valid enemy
    end

    local anyActionExecuted = false
    for idx, actor in ipairs(actors) do
        local b = best[idx]
        if b.action and b.score > -100 then
            -- Check if SOME valid target exists (might not be the exact one we scanned, but close enough)
            if UnitExists("target") and UnitAffectingCombat("target") and not UnitIsDead("target") and not UnitIsFriend(P, "target") then
                actor.onExecute(b.action, b.targetName, tm)
                anyActionExecuted = true
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

function ScriptExtender_IsTargetMatch(b, unit)
    if not UnitExists(unit) then return false end
    if b.targetName and b.targetName ~= UnitName(unit) then return false end
    return true
end
