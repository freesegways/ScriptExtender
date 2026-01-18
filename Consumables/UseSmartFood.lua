-- UseSmartFood Script
-- Depends on: Constants/FoodAndWater.lua

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

ScriptExtender_Register("UseSmartFood",
    "Intelligently eats food. Prioritizes Conjured items. For normal food, picks the most efficient item based on missing HP.")
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
    for b = 0, 4 do
        for s = 1, GetContainerNumSlots(b) do
            local link = GetContainerItemLink(b, s)
            if link then
                -- Match against DB
                for _, item in ipairs(TURTLE_FOOD_DB) do
                    if (item.type == "Food" or item.type == "Food & Drink") then
                        -- Check if non-buff (empty buffs table)
                        local isBuffFood = (item.buffs and table.getn(item.buffs) > 0)

                        if not isBuffFood and string.find(link, "%[" .. item.name .. "%]") then
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
        table.sort(conjuredFoods, function(a, b) return a.level > b.level end)
        bestCandidate = conjuredFoods[1]
        bestReason = "Best Conjured"
    else
        -- 2. Normal Food Logic (Efficiency)
        -- We want the SMALLEST healing food that is >= missingHP
        -- If none are >= missingHP, we want the LARGEST healing food available.

        local candidates = {}
        for _, f in ipairs(bagFoods) do table.insert(candidates, f) end

        -- Sort by Heal Amount Ascending (Small -> Large)
        table.sort(candidates, function(a, b) return a.heal < b.heal end)

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
