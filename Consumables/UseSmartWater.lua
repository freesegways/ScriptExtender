-- Consumables/UseSmartWater.lua
-- Intelligently selects the best water to use based on missing mana.
-- Uses cheaper water for small deficits to save gold/resources.

ScriptExtender_Register("UseSmartWater", "Intelligently drinks water based on missing mana.")

function UseSmartWater()
    if UnitAffectingCombat("player") then
        ScriptExtender_Print("Error: You are in combat and cannot drink!")
        return
    end

    -- 1. Check if already drinking
    for i = 1, 16 do
        local b = UnitBuff("player", i)
        if not b then break end
        if string.find(b, "Drink") or string.find(b, "Bottle") then
            return -- Already drinking
        end
    end

    local current = UnitMana("player")
    local max = UnitManaMax("player")
    local deficit = max - current

    -- 2. Full Mana Check
    if deficit <= 0 then
        -- ScriptExtender_Log("Mana is already full.") -- Optional logging
        return
    end

    -- 3. Get all available drinks
    local drinks = ScriptExtender_GetSortedFoodItems("Drink", nil, nil)
    local drinksWithStats = {}

    -- Filter available drinks
    for _, name in ipairs(drinks) do
        local count = 0
        local foundBag, foundSlot
        for b = 0, 4 do
            for s = 1, GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b, s)
                if link and string.find(link, name) then
                    local _, c = GetContainerItemInfo(b, s)
                    count = count + c
                    if not foundBag then
                        foundBag = b; foundSlot = s
                    end
                end
            end
        end

        if count > 0 then
            -- Find stats from DB
            local restore = 0
            for _, item in ipairs(TURTLE_FOOD_DB) do
                if item.name == name then
                    -- Approximate mana restoration for now or if defined in DB
                    -- Fallback logic based on level req if explicit mana not in DB
                    if item.buffs and item.buffs[1] and item.buffs[1].stat == "Mana" then
                        restore = item.buffs[1].amount
                    elseif item.level_req >= 55 then
                        restore = 4200
                    elseif item.level_req >= 45 then
                        restore = 2934
                    elseif item.level_req >= 35 then
                        restore = 1992
                    elseif item.level_req >= 25 then
                        restore = 1344
                    elseif item.level_req >= 15 then
                        restore = 835
                    elseif item.level_req >= 5 then
                        restore = 436
                    else
                        restore = 151
                    end

                    -- Conjured Preference Check (Optional: Give bonus weight to mage water?)
                    if item.conjured then
                        -- Maybe prioritize conjured equal to regular? For now we just list it.
                    end
                    break
                end
            end

            table.insert(drinksWithStats, {
                name = name,
                restore = restore,
                bag = foundBag,
                slot = foundSlot,
                count = count,
                is_conjured = (string.find(name, "Conjured") ~= nil) -- Quick check or use DB
            })
        end
    end

    if table.getn(drinksWithStats) == 0 then
        ScriptExtender_Print("Error: No water found!")
        return
    end

    -- 4. Find Best Match
    -- Logic: Find the smallest water that covers at least 80% of the deficit,
    -- OR the biggest water if deficit is huge.
    -- Prefer Conjured items if they satisfy the requirement to save gold.

    local bestDrink = nil

    -- Sort by Restoration Amount (Ascending)
    table.sort(drinksWithStats, function(a, b) return a.restore < b.restore end)

    for _, d in ipairs(drinksWithStats) do
        -- If this drink covers the deficit (with slight buffer)
        if d.restore >= (deficit * 0.8) then
            bestDrink = d

            -- Optimization: If we found a valid regular drink, check if there is a comparable Conjured one
            -- Scan remaining drinks to see if a Conjured one is close in value
            for j = _, table.getn(drinksWithStats) do
                local nextD = drinksWithStats[j]
                if nextD.is_conjured and nextD.restore >= (deficit * 0.8) then
                    bestDrink = nextD  -- Switch to conjured because it's free
                    break
                end
            end
            break
        end
    end

    -- If no drink was big enough, use the biggest one (last in sorted list)
    if not bestDrink then
        bestDrink = drinksWithStats[table.getn(drinksWithStats)]
    end

    -- Execute
    if bestDrink then
        ScriptExtender_Log("SmartWater: Need " ..
        deficit .. ". Using " .. bestDrink.name .. " (~" .. bestDrink.restore .. ").")
        UseContainerItem(bestDrink.bag, bestDrink.slot)
    end
end
