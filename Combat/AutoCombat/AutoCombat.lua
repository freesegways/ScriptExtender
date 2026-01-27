-- Combat/AutCombat/AutoCombat.lua
-- A reusable targeting loop that can run multiple analyzers (e.g. Player and Pet) in a single pass.

function ScriptExtender_AutoCombat_Run(params)
    -- params: {
    --   actors = Array of { analyzer = function, onExecute = function }
    --   disableScan = (optional) boolean to skip auto-scan phase
    -- }

    local actors = params.actors
    local disableScan = params.disableScan

    if not actors or type(actors) ~= "table" then
        error("ERROR: ScriptExtender_AutoCombat_Run: params.actors must be a table")
        return
    end


    for i, actor in ipairs(actors) do
        if type(actor) ~= "table" then
            error("ERROR: ScriptExtender_AutoCombat_Run: actor[" .. i .. "] must be a table")
            return
        end
        if type(actor.analyzer) ~= "function" then
            error("ERROR: ScriptExtender_AutoCombat_Run: actor[" .. i .. "].analyzer must be a function")
            return
        end
        if type(actor.onExecute) ~= "function" then
            error("ERROR: ScriptExtender_AutoCombat_Run: actor[" .. i .. "].onExecute must be a function")
            return
        end
    end

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
                -- If manual target is IN COMBAT,
                -- (OOC case covered above)
                local targetInCombat = UnitAffectingCombat("target")
                if not targetInCombat then
                    manualOverride = true
                end
                break
            end
        end
    end

    if not disableScan and not manualOverride then
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

                -- BRAKE: If we found a "Kill" target on this unit, STOP scanning.
                -- This ensures we are currently targeting the best mob when the loop ends.
                local topScore = -1000
                for _, b in ipairs(best) do if b.score > topScore then topScore = b.score end end
                if topScore >= 90 then
                    break
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

    local anyActionExecuted = false
    for idx, actor in ipairs(actors) do
        local b = best[idx]
        if b.action and b.score > -100 then
            ScriptExtender_Log("[EXEC] Attempting to execute " .. b.action .. " on " .. tostring(b.targetName))

            -- Validate current target
            if UnitExists("target") and not UnitIsDead("target") and not UnitIsFriend(P, "target") then
                ScriptExtender_Log("[EXEC] Target validation PASSED")

                -- Final Identity Check before casting:
                -- If we have a PseudoID, verify it matches the current target.
                -- This prevents casting on a mob with the same name but different state (e.g. Swapped Boars).
                if b.targetPseudoID and b.targetPseudoID ~= ScriptExtender_GetPseudoID("target") then
                    -- Mismatch! Try to re-target the correct mob.
                    ScriptExtender_Log("PseudoID Mismatch. Attempting to re-target correct mob...")

                    local foundCorrectTarget = false

                    -- Scan up to 20 nearby enemies to find the one with matching PseudoID
                    for i = 1, 20 do
                        TargetNearestEnemy()
                        if UnitExists("target") and not UnitIsDead("target") and not UnitIsFriend(P, "target") and UnitAffectingCombat("target") then
                            local currentPseudoID = ScriptExtender_GetPseudoID("target")
                            if currentPseudoID == b.targetPseudoID then
                                -- Found it! Verify name match
                                local targetName = UnitName("target")
                                if targetName == b.targetName then
                                    ScriptExtender_Log("Re-target SUCCESS: Found " .. targetName)
                                    foundCorrectTarget = true
                                    -- Execute the action on the correct target
                                    actor.onExecute(b.action, b.targetName, tm)
                                    anyActionExecuted = true
                                    break
                                end
                            end
                        end
                    end

                    if not foundCorrectTarget then
                        error("ERROR: Re-target FAILED: Could not find mob with PseudoID " ..
                            tostring(b.targetPseudoID))
                    end
                else
                    ScriptExtender_Log("[EXEC] PseudoID match confirmed. Executing action.")
                    actor.onExecute(b.action, b.targetName, tm)
                    anyActionExecuted = true
                end
            else
                error("ERROR: Target validation FAILED: Could not find mob with PseudoID " ..
                    tostring(b.targetPseudoID))
            end
        else
            if b.action then
                ScriptExtender_Log("[EXEC] Skipping action " .. b.action .. " due to low score (" .. b.score .. ")")
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

if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("AutoCombat.lua LOADED") end
