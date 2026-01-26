-- Tests for UseSmartFood
-- Tests: Combat Block, Full HP Block, Conjured Choice, Efficiency Choice

-- 1. CONJURED PREFERENCE
ScriptExtender_Tests["UseSmartFood_Pref_Conjured"] = function(t)
    -- Inventory:
    -- 1. Roast Quail (Normal, Lvl 55, heals 2000)
    -- 2. Conjured Bun (Conjured, Lvl 55, heals 2000)
    -- Should eat Bun.
    local usedBag, usedSlot = nil, nil

    t.Mock("UnitAffectingCombat", function() return false end)
    t.Mock("UnitHealthMax", function() return 5000 end)
    t.Mock("UnitHealth", function() return 3000 end) -- Missing 2000

    -- Mock Bag
    t.Mock("GetContainerNumSlots", function(b) return 5 end)
    t.Mock("GetContainerItemLink", function(b, s)
        if b == 0 and s == 1 then return "item:123:[Roast Quail]" end
        if b == 0 and s == 2 then return "item:456:[Conjured Sweet Roll]" end
        return nil
    end)

    -- Mock Utils DB Helper (Crucial!)
    -- We can't mock the global variable TURTLE_FOOD_DB easily unless we overwrite it?
    -- Or we mock the script logic?
    -- Actually the script logic iterates TURTLE_FOOD_DB global.
    -- We should assume the real DB is loaded?
    -- IF NOT, we must populate a fake one.

    local BACKUP_DB = TURTLE_FOOD_DB
    TURTLE_FOOD_DB = {
        { name = "Roast Quail",         level_req = 55, type = "Food", conjured = false },
        { name = "Conjured Sweet Roll", level_req = 55, type = "Food", conjured = true }
    }

    t.Mock("UseContainerItem", function(b, s)
        usedBag = b
        usedSlot = s
    end)

    UseSmartFood()

    -- Restore
    TURTLE_FOOD_DB = BACKUP_DB

    t.AssertEqual({ actual = usedSlot, expected = 2 })
end

-- 2. EFFICIENCY CHECK
ScriptExtender_Tests["UseSmartFood_Effectiveness"] = function(t)
    -- Missing 500 HP.
    -- Inv:
    -- 1. Quail (Heals ~2500)
    -- 2. Bread (Heals ~60)
    -- 3. Apple (Heals ~800) -- Matches best!
    -- Should eat Apple.
    local usedSlot = nil

    t.Mock("UnitAffectingCombat", function() return false end)
    t.Mock("UnitHealthMax", function() return 5000 end)
    t.Mock("UnitHealth", function() return 4500 end) -- Missing 500

    t.Mock("GetContainerNumSlots", function(b) return 5 end)
    t.Mock("GetContainerItemLink", function(b, s)
        if b == 0 and s == 1 then return "nm:[Roast Quail]" end
        if b == 0 and s == 2 then return "nm:[Bread]" end
        if b == 0 and s == 3 then return "nm:[Apple]" end
        return nil
    end)

    local BACKUP_DB = TURTLE_FOOD_DB
    TURTLE_FOOD_DB = {
        { name = "Roast Quail", level_req = 55, type = "Food", conjured = false }, -- ~2550
        { name = "Apple",       level_req = 25, type = "Food", conjured = false }, -- ~874 (Closest to 500)
        { name = "Bread",       level_req = 1,  type = "Food", conjured = false }  -- ~61
    }

    t.Mock("UseContainerItem", function(b, s) usedSlot = s end)

    UseSmartFood()
    TURTLE_FOOD_DB = BACKUP_DB

    t.AssertEqual({ actual = usedSlot, expected = 3 })
end
