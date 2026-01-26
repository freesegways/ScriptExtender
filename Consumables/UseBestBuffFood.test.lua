-- Tests for Buff Food Logic

ScriptExtender_Tests["UseBestBuffFood_Filter_Check"] = function(t)
    -- Inventory:
    -- 1. Normal Bread (No Buff)
    -- 2. Sagefish Delight (Buff)
    -- Should eat Sagefish.
    local usedSlot = nil

    -- Mock DB with explicit buff flags
    local BACKUP_DB = TURTLE_FOOD_DB
    TURTLE_FOOD_DB = {
        { name = "Normal Bread",     level_req = 5,  type = "Food" }, -- No buffs table
        { name = "Sagefish Delight", level_req = 30, type = "Food", buffs = { { stat = "mana" } } }
    }

    t.Mock("GetContainerNumSlots", function(b) return 5 end)
    t.Mock("GetContainerItemLink", function(b, s)
        if b == 0 and s == 1 then return "nm:Normal Bread" end
        if b == 0 and s == 2 then return "nm:Sagefish Delight" end
        return nil
    end)
    t.Mock("UseContainerItem", function(b, s) usedSlot = s end)

    UseBestBuffFood()

    TURTLE_FOOD_DB = BACKUP_DB -- Restore

    t.AssertEqual({ actual = usedSlot, expected = 2 })
end
