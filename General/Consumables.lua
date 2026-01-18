-- Helper to sort items by Level (Descending)
local function GetSortedItems(typeFilter, buffFilter, conjuredFilter)
    local items = {}
    
    -- Iterate array-based DB
    for _, item in ipairs(TURTLE_FOOD_DB) do
        local typeMatch = false
        if typeFilter == "Food" and (item.type == "Food" or item.type == "Food & Drink") then typeMatch = true end
        if typeFilter == "Drink" and (item.type == "Drink" or item.type == "Food & Drink") then typeMatch = true end
        
        if typeMatch then
            -- Buff Filter
            local buffMatch = true
            -- Check if buffs table matches requirement
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

ScriptExtender_Register("UseBestBuffFood", "Scans bags for the best available Stats Food (Well Fed) and eats it.")
function UseBestBuffFood()
    -- Get sorted list of Buff Foods ("Food", Buff=true)
    local foods = GetSortedItems("Food", true, nil)

    for _, name in ipairs(foods) do
        for b=0,4 do
            for s=1,GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b,s)
                if link and string.find(link, name) then
                    -- Find item helper
                    local level = 0
                    for _, item in ipairs(TURTLE_FOOD_DB) do
                         if item.name == name then level = item.level_req break end
                    end

                    ScriptExtender_Log("Eating (Buff): " .. name .. " (Lvl " .. level .. ")")
                    UseContainerItem(b,s)
                    return
                end
            end
        end
    end
    ScriptExtender_Log("No stat buff food found!")
end


ScriptExtender_Register("UseBestBandage", "Scans bags for the best available bandage and uses it on self.")
function UseBestBandage()
    -- Kept local as Bandages are not yet in the DB
    local bandages = {
        "Heavy Runecloth Bandage", "Runecloth Bandage", 
        "Heavy Mageweave Bandage", "Mageweave Bandage", 
        "Heavy Silk Bandage", "Silk Bandage", 
        "Heavy Wool Bandage", "Wool Bandage", 
        "Heavy Linen Bandage", "Linen Bandage" 
    }

    for _, name in ipairs(bandages) do
        for b=0,4 do
            for s=1,GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b,s)
                if link and string.find(link, name) then
                    ScriptExtender_Log("Using Bandage: " .. name)
                    UseContainerItem(b,s)
                    if SpellIsTargeting() then
                        SpellTargetUnit("player")
                    end
                    return
                end
            end
        end
    end
    ScriptExtender_Log("No bandages found!")
end


ScriptExtender_Register("UseBestWater", "Finds the best available water and drinks it.")
function UseBestWater()
    if UnitAffectingCombat("player") then
        ScriptExtender_Print("Error: You are in combat and cannot drink!")
        return
    end

    -- Get sorted list of Drink ("Drink", Buff=any, Conjured=any)
    local drinks = GetSortedItems("Drink", nil, nil)

    local foundBag, foundSlot, foundLink = nil, nil, nil
    local bestDrinkName = ""

    -- Check Sorted Drinks
    for _, name in ipairs(drinks) do
        for b = 0, 4 do
            for s = 1, GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b, s)
                if link and string.find(link, name) then
                    foundBag = b
                    foundSlot = s
                    foundLink = link
                    bestDrinkName = name
                    break
                end
            end
            if foundBag then break end
        end
        if foundBag then break end
    end

    -- If no water found
    if not foundBag then
        ScriptExtender_Print("Error: No water found in your bags.")
        return
    end

    UseContainerItem(foundBag, foundSlot)

    -- Count Remaining
    local totalCount = 0
    for b = 0, 4 do
       for s = 1, GetContainerNumSlots(b) do
          local link = GetContainerItemLink(b,s)
          if link and string.find(link, bestDrinkName) then
             local _, count = GetContainerItemInfo(b,s)
             totalCount = totalCount + count
          end
       end
    end

    local remaining = totalCount - 1
    if remaining < 0 then remaining = 0 end
    ScriptExtender_Log("Drank: " .. bestDrinkName .. ". Total Left: " .. remaining)
end

-- Heuristic to estimate health restored based on Level Requirement
local function EstimateFoodHeal(level)
    if level >= 55 then return 2550 end
    if level >= 45 then return 2148 end
    if level >= 35 then return 1392 end
    if level >= 25 then return 874 end
    if level >= 15 then return 552 end
    if level >= 5 then return 243 end
    return 61 -- Level 0/1
end

