-- Combat/AutoCombat2/Core/Executor.lua
-- Executes the decision. Handles targeting (via Tab-Cycling) and casting.

if ScriptExtender_Executor then return end

ScriptExtender_Executor = {
    -- Execute the best valid action from the list
    Execute = function(actionList, ws)
        if not actionList or table.getn(actionList) == 0 then return false end

        for _, action in ipairs(actionList) do
            local success = ScriptExtender_Executor.Attempt(action, ws)
            if success then return true end
        end

        return false
    end,

    -- Attempt a specific action
    Attempt = function(action, ws)
        local spellName = action.action
        local targetPseudoID = action.target

        -- 1. Special Case: Self Cast
        if targetPseudoID == "player" then
            CastSpellByName(spellName)
            ScriptExtender_Log("Executor: Executing Self-Cast: " .. spellName)
            return true
        end

        -- 2. Target Acquisition
        local targetMob = ws.mobs[targetPseudoID]
        if not targetMob then
            ScriptExtender_Error("Executor: Target PseudoID not found in WorldState: " .. tostring(targetPseudoID))
            return false
        end

        -- Determine if we are in Pull Mode (Current Target is OOC)
        local targetExists = UnitExists("target")
        local targetIsOOC = targetExists and not UnitAffectingCombat("target")

        -- Check current target immediately
        local currentID = ScriptExtender_Scanner.GeneratePseudoID({ unit = "target" })

        if currentID ~= targetPseudoID then
            -- RESTRICTION: If we are in Pull Mode (OOC target), we are FORBIDDEN from tabbing.
            if targetIsOOC then
                ScriptExtender_Log("Executor: Pull Target mismatch. Skipping action to avoid accidental pull.")
                return false
            end

            -- Normal Combat Acquisition (Tabs allowed)
            ScriptExtender_Log("Executor: Target mismatch. Cycling to find PseudoID: " .. tostring(targetPseudoID))

            local startKey = nil
            if targetExists then
                startKey = UnitName("target") .. "_" .. UnitLevel("target") .. "_" .. UnitHealthMax("target")
            end

            local found = false
            for i = 1, 26 do
                if i > 1 then TargetNearestEnemy() end

                local newID = ScriptExtender_Scanner.GeneratePseudoID({ unit = "target" })
                local newKey = nil
                if UnitExists("target") then
                    newKey = UnitName("target") .. "_" .. UnitLevel("target") .. "_" .. UnitHealthMax("target")
                end

                if newID == targetPseudoID then
                    found = true
                    break
                end

                if i > 1 and startKey and newKey == startKey then
                    break
                end

                if not startKey and newKey then
                    startKey = newKey
                end
            end

            if not found then
                ScriptExtender_Error("Executor: Target lost (Full Circle reached without finding " ..
                    tostring(targetPseudoID) .. ")")
                return false
            end
        end

        -- 3. Final Check: Cast
        local spellID = ScriptExtender_SpellbookCache.GetSpellID(spellName)
        if spellID then
            ScriptExtender_Log("Executor: Casting " .. spellName .. " on " .. (UnitName("target") or "Unknown"))
            CastSpell(spellID, BOOKTYPE_SPELL)

            -- Point 2.3: Register Debuff in Ledger if it's a known class spell
            local _, class = UnitClass("player")
            local classKey = string.upper(class or "")
            if ScriptExtender_ClassDebuffs and ScriptExtender_ClassDebuffs[classKey] then
                local meta = ScriptExtender_ClassDebuffs[classKey][spellName]
                if meta and meta.duration then
                    local ledger = ws.ledger
                    if not ledger[targetPseudoID] then ledger[targetPseudoID] = {} end
                    ledger[targetPseudoID][spellName] = GetTime() + meta.duration
                    ScriptExtender_Log("Executor: Registered " .. spellName .. " in ledger for " .. targetPseudoID)
                end
            end

            return true
        end

        return false
    end
}
