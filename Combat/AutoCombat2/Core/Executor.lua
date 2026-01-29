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
        local startID = initialID
        local steps = 0
        local seenIDs = {}
        local MAX_STEPS = 26

        -- If Pull Mode is active, we do NOT cycle. We only check the current target.
        if ws.context.pullMode and targetExists then
            MAX_STEPS = 1
            ScriptExtender_Log("Executor: Pull Mode active. Restricting loop to current target.")
        end

        for i = 1, MAX_STEPS do
            if i > 1 then TargetNearestEnemy() end
            steps = i

            local currentID = ScriptExtender_Scanner.GeneratePseudoID({ unit = "target" })
            if currentID and not seenIDs[currentID] then
                seenIDs[currentID] = true
            end

            local isOOC = not UnitAffectingCombat("target")

            -- Valid Target Logic
            local validTarget = false
            if currentID then validTarget = true end

            -- Skip OOC (unless Pull Mode, but Pull Mode max_steps=1 handles that implicitly by not cycling)
            if not ws.context.pullMode and isOOC then
                validTarget = false
            end

            -- Pull Mode Override: Trust the target even if ID drifted
            if ws.context.pullMode and targetExists then
                currentID = (bestPlayerAction and bestPlayerAction.target) or (bestPetAction and bestPetAction.target)
                validTarget = true
            end

            if validTarget then
                -- Check Player Action
                if bestPlayerAction and bestPlayerAction.target == currentID then
                    if ScriptExtender_Executor.AttemptCast(bestPlayerAction, ws) then
                        actionExecuted = true
                        bestPlayerAction = nil -- Done
                    end
                end

                -- Check Pet Action
                if bestPetAction and bestPetAction.target == currentID then
                    if ScriptExtender_Executor.AttemptCast(bestPetAction, ws) then
                        actionExecuted = true
                        bestPetAction = nil -- Done
                    end
                end
            end

            -- Exit Conditions
            if not bestPlayerAction and not bestPetAction then break end -- All done

            -- Full Circle Check
            if i > 1 and startID and currentID == startID then break end
            if not startID and currentID then startID = currentID end
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
            if spellName == "PetAttack" then
                PetAttack()
            elseif spellName == "PetFollow" then
                PetFollow()
            else
                CastSpellByName(spellName)
            end
            return true
        end

        -- Player Spell
        local spellID = ScriptExtender_SpellbookCache.GetSpellID(spellName)
        if spellID then
            ScriptExtender_Log("Executor: Casting " .. spellName .. " on " .. (UnitName("target") or "Me"))
            CastSpell(spellID, BOOKTYPE_SPELL)

            local _, class = UnitClass("player")
            local classKey = string.upper(class or "")
            if ScriptExtender_ClassDebuffs and ScriptExtender_ClassDebuffs[classKey] then
                local meta = ScriptExtender_ClassDebuffs[classKey][spellName]
                if meta and meta.duration then
                    local ledger = ws.ledger
                    local tID = action.target
                    if not ledger[tID] then ledger[tID] = {} end
                    ledger[tID][spellName] = GetTime() + meta.duration
                    ScriptExtender_Log("Executor: Registered " .. spellName .. " in ledger for " .. tID)
                end
            end
            return true
        end
        return false
    end
}
