ScriptExtender_Tests["AutoWarlockBuffs_CraftAllRanks"] = function(t)
    local castSpells = {}
    local bagItems = {}
    local knownSpells = {}

    -- Config
    local PLAYER_LEVEL = 60
    local MANA = 3000

    -- Mocks
    t.Mock("UnitLevel", function(u) return PLAYER_LEVEL end)
    t.Mock("UnitMana", function(u) return MANA end)
    t.Mock("UnitClass", function(u) return "Warlock", "WARLOCK" end)
    t.Mock("GetTime", function() return 1000 end)
    t.Mock("GetPlayerBuff", function() return -1 end) -- No buffs
    t.Mock("GetContainerNumSlots", function(b) return 16 end)

    -- Mock Spells (Knows all up to level)
    -- Mock Spells (Knows all up to level)
    knownSpells["Create Healthstone (Major)"] = 101
    knownSpells["Create Healthstone (Greater)"] = 102
    knownSpells["Create Healthstone"] = 103

    ScriptExtender_IsSpellLearned = function(s) return knownSpells[s] ~= nil end
    ScriptExtender_GetSpellID = function(s) return knownSpells[s] end

    t.Mock("CastSpellByName", function(s) table.insert(castSpells, s) end)
    t.Mock("CastSpell", function(id, book) table.insert(castSpells, "ID:" .. id) end)
    t.Mock("ScriptExtender_Print", function(msg) end)
    t.Mock("ScriptExtender_Log", function(msg) end)

    -- Mock Bag
    -- Start with "Major Healthstone" and "Soul Shard"
    bagItems = {
        { name = "Major Healthstone", link = "|cff1eff00|Hitem:9421:0:0:0|h[Major Healthstone]|h|r" },
        { name = "Soul Shard",        link = "|cff1eff00|Hitem:6265:0:0:0|h[Soul Shard]|h|r" },
        { name = "Soul Shard",        link = "|cff1eff00|Hitem:6265:0:0:0|h[Soul Shard]|h|r" }
    }

    local function FindItemInBag(itemName)
        -- Linear search mock
        for _, item in ipairs(bagItems) do
            if item.name == itemName then return 1, 1 end -- Dummy slot
        end
        return nil, nil
    end

    -- We need to access the LOCAL FindItemInBag inside AutoWarlockBuffs?
    -- No, AutoWarlockBuffs defines a local helper. We cannot mock a local function easily from outside unless we inject dependencies or globalize it.
    -- However, the AutoWarlockBuffs file calls `CreateFrame`, `GetContainerItemLink`, etc.
    -- We can mock `GetContainerItemLink`.

    t.Mock("GetContainerItemLink", function(bag, slot)
        -- Iterate bagItems to simulate content?
        -- For simplicity, let's map slot 1..N to items.
        if bag == 0 and slot <= table.getn(bagItems) then
            return bagItems[slot].link
        end
        return nil
    end)

    -- But FindItemInBag iterates 0..4 and slots.
    -- Our mock GetContainerItemLink needs to be consistent.

    -- IMPORTANT: AutoWarlockBuffs uses a LOCAL 'FindItemInBag'.
    -- We cannot overwrite it directly.
    -- But it depends on `GetContainerNumSlots` and `GetContainerItemLink`.
    -- So mocking those is the correct way.

    -- Step 1: Run. Expect it to skip Major (Have it) and Craft Greater (Missing).
    AutoWarlockBuffs(5)

    local foundGreater = false
    for _, s in ipairs(castSpells) do
        if s == "ID:102" then foundGreater = true end
    end
    t.Assert(foundGreater, "Should have crafted Greater Healthstone (missing rank).")

    -- Step 2: Add Greater to bag, Clear spells, run again.
    table.insert(bagItems,
        { name = "Greater Healthstone", link = "|cff1eff00|Hitem:5512:0:0:0|h[Greater Healthstone]|h|r" })
    castSpells = {}

    AutoWarlockBuffs(5)

    local foundNormal = false
    for _, s in ipairs(castSpells) do
        if s == "ID:103" then foundNormal = true end
    end
    t.Assert(foundNormal, "Should have crafted Normal Healthstone (missing rank).")

    -- Check that we did NOT craft Major (already have it)
    local foundMajor = false
    for _, s in ipairs(castSpells) do
        if s == "ID:101" then foundMajor = true end
    end
    t.Assert(not foundMajor, "Should NOT have crafted Major Healthstone (already have it).")
end
