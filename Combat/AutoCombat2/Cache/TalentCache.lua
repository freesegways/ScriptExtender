-- Combat/AutoCombat2/Cache/TalentCache.lua
-- Caches specific high-value talent names and current point counts.

if ScriptExtender_TalentCache then return end

ScriptExtender_TalentCache = {
    talents = {}, -- Key: Name, Value: Points
    lastUpdate = 0
}

function ScriptExtender_TalentCache.Update()
    ScriptExtender_Log("TalentCache: Refreshing...")
    ScriptExtender_TalentCache.talents = {}

    -- In Vanilla 1.12, GetTalentInfo takes (tabIndex, talentIndex)
    -- This is slow to iterate everything, so we only look for names we care about
    -- Usually better to just iterate all 3 tabs and map everything.

    local numTabs = GetNumTalentTabs()
    for tab = 1, numTabs do
        for i = 1, GetNumTalents(tab) do
            local name, icon, tier, column, currRank, maxRank = GetTalentInfo(tab, i)
            if name then
                ScriptExtender_TalentCache.talents[name] = currRank
            end
        end
    end

    ScriptExtender_TalentCache.lastUpdate = GetTime()
    ScriptExtender_Log("TalentCache: Scanned " .. numTabs .. " tabs.")
end

function ScriptExtender_TalentCache.HasTalent(name)
    local rank = ScriptExtender_TalentCache.talents[name] or 0
    return rank > 0
end

function ScriptExtender_TalentCache.GetRank(name)
    return ScriptExtender_TalentCache.talents[name] or 0
end

function ScriptExtender_TalentCache.Dump()
    ScriptExtender_Log("--- Talent Cache ---")
    local count = 0
    local keys = {}
    for k in pairs(ScriptExtender_TalentCache.talents) do table.insert(keys, k) end
    table.sort(keys)

    for _, name in ipairs(keys) do
        local rank = ScriptExtender_TalentCache.talents[name]
        ScriptExtender_Log(string.format("Talent: %s -> Rank: %d", name, rank))
        count = count + 1
    end
    ScriptExtender_Log("Total cached talents: " .. count)
end

-- Global Wrapper
function TalentDump()
    ScriptExtender_TalentCache.Dump()
end

if ScriptExtender_Register then
    ScriptExtender_Register({
        name = "TalentDump",
        command = "talents",
        description = "Lists all cached talents"
    })
end
