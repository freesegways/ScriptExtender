-- Combat/AutoCombat2/Core/Executor.lua
-- Executes the decision. Handles targeting (via Tab-Cycling) and casting.

if ScriptExtender_Executor then return end

ScriptExtender_Executor = {
    -- Execute the best valid action from the list
    Execute = function(actionList, ws)
        if not actionList or table.getn(actionList) == 0 then return false end

        -- 1. Identify Best Actions (One for Player, One for Pet)
        local bestPlayerAction = nil
        local bestPetAction = nil

        -- Flatten scanning just to find the top candidates
        for _, action in ipairs(actionList) do
            if action.source == "player" and not bestPlayerAction then
                bestPlayerAction = action
            elseif action.source == "pet" and not bestPetAction then
                bestPetAction = action
            end
            if bestPlayerAction and bestPetAction then break end
        end

        local actionExecuted = false

        -- 2. Immediate Execution (Self/Pet/Friendly Targets)
        -- These do not require target cycling.
        if bestPlayerAction and (bestPlayerAction.target == "player" or bestPlayerAction.target == "pet") then
            if ScriptExtender_Executor.AttemptCast(bestPlayerAction, ws) then
                actionExecuted = true
                bestPlayerAction = nil -- Mask as done
            end
        end

        if bestPetAction and (bestPetAction.target == "player" or bestPetAction.target == "pet") then
            if ScriptExtender_Executor.AttemptCast(bestPetAction, ws) then
                actionExecuted = true
                bestPetAction = nil -- Mask as done
            end
        end

        -- If both are done (or were nil), we return
        if not bestPlayerAction and not bestPetAction then return actionExecuted end

        -- 3. Batched Target Cycling (Enemy Actions)
        -- We have at least one action targeting an enemy.
        -- We will cycle ONCE.

        local targetExists = UnitExists("target")
        local initialID = nil
        if targetExists then
            initialID = ScriptExtender_Scanner.GeneratePseudoID({ unit = "target" })
        end

        -- Loop Variables
        local startID = nil
        local seenIDs = {}
        local steps = 0
        local MAX_STEPS = 12

        -- 1. Check current target FIRST (Efficiency & Reliability)
        if targetExists then
            local currentID = ScriptExtender_Scanner.GeneratePseudoID({ unit = "target" })
            if currentID then
                startID = currentID
                seenIDs[currentID] = true

                -- Try to execute immediately
                if bestPlayerAction and ScriptExtender_Scanner.IsIDCompatible(bestPlayerAction.target, currentID) then
                    if ScriptExtender_Executor.AttemptCast(bestPlayerAction, ws) then
                        actionExecuted = true
                        bestPlayerAction = nil
                    end
                end
                if bestPetAction and ScriptExtender_Scanner.IsIDCompatible(bestPetAction.target, currentID) then
                    if ScriptExtender_Executor.AttemptCast(bestPetAction, ws) then
                        actionExecuted = true
                        bestPetAction = nil
                    end
                end
            end
        end

        if not bestPlayerAction and not bestPetAction then return true end

        -- 2. Tab-Cycling Engine
        for i = 1, MAX_STEPS do
            TargetNearestEnemy()
            steps = i

            local currentID = ScriptExtender_Scanner.GeneratePseudoID({ unit = "target" })
            if not currentID then break end

            -- Exit Condition: Strict Full Circle Check
            -- We only stop if we hit the EXACT same string ID we started on.
            if startID and currentID == startID then break end
            if not startID then startID = currentID end

            if not seenIDs[currentID] then
                seenIDs[currentID] = true

                -- Action Matching: Use Compatible matching to handle target shifts
                if bestPlayerAction and ScriptExtender_Scanner.IsIDCompatible(bestPlayerAction.target, currentID) then
                    if ScriptExtender_Executor.AttemptCast(bestPlayerAction, ws) then
                        actionExecuted = true
                        bestPlayerAction = nil
                    end
                end

                if bestPetAction and ScriptExtender_Scanner.IsIDCompatible(bestPetAction.target, currentID) then
                    if ScriptExtender_Executor.AttemptCast(bestPetAction, ws) then
                        actionExecuted = true
                        bestPetAction = nil
                    end
                end

                if not bestPlayerAction and not bestPetAction then break end
            end
        end

        if not actionExecuted and (bestPlayerAction or bestPetAction) then
            local missing = {}
            local expected = {}
            if bestPlayerAction then
                table.insert(missing, bestPlayerAction.action)
                table.insert(expected, bestPlayerAction.target)
            end
            if bestPetAction then
                table.insert(missing, "(Pet) " .. bestPetAction.action)
                table.insert(expected, bestPetAction.target)
            end

            local foundStr = ""
            for id, _ in pairs(seenIDs) do
                foundStr = foundStr .. "\n - " .. id
            end

            ScriptExtender_Error(string.format(
                "Executor: No action executed!\nTarget References: %s\nActions Attempted: %s\nActual IDs Found:%s\nTabs Count: %d",
                table.concat(expected, ", "),
                table.concat(missing, ", "),
                foundStr,
                steps
            ))
        end

        return actionExecuted
    end,

    -- Helper: Final Cast Logic
    AttemptCast = function(action, ws)
        local spellName = action.action

        -- Pet Spell? (Implicit execution via API usually, but standardized here)
        if action.source == "pet" then
            if ScriptExtender_PetCache then
                return ScriptExtender_PetCache.Cast(spellName)
            end
            return false
        end

        -- Player Spell
        local spellID = ScriptExtender_SpellbookCache.GetSpellID(spellName)
        if spellID then
            ScriptExtender_Log("Executor: Casting " .. spellName .. " on " .. (UnitName("target") or "Me"))
            CastSpell(spellID, BOOKTYPE_SPELL)

            -- Ledger tracking
            local _, class = UnitClass("player")
            local classKey = string.upper(class or "")
            if ScriptExtender_ClassDebuffs and ScriptExtender_ClassDebuffs[classKey] then
                local meta = ScriptExtender_ClassDebuffs[classKey][spellName]
                if meta and meta.duration then
                    local ledger = ws.ledger
                    local tID = action.target
                    if not ledger[tID] then ledger[tID] = {} end
                    ledger[tID][spellName] = GetTime() + meta.duration
                end
            end
            return true
        else
            ScriptExtender_Error("Executor: Spell lookup failed for '" ..
                tostring(spellName) .. "'. Not in SpellbookCache?")
        end
        return false
    end
}
