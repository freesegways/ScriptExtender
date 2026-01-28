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

        local ws = ScriptExtender_Scanner.Scan()

        if not next(ws.mobs) then
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

        local actionList = ScriptExtender_Analyzer.Analyze({
            worldState = ws,
            spellTables = {
                player = spellTable,
                pet = petSpellTable
            },
            casterUnit = "player"
        })

        local executed = ScriptExtender_Executor.Execute(actionList, ws)

        if executed then
            ScriptExtender_Log("AutoCombat2: Action Executed: " .. tostring(executed))
        else
            ScriptExtender_Log("AutoCombat2: No suitable action found.")
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
