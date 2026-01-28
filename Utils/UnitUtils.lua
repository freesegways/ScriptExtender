function ScriptExtender_GetClassCount(className)
    local count = 0
    local numRaid = GetNumRaidMembers()
    local numParty = GetNumPartyMembers()

    -- Check Self first
    local _, class = UnitClass("player")
    if class == className then count = count + 1 end

    if numRaid > 0 then
        count = 0 -- Reset to recount in raid loop (raid includes player usually)
        for i = 1, numRaid do
            local _, class = UnitClass("raid" .. i)
            if class == className then count = count + 1 end
        end
    elseif numParty > 0 then
        for i = 1, numParty do
            local _, class = UnitClass("party" .. i)
            if class == className then count = count + 1 end
        end
    end

    return count
end
