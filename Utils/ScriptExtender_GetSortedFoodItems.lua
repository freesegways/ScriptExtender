-- Helper moved from Consumables.lua
function ScriptExtender_GetSortedFoodItems(typeFilter, buffFilter, conjuredFilter)
    local items = {}
    
    -- Iterate array-based DB
    for _, item in ipairs(TURTLE_FOOD_DB) do
        local typeMatch = false
        if typeFilter == "Food" and (item.type == "Food" or item.type == "Food & Drink") then typeMatch = true end
        if typeFilter == "Drink" and (item.type == "Drink" or item.type == "Food & Drink") then typeMatch = true end
        
        if typeMatch then
            -- Buff Filter
            local buffMatch = true
            local hasBuffs = (item.buffs and table.getn(item.buffs) > 0)
            if buffFilter ~= nil and hasBuffs ~= buffFilter then buffMatch = false end

            -- Conjured Filter
            local conjuredMatch = true
            if conjuredFilter ~= nil and item.conjured ~= conjuredFilter then conjuredMatch = false end

            if buffMatch and conjuredMatch then
                table.insert(items, {name=item.name, level=item.level_req})
            end
        end
    end
    
    -- Sort High Level -> Low Level
    table.sort(items, function(a,b) return a.level > b.level end)
    
    local keys = {}
    for _, v in ipairs(items) do table.insert(keys, v.name) end
    return keys
end
