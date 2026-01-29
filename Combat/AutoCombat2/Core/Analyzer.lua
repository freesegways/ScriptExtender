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
            hpPct = ws.context.playerHP_Pct,
            manaPct = ws.context.playerMana_Pct,
            shards = ws.context.playerShards
        }

        local evaluationSummary = {}

        -- 1. Target Actions (Enemy/PetEnemy)
        for _, mob in pairs(ws.mobs) do
            local isOffensiveLegal = mob.inCombat or (ws.context.initialTargetPseudoID == mob.pseudoID)
            local mobSummary = { name = mob.name, isLegal = isOffensiveLegal, peakScore = 0, rejectedSpells = {} }

            if not isOffensiveLegal then
                mobSummary.rejectedReason = "OOC/Illegal"
            end

            for source, spellTable in pairs(spellTables) do
                for spellName, spellData in pairs(spellTable) do
                    if (spellData.target == "enemy" or spellData.target == "pet_enemy") and isOffensiveLegal then
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

                            if not ready then
                                mobSummary.rejectedSpells[spellName] = "NotReady"
                            end

                            -- Range Check (Scanner-Trust Strategy)
                            local inRange = (mob.foundInRange == true) or (mob.rangeBucket <= 2)
                            if not inRange then
                                mobSummary.rejectedSpells[spellName] = "Range"
                            end

                            if inRange and ready then
                                local context = casterState
                                if isPetSpell then context = ws.context.pet end
                                score = (spellData.score(mob, ws, context) or 0)
                                if score <= 0 then
                                    mobSummary.rejectedSpells[spellName] = "Score0"
                                end
                            end
                        else
                            mobSummary.rejectedSpells[spellName] = "Cooldown"
                        end

                        if score > mobSummary.peakScore then mobSummary.peakScore = score end

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

            if mobSummary.peakScore == 0 and isOffensiveLegal then
                mobSummary.rejectedReason = "No spells passed criteria"
            end
            evaluationSummary[mob.pseudoID] = mobSummary
        end

        -- 2. Self Actions (Player/Pet)
        -- ... (Skipping full update to 2. Self Actions for brevity in summary, but ensuring it returns correctly) ...
        -- (Actually I should keep the logic for 2. Self Actions but not necessarily summarize it the same way unless needed)

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
        return actionList, evaluationSummary
    end
}
