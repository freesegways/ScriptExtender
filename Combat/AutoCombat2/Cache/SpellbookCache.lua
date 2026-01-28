-- Combat/AutoCombat2/Cache/SpellbookCache.lua
-- Indexes all spells in the player's spellbook, handling multiple ranks.

if ScriptExtender_SpellbookCache then return end

ScriptExtender_SpellbookCache = {
    spells = {}, -- Map: SpellName -> { maxRank = 5, ranks = { [1] = { id = 5, cost = 100 }, [5] = { id = 20, cost = 500 } } }

    Update = function()
        ScriptExtender_SpellbookCache.spells = {}

        local i = 1
        while true do
            local spellName, spellRankVal = GetSpellName(i, BOOKTYPE_SPELL)
            if not spellName then break end

            -- Parse Rank: "Rank 1" -> 1. If nil (e.g., "Attack"), default to 0 or 1
            local rank = 1
            if spellRankVal and string.find(spellRankVal, "Rank") then
                local _, _, rNum = string.find(spellRankVal, "Rank (%d+)")
                rank = tonumber(rNum) or 1
            end

            -- Initialize entry if missing
            if not ScriptExtender_SpellbookCache.spells[spellName] then
                ScriptExtender_SpellbookCache.spells[spellName] = {
                    maxRank = 0,
                    ranks = {}
                }
            end

            -- Store Data
            -- NOTE: We cannot easily get mana cost without tooltip scanning at runtime
            -- BUT for V1 foundation, we just need the ID to check IsUsableSpell
            -- Optimization: Only scan tooltip if really needed. For now, we store ID.

            local entry = ScriptExtender_SpellbookCache.spells[spellName]
            entry.ranks[rank] = { id = i, rankText = spellRankVal }

            if rank > entry.maxRank then
                entry.maxRank = rank
            end

            i = i + 1
        end
        -- ScriptExtender_Log("SpellbookCache Updated. Scanned " .. (i-1) .. " spells.")
    end,

    GetSpellID = function(name, rank)
        local entry = ScriptExtender_SpellbookCache.spells[name]
        if not entry then return nil end

        -- Default to Max Rank if not specified
        if not rank then rank = entry.maxRank end

        local rankData = entry.ranks[rank]
        if rankData then return rankData.id end
        return nil
    end
}
