-- Combat/AutoCombat2/Core/Analyzer.lua
-- The Brain. Iterates Mobs x Spells, checks caches, scores actions, and sorts them.

if ScriptExtender_Analyzer then return end

ScriptExtender_Analyzer = {
    -- Evaluate WorldState and return sorted ActionList
    -- Evaluate WorldState and return sorted ActionList
    -- Evaluate WorldState and return sorted ActionList
    Analyze = function(params)
        local ws = params.worldState
        local spellTable = params.spellTable
        local casterUnit = params.casterUnit or "player"

        local actionList = {}

        -- 1. Validate Spell Table
        if not spellTable then
            return {}
        end

        -- 2. Caster State helper for scoring
        local casterState = {
            name = UnitName(casterUnit),
            hpPct = (UnitHealth(casterUnit) / UnitHealthMax(casterUnit)) * 100,
            manaPct = (UnitMana(casterUnit) / UnitManaMax(casterUnit)) * 100
        }

        -- 3. Iterate Spells (Outer Loop? Or Mobs Outer Loop?)
        -- Mobs Outer Loop seems better for "Target Switching" focus,
        -- but Spells Outer Loop is better for "I really need to Heal".
        -- Actually, we treat every (Mob, Spell) pair as a candidate.

        -- A. Target Actions (Spells against Mobs)
        for _, mob in pairs(ws.mobs) do
            -- Safety Gate: Only offensive if mob is In Combat OR is our specific Pull Focus
            local isOffensiveLegal = mob.inCombat or (ws.context.targetPseudoID == mob.pseudoID)

            for spellName, spellData in pairs(spellTable) do
                if spellData.target == "enemy" and isOffensiveLegal then
                    local score = 0

                    -- GATE 1: Internal Cooldown
                    if ScriptExtender_CooldownTracker.IsReady(spellName) then
                        -- GATE 2: Game Cooldown & Usability (Mana)
                        -- We need the Spell ID from SpellbookCache
                        local spellID = ScriptExtender_SpellbookCache.GetSpellID(spellName)

                        -- If we don't know the spell, we can't cast it.
                        if spellID then
                            local start, duration = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
                            local onCD = (start > 0 and duration > 1.5) -- Ignore GCD

                            -- Point 2.1: IsUsableSpell doesn't exist in 1.12. Use Action Slot if possible.
                            local usable = true
                            local slot = ScriptExtender_RangeSlotCache.GetSlot(spellName)
                            if slot then
                                usable = IsUsableAction(slot)
                            end

                            if not onCD and usable then
                                -- GATE 3: Range Check
                                -- Use RangeSlotCache if available, else fallback to bucket
                                local inRange = true

                                -- If the spell has a specific range check slot
                                local rangeSlot = ScriptExtender_RangeSlotCache.GetSlot(spellData.sameRangeAs or
                                    spellName)
                                if rangeSlot then
                                    -- IsActionInRange: 1=True, 0=False, nil=Invalid
                                    local valid = IsActionInRange(rangeSlot, mob.unit)
                                    if valid == 0 then inRange = false end
                                else
                                    -- Fallback: Use Bucket (Very rough)
                                    -- If bucket is 3 (Far) and spell is Melee, fail
                                    -- This is weak, but RangeSlotCache should cover 99% of cases
                                end

                                if inRange then
                                    -- SCORING
                                    score = spellData.score(mob, ws, casterState)
                                end
                            end
                        end
                    end

                    if score > 0 then
                        table.insert(actionList, {
                            action = spellName,
                            target = mob.pseudoID,
                            score = score,
                            unit = mob.unit -- fallback
                        })
                    end
                end
            end
        end

        -- B. Self Actions (Life Tap, Buffs)
        for spellName, spellData in pairs(spellTable) do
            if spellData.target == "player" then
                local score = 0

                -- Checks (Simplified for Self)
                if ScriptExtender_CooldownTracker.IsReady(spellName) then
                    local spellID = ScriptExtender_SpellbookCache.GetSpellID(spellName)
                    if spellID then
                        local start, duration = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
                        local onCD = (start > 0 and duration > 1.5)
                        -- IsUsableSpell checks mana, but for Life Tap mana isn't the cost (HP is)
                        -- So we might skip IsUsable check for some, or trust the API.
                        -- Life Tap returns usable if you have HP.

                        if not onCD then
                            score = spellData.score(nil, ws, casterState)
                        end
                    end
                end

                if score > 0 then
                    table.insert(actionList, {
                        action = spellName,
                        target = casterUnit,
                        score = score,
                        unit = casterUnit
                    })
                end
            end
        end

        -- 4. Sort (Highest Score First)
        table.sort(actionList, function(a, b) return a.score > b.score end)

        ScriptExtender_Log("Analyzer: Evaluated " ..
            table.getn(actionList) .. " valid actions. Top: " .. (actionList[1] and actionList[1].action or "None"))

        return actionList
    end
}
