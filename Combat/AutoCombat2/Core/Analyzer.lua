-- Combat/AutoCombat2/Core/Analyzer.lua
-- The Brain. Iterates Mobs x Spells, checks caches, scores actions, and sorts them.

if ScriptExtender_Analyzer then return end

ScriptExtender_Analyzer = {
    -- Evaluate WorldState and return sorted ActionList
    Analyze = function(params)
        local ws = params.worldState
        local spellTables = params.spellTables
        local casterUnit = params.casterUnit or "player"
        local actionList = {}

        if not spellTables then return {} end

        local casterState = {
            name = UnitName(casterUnit),
            hpPct = (UnitHealth(casterUnit) / UnitHealthMax(casterUnit)) * 100,
            manaPct = (UnitMana(casterUnit) / (UnitManaMax(casterUnit) or 1)) * 100
        }

        local isPet = (casterUnit == "pet")

        -- 1. Target Actions (Enemy/PetEnemy)
        for _, mob in pairs(ws.mobs) do
            local isOffensiveLegal = mob.inCombat or (ws.context.targetPseudoID == mob.pseudoID)

            for source, spellTable in pairs(spellTables) do
                for spellName, spellData in pairs(spellTable) do
                    if (spellData.target == "enemy" or spellData.target == "pet_enemy") and isOffensiveLegal then
                        local score = 0
                        local isPetSpell = (source == "pet")

                        if ScriptExtender_CooldownTracker.IsReady(spellName) then
                            local ready = false

                            -- Special Case: Pet Commands (Attack, Follow, etc) skip the bar/cooldown check
                            if isPetSpell and spellData.isCommand then
                                ready = true
                            elseif isPetSpell then
                                -- Pet Logic: Check Pet Action Bar
                                for i = 1, 10 do
                                    local name = GetPetActionInfo(i)
                                    if name and name == spellName then
                                        local start, duration = GetPetActionCooldown(i)
                                        if start == 0 or duration <= 1.5 then
                                            ready = true
                                        end
                                        break
                                    end
                                end
                            else
                                -- Player Logic
                                local spellID = ScriptExtender_SpellbookCache.GetSpellID(spellName)
                                if spellID then
                                    local start, duration = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
                                    if (start == 0 or duration <= 1.5) then
                                        local slot = ScriptExtender_RangeSlotCache.GetSlot(spellName)
                                        if not slot or IsUsableAction(slot) then ready = true end
                                    end
                                end
                            end

                            if ready then
                                local inRange = true
                                local rangeSlot = ScriptExtender_RangeSlotCache.GetSlot(spellData.sameRangeAs or
                                    spellName)
                                if rangeSlot then
                                    if IsActionInRange(rangeSlot, mob.unit) == 0 then inRange = false end
                                end

                                if inRange then
                                    local context = casterState
                                    if isPetSpell then context = ws.context.pet end
                                    score = spellData.score(mob, ws, context)
                                end
                            end
                        end

                        if score > 0 then
                            table.insert(actionList, {
                                action = spellName,
                                target = mob.pseudoID,
                                score = score,
                                unit = mob.unit,
                                source = source
                            })
                        end
                    end
                end
            end
        end

        -- 2. Self Actions (Player/Pet)
        -- 2. Self Actions (Player/Pet)
        for source, spellTable in pairs(spellTables) do
            for spellName, spellData in pairs(spellTable) do
                if spellData.target == "player" or spellData.target == "pet" then
                    local score = 0
                    local isPetSpell = (source == "pet")

                    if ScriptExtender_CooldownTracker.IsReady(spellName) then
                        local ready = false
                        if isPetSpell and spellData.isCommand then
                            ready = true
                        elseif isPetSpell then
                            for i = 1, 10 do
                                local name = GetPetActionInfo(i)
                                if name == spellName then
                                    local start, duration = GetPetActionCooldown(i)
                                    if start == 0 or duration <= 1.5 then ready = true end
                                    break
                                end
                            end
                        else
                            local spellID = ScriptExtender_SpellbookCache.GetSpellID(spellName)
                            if spellID then
                                local start, duration = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
                                if start == 0 or duration <= 1.5 then ready = true end
                            end
                        end

                        if ready then
                            local context = casterState
                            if isPetSpell then context = ws.context.pet end
                            score = spellData.score(nil, ws, context)
                        end
                    end

                    if score > 0 then
                        table.insert(actionList, {
                            action = spellName,
                            target = spellData.target,
                            score = score,
                            unit = casterUnit,
                            source = source
                        })
                    end
                end
            end
        end

        table.sort(actionList, function(a, b) return a.score > b.score end)
        return actionList
    end
}
