-- Tests for Warlock Logic

ScriptExtender_Tests["DeleteExcessShards_Check"] = function(t)
    -- SCENARIO: Limit 2. Have 4 Shards.
    -- Bag 4 (Soul Bag): 3 Shards.
    -- Bag 0 (Backpack): 1 Shard.
    -- Logic iterates 0->4.
    -- Count:
    -- Bag0 Slot1: Shard (Count 1) -> Keep
    -- Bag4 Slot1: Shard (Count 2) -> Keep
    -- Bag4 Slot2: Shard (Count 3) -> DELETE
    -- Bag4 Slot3: Shard (Count 4) -> DELETE

    local deletedCount = 0

    t.Mock("GetContainerNumSlots", function(b)
        if b == 0 or b == 4 then return 3 else return 0 end
    end)

    t.Mock("GetContainerItemLink", function(b, s)
        if b == 0 and s == 1 then return "Soul Shard" end
        if b == 4 and s == 1 then return "Soul Shard" end
        if b == 4 and s == 2 then return "Soul Shard" end
        if b == 4 and s == 3 then return "Soul Shard" end
        return nil
    end)

    t.Mock("PickupContainerItem", function() end)
    t.Mock("DeleteCursorItem", function() deletedCount = deletedCount + 1 end)

    DeleteExcessShards(2)

    t.AssertEqual(deletedCount, 2, "Should delete exactly 2 excess shards.")
end
