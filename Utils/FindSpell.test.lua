ScriptExtender_Tests["Utils_FindSpell"] = function(t)
    -- Verify FindSpell command searches spellbook AND database

    local printOutput = {}

    -- Mock Logs
    t.Mock("ScriptExtender_Log", function(msg)
        table.insert(printOutput, msg)
    end)

    -- Mock Spellbook
    local mockSpells = {
        [1] = "Fireball",
        [2] = "Frostbolt"
    }

    t.Mock("GetSpellName", function(i, bookType)
        if bookType ~= "spell" then return nil end
        return mockSpells[i]
    end)

    -- Test 1: Search Spellbook
    local results = FindSpells("Fireball")
    t.Assert(results, "Should return results table")
    t.Assert(table.getn(results) == 1, "Should find 1 match")
    t.Assert(results[1].name == "Fireball", "Match name incorrect")
    t.Assert(results[1].index == 1, "Match index incorrect")

    -- Test 2: Case Insensitive
    results = FindSpells("fireball")
    t.Assert(table.getn(results) == 1, "Should find 1 match (case insensitive)")
    t.Assert(results[1].name == "Fireball", "Match name incorrect")
end
