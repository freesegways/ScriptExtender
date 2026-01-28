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
        ScriptExtender_Coordinator.lastCacheUpdate = GetTime()
    end,

    -- Main Entry Point
    Run = function()
        -- 0. Ensure Init
        ScriptExtender_Coordinator.Initialize()

        -- 0.5 Check Cache Expiry
        if (GetTime() - ScriptExtender_Coordinator.lastCacheUpdate) > ScriptExtender_Coordinator.CACHE_EXPIRY then
            ScriptExtender_Coordinator.UpdateCaches()
        else
            ScriptExtender_Log("AutoCombat2: Caches are fresh.")
        end

        -- 1. Scan World
        -- Builds WorldState (Mobs, Context)
        -- Point 8.3: Store target to restore after discovery/execution
        local originalTarget = nil
        if UnitExists("target") then
            originalTarget = UnitName("target")
        end

        local ws = ScriptExtender_Scanner.Scan()

        -- 2. Analyze (Player)
        -- Determine best class spells
        local _, playerClass = UnitClass("player")
        local spellTable = nil

        if playerClass == "WARLOCK" then
            spellTable = ScriptExtender_WarlockSpells
        end

        ScriptExtender_Log("AutoCombat2: Cycle Start (Scanning...)")

        if not spellTable then
            ScriptExtender_Error("AutoCombat2: No logic for class " .. tostring(playerClass))
            return
        end

        local actionList = ScriptExtender_Analyzer.Analyze({
            worldState = ws,
            spellTable = spellTable,
            casterUnit = "player"
        })

        -- 2.1 Analyze Pet (Independent of Player GCD)
        local petActionList = nil
        if UnitExists("pet") then
            if ScriptExtender_WarlockPetSpells then
                ScriptExtender_Log("Coordinator: Analyzing Pet Family: " ..
                tostring(ws.context.pet and ws.context.pet.family or "Unknown"))
                petActionList = ScriptExtender_Analyzer.Analyze({
                    worldState = ws,
                    spellTable = ScriptExtender_WarlockPetSpells,
                    casterUnit = "pet"
                })
                if petActionList and table.getn(petActionList) > 0 then
                    ScriptExtender_Log("Coordinator: Pet Action List count: " .. table.getn(petActionList))
                end
            else
                ScriptExtender_Log("Coordinator: Pet exists but ScriptExtender_WarlockPetSpells is nil!")
            end
        end

        -- 3. Execute
        if petActionList and table.getn(petActionList) > 0 then
            local petExecuted = ScriptExtender_Executor.Execute(petActionList, ws)
            if petExecuted then
                ScriptExtender_Log("Coordinator: Pet Action Executed.")
            end
        end

        local executed = ScriptExtender_Executor.Execute(actionList, ws)

        if executed then
            ScriptExtender_Log("AutoCombat2: Action Executed: " .. tostring(executed))
        else
            ScriptExtender_Log("AutoCombat2: No suitable action found.")
        end

        -- 4. Target Restoration & Cleanup
        -- Point 1.6: If we end up on an OOC target that isn't our original, clear it.
        if UnitExists("target") and not UnitAffectingCombat("target") then
            if not originalTarget or UnitName("target") ~= originalTarget then
                ScriptExtender_Log("Coordinator: Clearing unwanted OOC target.")
                ClearTarget()
            end
        end

        -- Point 8.3: Attempt to restore original target if it was lost
        if originalTarget and UnitName("target") ~= originalTarget then
            ScriptExtender_Log("Coordinator: Attempting to restore original target: " .. originalTarget)
            for i = 1, 25 do
                TargetNearestEnemy()
                if UnitName("target") == originalTarget then break end
            end
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
