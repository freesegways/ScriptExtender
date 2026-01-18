-- Tests for Mana Logic (Colocated)

ScriptExtender_Tests["UseSmartMana_Efficiency_Check"] = function(t)
    -- SCENARIO:
    -- Max Mana: 2000, Current: 1000 (Deficit 1000)
    -- Bag 0, Slot 1: Major Mana (1800) -> Waste
    -- Bag 0, Slot 2: Mana Potion (520) -> Safe

    local usedBag, usedSlot = nil, nil

    t.Mock("UnitManaMax", function(u) return 2000 end)
    t.Mock("UnitMana", function(u) return 1000 end)
    t.Mock("GetContainerNumSlots", function(b) return 5 end)
    t.Mock("GetContainerItemLink", function(b, s)
        if b == 0 and s == 1 then return "item:13444:[Major Mana Potion]" end
        if b == 0 and s == 2 then return "item:3385:[Mana Potion]" end
        return nil
    end)
    t.Mock("GetContainerItemCooldown", function() return 0, 0, 1 end)
    t.Mock("UseContainerItem", function(b, s)
        usedBag = b
        usedSlot = s
    end)

    UseSmartMana()

    t.AssertEqual(usedBag, 0, "Should use Bag 0")
    t.AssertEqual(usedSlot, 2, "Should use Slot 2 (Efficient Potion).")
end

ScriptExtender_Tests["UseSmartMana_Panic_Check"] = function(t)
    -- SCENARIO: Max 1000, Curr 50 (5%) -> PANIC
    -- Bag 0, Slot 1: Major Mana (1800) -> Huge waste but allowed due to panic

    local usedBag, usedSlot = nil, nil

    t.Mock("UnitManaMax", function(u) return 1000 end)
    t.Mock("UnitMana", function(u) return 50 end)

    t.Mock("GetContainerNumSlots", function(b) return 5 end)
    t.Mock("GetContainerItemLink", function(b, s)
        if b == 0 and s == 1 then return "item:13444:[Major Mana Potion]" end
        return nil
    end)
    t.Mock("GetContainerItemCooldown", function() return 0, 0, 1 end)
    t.Mock("UseContainerItem", function(b, s)
        usedBag = b
        usedSlot = s
    end)

    UseSmartMana()

    t.AssertEqual(usedBag, 0, "Should use Bag 0")
    t.AssertEqual(usedSlot, 1, "Should use Slot 1 (Major) despite waste.")
end
