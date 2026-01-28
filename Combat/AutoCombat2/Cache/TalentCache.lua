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
