-- Features/NextSpells.test.lua

ScriptExtender_Tests["NextSpells"] = function(t)
    -- Mocks
    local messages = {}

    -- Mock DEFAULT_CHAT_FRAME to capture output
    t.Mock("DEFAULT_CHAT_FRAME", {
        AddMessage = function(self, msg)
            table.insert(messages, msg)
        end
    })

    local mockClass = "PRIEST"
    local mockLevel = 1

    -- Mock WoW API
    t.Mock("UnitClass", function(unit)
        if unit == "player" then return "Priest", mockClass end
    end)

    t.Mock("UnitLevel", function(unit)
        if unit == "player" then return mockLevel end
    end)

    -- Mock Spell Data
    local originalData = ScriptExtender_SpellLevels
    -- We'll just define the global directly since the runner doesn't support complex table patching easily
    -- But wait, ScriptExtender_SpellLevels is global. We can just modify it and rely on RestoreMocks?
    -- Tests/Core.lua RestoreMocks iterates over `Original` and calls setglobal.
    -- It only captures things mocked via t.Mock.
    -- So for table modification, we should probably manually save/restore or just use t.Mock to replace the WHOLE table.

    t.Mock("ScriptExtender_SpellLevels", {
        PRIEST = {
            [1] = { { name = "Spell Level 1", learnCost = 10 } },
            [4] = { { name = "Spell Level 4", learnCost = 100 } },
            [6] = { { name = "Spell Level 6", learnCost = 200 } },
        }
    })

    local NextSpellsHandler = SlashCmdList["NEXTSPELLS"]
    t.Assert(NextSpellsHandler, "NextSpells handler should be registered in SlashCmdList")

    -- Test Case 1: Level 1 Priest, Next spells at Level 4
    messages = {}
    mockLevel = 1
    NextSpellsHandler()

    local foundHeader = false
    local foundSpell = false
    local foundCost = false

    for _, msg in ipairs(messages) do
        if string.find(msg, "Next Spells at Level 4") then foundHeader = true end
        if string.find(msg, "Spell Level 4") then foundSpell = true end
        if string.find(msg, "1s") then foundCost = true end
    end

    t.Assert(foundHeader, "Level 1: Should find 'Next Spells at Level 4' header")
    t.Assert(foundSpell, "Level 1: Should list 'Spell Level 4'")
    t.Assert(foundCost, "Level 1: Should show cost formatted as 1s")

    -- Test Case 2: Level 4 Priest, Next spells at Level 6
    messages = {}
    mockLevel = 4
    NextSpellsHandler()

    foundHeader = false
    for _, msg in ipairs(messages) do
        if string.find(msg, "Next Spells at Level 6") then foundHeader = true end
    end
    t.Assert(foundHeader, "Level 4: Should find 'Next Spells at Level 6' header")

    -- Test Case 3: Level 6 Priest, No future spells
    messages = {}
    mockLevel = 6
    NextSpellsHandler()

    local foundEnd = false
    for _, msg in ipairs(messages) do
        if string.find(msg, "max known spell level") then foundEnd = true end
    end
    t.Assert(foundEnd, "Level 6: Should report max known spell level")
end
