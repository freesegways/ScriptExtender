-- Consumables/UseSmartWater.test.lua

ScriptExtender_Tests["UseSmartWater_Efficiency_Check"] = function(t)
    local usedBag, usedSlot = nil, nil
    local currentMana = 1000

    t.Mock("UnitAffectingCombat", function() return false end)
    t.Mock("UnitBuff", function() return nil end)

    t.Mock("UnitMana", function() return currentMana end)
    t.Mock("UnitManaMax", function() return 4000 end) -- Deficit = 3000

    -- Items: Small (1000), Medium (2934), Big (4200)
    -- We expect Medium to be chosen (closest match >= 80% of 3000)
    local inventory = {
        ["Small Water"] = 5,
        ["Medium Water"] = 5,
        ["Big Water"] = 5
    }

    t.Mock("ScriptExtender_GetSortedFoodItems", function(type)
        return { "Small Water", "Medium Water", "Big Water" }
    end)

    -- Mock DB for restoration values (simulating Constants/FoodAndWater.lua)
    _G.TURTLE_FOOD_DB = {
        { name = "Small Water",  level_req = 15, type = "Drink" }, -- ~835
        { name = "Medium Water", level_req = 45, type = "Drink" }, -- ~2934
        { name = "Big Water",    level_req = 55, type = "Drink" }  -- ~4200
    }

    t.Mock("GetContainerNumSlots", function() return 10 end)
    t.Mock("GetContainerItemLink", function(b, s)
        if inventory["Medium Water"] > 0 then return "item:123:Medium Water" end
        return nil
    end)
    -- Override mock to simulate finding all items
    t.Mock("GetContainerItemLink", function(b, s)
        if s == 1 then return "item:1:Small Water" end
        if s == 2 then return "item:2:Medium Water" end
        if s == 3 then return "item:3:Big Water" end
        return nil
    end)

    t.Mock("GetContainerItemInfo", function(b, s) return "texture", 5 end)
    t.Mock("string.find", function(a, b) return string.find(a, b) end) -- Use real string.find

    t.Mock("UseContainerItem", function(b, s)
        usedBag = b; usedSlot = s
    end)

    -- Run
    currentMana = 1000 -- Deficit 3000
    -- 0.8 * 3000 = 2400.
    -- Small (835) < 2400 (SKIP)
    -- Medium (2934) > 2400 (MATCH!)
    -- Big (Skip, already found match)

    UseSmartWater()

    t.Assert(usedSlot == 2, "Should have used Medium Water (Slot 2) for 3000 deficit.")
end

ScriptExtender_Tests["UseSmartWater_FullMana"] = function(t)
    local usedItem = false
    t.Mock("UnitAffectingCombat", function() return false end)
    t.Mock("UnitBuff", function() return nil end)
    t.Mock("UnitMana", function() return 100 end)
    t.Mock("UnitManaMax", function() return 100 end)
    t.Mock("UseContainerItem", function() usedItem = true end)

    UseSmartWater()

    t.Assert(not usedItem, "Should NOT drink if mana is full.")
end
