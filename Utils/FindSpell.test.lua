ScriptExtender_Tests["Utils_FindSpell"] = function(t)
    -- Verify FindSpell command searches spellbook AND database

    local printOutput = {}

    -- Mock Deps
    t.Mock("ScriptExtender_Print", function(msg)
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

    -- Mock Database
    ScriptExtender_SpellLevels = {
        ["MAGE"] = {
            [1] = {
                { name = "Fireball" }
            }
        }
    }

    -- Test 1: Search Spellbook
    FindSpell("Fireball")

    -- Check output for match
    local found = false
    for _, line in ipairs(printOutput) do
        if string.find(line, "ID: 1 | Fireball") then
            found = true
        end
    end
    t.Assert(found, "Should find Fireball in Spellbook")

    -- Test 2: Search Database
    found = false
    for _, line in ipairs(printOutput) do
        if string.find(line, "MAGE Lvl 1") and string.find(line, "Fireball") then
            found = true
        end
    end
    t.Assert(found, "Should find Fireball in Database")

    -- Test 3: Case Insensitive
    printOutput = {}
    FindSpell("fireball")
    found = false
    for _, line in ipairs(printOutput) do
        if string.find(line, "ID: 1 | Fireball") then
            found = true
        end
    end
    t.Assert(found, "Should find Fireball (case insensitive)")
end
