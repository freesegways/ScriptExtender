-- Combat/AutoCombat2/Core/Coordinator.lua
-- The Orchestrator. Ties Scanner, Analyzer, and Executor together.

if ScriptExtender_Coordinator then return end

ScriptExtender_Coordinator = {
    initialized = false,
    lastCacheUpdate = 0,
    CACHE_EXPIRY = 300, -- 5 Minutes

    Initialize = function()
        if ScriptExtender_Coordinator.initialized then return end

        ScriptExtender_Coordinator.UpdateCaches()

        ScriptExtender_Coordinator.initialized = true
        ScriptExtender_Log("AutoCombat2: Initialized.")
    end,

    UpdateCaches = function()
        ScriptExtender_Log("AutoCombat2: Refreshing Caches (5m Expiry or Init)...")
        ScriptExtender_RangeSlotCache.Update()
        ScriptExtender_SpellbookCache.Update()
        ScriptExtender_TalentCache.Update()
        if ScriptExtender_PetCache then ScriptExtender_PetCache.Update() end
        ScriptExtender_Coordinator.lastCacheUpdate = GetTime()
    end,

    CacheManager = function()
        if (GetTime() - ScriptExtender_Coordinator.lastCacheUpdate) > ScriptExtender_Coordinator.CACHE_EXPIRY then
            ScriptExtender_Coordinator.UpdateCaches()
        else
            ScriptExtender_Log("AutoCombat2: Caches are fresh.")
        end
    end,

    -- Main Entry Point
    Run = function()
        ScriptExtender_Coordinator.Initialize()
        ScriptExtender_Coordinator.CacheManager()

        ScriptExtender_Log("AutoCombat2: Cycle Start (Scanning...)")
        local ws = ScriptExtender_Scanner.Scan()

        if not next(ws.mobs) then
            -- Cleanup: If we discovered enemies but none were pullable/in-combat, clear the target.
            -- This prevents the bot from leaving you targeting random OOC mobs after a scan cycle.
            if not ws.context.pullMode and UnitExists("target") and not UnitAffectingCombat("target") then
                ClearTarget()
                ScriptExtender_Log("AutoCombat2: No combat found. Clearing discovered target.")
            end
            return
        end

        local _, playerClass = UnitClass("player")
        local spellTable = nil
        local petSpellTable = nil

        if playerClass == "WARLOCK" then
            spellTable = ScriptExtender_WarlockSpells
            petSpellTable = ScriptExtender_WarlockPetSpells
        end

        ScriptExtender_Log("AutoCombat2: Cycle Start (Scanning...)")

        if not spellTable then
            ScriptExtender_Error("AutoCombat2: No logic for class " .. tostring(playerClass))
            return
        end

        local actionList, evalSummary = ScriptExtender_Analyzer.Analyze({
            worldState = ws,
            spellTables = {
                player = spellTable,
                pet = petSpellTable
            },
            casterUnit = "player"
        })

        local executed = ScriptExtender_Executor.Execute(actionList, ws)

        if not ws.context.pullMode and UnitExists("target") and not UnitAffectingCombat("target") then
            ClearTarget()
            ScriptExtender_Log("AutoCombat2: No combat found. Clearing discovered target.")
        end

        local executed = ScriptExtender_Executor.Execute(actionList, ws)

        if executed then
            ScriptExtender_Log("AutoCombat2: Action Executed: " .. tostring(executed))
        else
            -- Detailed Failure Report
            local targetName = ws.context.target or "None"
            local initialID = ws.context.initialTargetPseudoID or "None"
            local mobCount = ws.aggregations.mobCount or 0
            local actionCount = table.getn(actionList or {})

            local debugMsg = string.format(
                "AutoCombat2: No suitable action found!\n- Desired Target: %s (%s)\n- Mobs Discovered: %d\n- Final Actions: %d",
                targetName, initialID, mobCount, actionCount
            )

            -- Mob Evaluation Breakdown
            debugMsg = debugMsg .. "\n--- Evaluated Mobs ---"
            for id, data in pairs(evalSummary or {}) do
                local reason = data.rejectedReason or "Unknown"
                if data.peakScore > 0 then reason = "Executor identity mismatch" end

                debugMsg = debugMsg .. string.format("\n[%s] %s | Legal: %s | MaxScore: %d\n  - Reason: %s",
                    string.sub(id, 1, 8), data.name, tostring(data.isLegal), data.peakScore, reason)

                if data.rejectedSpells and next(data.rejectedSpells) then
                    debugMsg = debugMsg .. "\n  - Rejections: "
                    local count = 0
                    for sName, rCode in pairs(data.rejectedSpells) do
                        debugMsg = debugMsg .. sName .. "(" .. rCode .. ") "
                        count = count + 1
                        if count >= 3 then break end
                    end
                end
            end

            if actionCount > 0 then
                debugMsg = debugMsg ..
                    string.format("\n- Top Action: %s on %s", actionList[1].action, actionList[1].target)
                debugMsg = debugMsg .. "\n- Context: Executor failed to find a valid Target ID match during tab-cycle."
            else
                debugMsg = debugMsg ..
                    "\n- Context: Brain (Analyzer) found no valid actions for the state of the world."
            end

            ScriptExtender_Error(debugMsg)
        end

        if not ws.context.pullMode and UnitExists("target") and not UnitAffectingCombat("target") then
            ClearTarget()
            ScriptExtender_Log("AutoCombat2: Target cleared.")
        end
    end
}

-- Global Accessor for Slash Command
function ScriptExtender_AutoCombat2_Run()
    ScriptExtender_Coordinator.Run()
end

-- Register Command if ScriptExtender is loaded
if ScriptExtender_Register then
    ScriptExtender_Register({
        name = "ScriptExtender_AutoCombat2_Run",
        command = "ac2",
        description = "Runs AutoCombat2 Decision Cycle (The Global Brain)"
    })
end
