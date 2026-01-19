-- Utils/TalentUtils.lua
-- Helper checking if a talent is learned by name.

function ScriptExtender_HasTalent(talentName)
    local numTabs = GetNumTalentTabs()
    for t = 1, numTabs do
        local numTalents = GetNumTalents(t)
        for i = 1, numTalents do
            local name, icon, tier, column, currentRank, maxRank = GetTalentInfo(t, i)
            if name == talentName then
                return currentRank > 0
            end
        end
    end
    return false
end
