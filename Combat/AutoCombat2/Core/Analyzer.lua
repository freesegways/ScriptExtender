-- Combat/AutoCombat2/Core/Analyzer.lua
-- The Brain. Iterates Mobs x Spells, checks caches, scores actions, and sorts them.

if ScriptExtender_Analyzer then return end

ScriptExtender_Analyzer = {
    -- Evaluate WorldState and return sorted ActionList
    Analyze = function(params)
        local ws = params.worldState
        local spellTables = params.spellTables
        local casterUnit = params.casterUnit == "pet" and "pet" or "player"
        local actionList = {}

        if not spellTables then return {} end

        local casterState = {
            name = UnitName(casterUnit),
            hpPct = (UnitHealth(casterUnit) / UnitHealthMax(casterUnit)) * 100,
            manaPct = (UnitMana(casterUnit) / (UnitManaMax(casterUnit) or 1)) * 100
        }

        -- 1. Target Actions (Enemy/PetEnemy)
        for _, mob in pairs(ws.mobs) do
            local isOffensiveLegal = mob.inCombat or (ws.context.initialTargetPseudoID == mob.pseudoID)

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
                                -- Pet Logic: Use PetCache
                                if ScriptExtender_PetCache and ScriptExtender_PetCache.IsReady(spellName) then
                                    ready = true
                                end
                            else
                                -- Player Logic
                                if ScriptExtender_SpellbookCache.IsReady(spellName) then
                                    ready = true
                                end
                            end

                            local inRange = ScriptExtender_RangeSlotCache.InRange(spellName, mob.unit)

                            if inRange and ready then
                                local context = casterState
                                if isPetSpell then context = ws.context.pet end
                                score = spellData.score(mob, ws, context)
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
                            if ScriptExtender_PetCache and ScriptExtender_PetCache.IsReady(spellName) then
                                ready = true
                            end
                        else
                            if ScriptExtender_SpellbookCache.IsReady(spellName) then
                                ready = true
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