ScriptExtender_Register("UseSmartFood", "Intelligently eats food. Prioritizes Conjured items. For normal food, picks the most efficient item based on missing HP.")
function UseSmartFood()
    if UnitAffectingCombat("player") then
        ScriptExtender_Print("Error: You are in combat and cannot eat!")
        return
    end

    local missingHP = UnitHealthMax("player") - UnitHealth("player")
    if missingHP <= 0 then
        ScriptExtender_Print("You are already at full health.")
        return
    end

    local bagFoods = {} -- List of {name=name, level=level, conjured=bool, bag=b, slot=s}
    
    -- Scan bags for valid non-buff foods
    for b=0,4 do
        for s=1,GetContainerNumSlots(b) do
            local link = GetContainerItemLink(b,s)
            if link then
                -- Match against DB
                for _, item in ipairs(TURTLE_FOOD_DB) do
                    if (item.type == "Food" or item.type == "Food & Drink") then
                        -- Check if non-buff (empty buffs table)
                        local isBuffFood = (item.buffs and table.getn(item.buffs) > 0)
                        
                        if not isBuffFood and string.find(link, item.name) then
                            table.insert(bagFoods, {
                                name = item.name,
                                level = item.level_req,
                                conjured = item.conjured,
                                bag = b,
                                slot = s,
                                heal = EstimateFoodHeal(item.level_req)
                            })
                            break -- stop checking DB for this bag slot
                        end
                    end
                end
            end
        end
    end

    if table.getn(bagFoods) == 0 then
        ScriptExtender_Print("No normal food found!")
        return
    end

    -- Selection Logic
    local bestCandidate = nil
    local bestReason = ""

    -- 1. Check for Conjured (Priority: High Level -> Low Level)
    local conjuredFoods = {}
    for _, f in ipairs(bagFoods) do
        if f.conjured then table.insert(conjuredFoods, f) end
    end

    if table.getn(conjuredFoods) > 0 then
        table.sort(conjuredFoods, function(a,b) return a.level > b.level end)
        bestCandidate = conjuredFoods[1]
        bestReason = "Best Conjured"
    else
        -- 2. Normal Food Logic (Efficiency)
        -- We want the SMALLEST healing food that is >= missingHP
        -- If none are >= missingHP, we want the LARGEST healing food available.

        local candidates = {}
        for _, f in ipairs(bagFoods) do table.insert(candidates, f) end
        
        -- Sort by Heal Amount Ascending (Small -> Large)
        table.sort(candidates, function(a,b) return a.heal < b.heal end)

        local efficientFood = nil
        for _, f in ipairs(candidates) do
            if f.heal >= missingHP then
                efficientFood = f
                break -- Found the smallest one that does the job
            end
        end

        if efficientFood then
            bestCandidate = efficientFood
            bestReason = "Efficient (Needs " .. missingHP .. ", Heals ~" .. bestCandidate.heal .. ")"
        else
            -- None were big enough, picking the biggest one (last in sorted list)
            bestCandidate = candidates[table.getn(candidates)]
            bestReason = "Max Healing (Needs " .. missingHP .. ", Heals ~" .. bestCandidate.heal .. ")"
        end
    end

    if bestCandidate then
        ScriptExtender_Log("Eating: " .. bestCandidate.name .. " [" .. bestReason .. "]")
        UseContainerItem(bestCandidate.bag, bestCandidate.slot)
    end
end

local health_regen = {
    "Major Healthstone",
    "Great Healthstone",
    "Healthstone",
    "Lesser Healthstone",
    "Major Healing Potion", 
    "Superior Healing Potion",
    "Great Healing Potion", 
    "Healing Potion", 
    "Lesser Healing Potion",
    "Minor Healing Potion",
}

ScriptExtender_Register("UseBestHealthRegen", "Uses the best Healthstone or Potion available.")
function UseBestHealthRegen()
    for _, name in ipairs(health_regen) do
        for b=0,4 do 
            for s=1,GetContainerNumSlots(b) do
                local n=GetContainerItemLink(b,s) 
                if n and string.find(n, name) then 
                    ScriptExtender_Log("Using Health Item: " .. name)
                    UseContainerItem(b,s) 
                    return
                end 
            end 
        end 
    end
    ScriptExtender_Log("No health potions or healthstones found!")
end

local mana_regen = {
    -- Highest Tier Mana Potions (Prioritized by Mana Restored)
    "Major Mana Potion", 
    "Superior Mana Potion",
    "Great Mana Potion", 
    "Mana Potion", 
    "Lesser Mana Potion",
    "Minor Mana Potion",
    -- Specialty/Unique Mana Items
    "Balor Moonshine",
    "Dark Rune",
    "Demonic Rune"
}

ScriptExtender_Register("UseBestManaRegen", "Uses the best Mana Potion or Rune available.")
function UseBestManaRegen()
    for _, name in ipairs(mana_regen) do
        for b=0,4 do 
            for s=1,GetContainerNumSlots(b) do
                local n=GetContainerItemLink(b,s) 
                if n and string.find(n, name) then 
                    ScriptExtender_Log("Using Mana Item: " .. name)
                    UseContainerItem(b,s) 
                    return
                end 
            end 
        end 
    end
    ScriptExtender_Log("No mana potions or runes found!")
end

ScriptExtender_Log('Consumables Loaded successfully')
