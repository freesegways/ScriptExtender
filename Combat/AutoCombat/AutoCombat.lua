-- Combat/AutCombat/AutoCombat.lua
-- A reusable targeting loop that can run multiple analyzers (e.g. Player and Pet) in a single pass.

function ScriptExtender_AutoCombat_Run(actors)
    -- actors: Array of { analyzer = function, onExecute = function }
    if not actors then return end

    local tm = GetTime()
    local best = {}
    for i, _ in ipairs(actors) do
        best[i] = { score = -999, action = nil, type = nil, prio = 0, targetName = nil, targetPseudoID = nil }
    end

    local maxPrioSeen = 0

    -- Phase 1: SCANNING (Single pass through targets)
    local P = "player"
    local inCombat = UnitAffectingCombat(P)

    -- 1. MANUAL TARGET CHECK (Allows OOC pulling)
    if UnitExists("target") and not UnitIsDead("target") and not UnitIsFriend(P, "target") then
        local u = "target"
        local n = UnitName(u)

        -- Get Context for Manual Unit (Force Refresh to ensure accurate data)
        -- SKIP SCANNING: We are focused on a manual target, do NOT run environment scan (TargetNearestEnemy loop).
        local ctx = ScriptExtender_GetCombatContext(u, true)
        -- Capture ID for matching later
        local pid = ctx.pseudoID

        for idx, actor in ipairs(actors) do
            local action, type, score = actor.analyzer({ unit = u, allowManualPull = true, context = ctx })
            if score and score > best[idx].score then
                best[idx] = {
                    score = score,
                    action = action,
                    type = type,
                    targetName = n,
                    targetPseudoID = pid, -- Store ID
                    strict = false
                }
            end
        end
    end

    -- 2. AUTO SCANNING
    -- Check if we found a valid manual target action (Manual Override)
    local manualOverride = false

    -- FORCE OVERRIDE: If we have a valid OOC enemy target, NEVER scan.
    -- This prevents tabbing away to identical mobs (PseudoID collision) during pulls.
    if UnitExists("target") and not UnitIsDead("target") and not UnitIsFriend(P, "target") and not UnitAffectingCombat("target") then
        manualOverride = true
    end

    local curPseudoID = nil
    if ScriptExtender_GetPseudoID then curPseudoID = ScriptExtender_GetPseudoID("target") end

    if not manualOverride then
        for idx, b in ipairs(best) do
            local match = false
            if b.targetPseudoID and curPseudoID then
                if b.targetPseudoID == curPseudoID then match = true end
            end

            if match then
                -- If manual target is IN COMBAT, we allow scan to proceed (Check for better targets like Healers)
                -- (OOC case covered above)
                local targetInCombat = UnitAffectingCombat("target")
                if not targetInCombat then
                    manualOverride = true
                end
                break
            end
        end
    end

    if not actors.disableScan and not manualOverride then
        -- OPTIMIZATION: Fetch Global Context ONCE (skipScan=true for speed)
        local globalCtx = ScriptExtender_GetGlobalContext(true)

        for i = 1, 20 do -- OPTIMIZATION: Scan 10 nearest mobs
            TargetNearestEnemy()
            local u = "target"
            local n = UnitName(u) or "Unknown"

            -- Safety: Auto-Scan targets MUST be in combat. Never auto-pull OOC mobs.
            local valid = UnitExists(u) and UnitAffectingCombat(u) and not UnitIsFriend(P, u) and not UnitIsDead(u)

            if valid then
                -- Get Context for Scanned Unit (Lightweight enrichment)
                local ctx = ScriptExtender_EnrichContext(globalCtx, u, true)

                for idx, actor in ipairs(actors) do
                    -- Pass allowManualPull=FALSE (Strict) to prevent auto-pulling OOC mobs
                    local action, type, score = actor.analyzer({ unit = u, allowManualPull = false, context = ctx })

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
                                targetPseudoID = ctx.pseudoID,
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
            ScriptExtender_Log("BEST[" ..
                idx ..
                "]: " ..
                b.action ..
                " on " .. tostring(b.targetName) .. " (score: " .. b.score .. ", strict: " .. tostring(b.strict) .. ")")
        end
    end

    -- Phase 2: EXECUTION
    -- Heuristic: After scanning, if we found good actions and have ANY valid target, execute.

    local anyNeedsAutoTarget = false
    local manualActionExists = false
    for idx, b in ipairs(best) do
        if b.action and b.score > -100 then
            if b.strict then
                anyNeedsAutoTarget = true
            else
                manualActionExists = true
            end
        end
    end

    -- Only auto-target if we have ONLY auto-scan actions and no valid combat target.
    -- If we have a manual action, we NEVER want to change our target.
    if anyNeedsAutoTarget and not manualActionExists then
        if not (UnitExists("target") and UnitAffectingCombat("target") and not UnitIsDead("target") and not UnitIsFriend(P, "target")) then
            TargetNearestEnemy()
        end
    end

    local anyActionExecuted = false
    for idx, actor in ipairs(actors) do
        local b = best[idx]
        if b.action and b.score > -100 then
            -- Validate current target
            if UnitExists("target") and not UnitIsDead("target") and not UnitIsFriend(P, "target") then
                -- Match check: Ensure we are still targeting who we analyzed
                -- (Skip for strict/auto-scan as they might have been targeted by Phase 2 auto-target)
                if b.strict or ScriptExtender_IsTargetMatch(b, "target") then
                    -- Requirement: Auto-scanned targets MUST be in combat. Manual targets can be OOC (Pulling).
                    local combatPass = not b.strict or UnitAffectingCombat("target")

                    if combatPass then
                        -- Final Identity Check before casting:
                        -- If we have a PseudoID, verify it matches the current target.
                        -- This prevents casting on a mob with the same name but different state (e.g. Swapped Boars).
                        if b.targetPseudoID and b.targetPseudoID ~= ScriptExtender_GetPseudoID("target") then
                            -- Mismatch! We likely tabbed to a different mob with same name. Abort.
                            ScriptExtender_Log("PseudoID Mismatch. Aborting cast.")
                        else
                            actor.onExecute(b.action, b.targetName, tm)
                            anyActionExecuted = true
                        end
                    end
                end
            end
        end
    end

    -- Cleanup
    -- If we engaged no action, and we were in Auto-Scan mode (no manual override),
    -- we might be left targeting a random OOC mob from the scan loop. Clear it.
    if not anyActionExecuted and not manualOverride then
        if UnitExists("target") and not UnitIsDead("target") and not UnitAffectingCombat("target") then
            ClearTarget()
        end
    end

    if not UnitExists("target") or UnitIsDead("target") then
        ClearTarget()
    end
end

function ScriptExtender_IsTargetMatch(b, unit)
    if not UnitExists(unit) then return false end
    if b.targetPseudoID and ScriptExtender_GetPseudoID then
        return b.targetPseudoID == ScriptExtender_GetPseudoID(unit)
    end
    return false
end
