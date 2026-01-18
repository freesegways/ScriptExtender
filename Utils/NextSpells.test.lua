-- Utils/NextSpells.test.lua

ScriptExtender_Tests["NextSpells_Filtering"] = function(t)
    -- Mocks
    local messages = {}

    t.Mock("DEFAULT_CHAT_FRAME", {
        AddMessage = function(self, msg)
            table.insert(messages, msg)
        end
    })

    t.Mock("UnitClass", function(unit) return "Priest", "PRIEST" end)
    t.Mock("UnitLevel", function(unit) return 5 end) -- User is level 5

    -- Force the global player class to match our mock
    ScriptExtender_PlayerClass = "PRIEST"

    t.Mock("ScriptExtender_SpellLevels", {
        PRIEST = {
            [4] = {
                { name = "Shadow Word: Pain (Rank 1)", learnCost = 100 },
                { name = "Lesser Heal (Rank 2)",       learnCost = 100 },
            },
            [6] = {
                { name = "Smite (Rank 2)", learnCost = 200 },
            }
        }
    })

    -- Mock Spellbook: Knowledge of Lesser Heal only
    t.Mock("GetNumSpellTabs", function() return 1 end)
    t.Mock("GetSpellTabInfo", function(tab) return "General", "", 0, 1 end)
    t.Mock("GetSpellName", function(index, book)
        if index == 1 then
            return "Lesser Heal", "Rank 2"
        end
        return nil, nil
    end)

    -- Command registry check
    local cmdData = ScriptExtender_Commands["nextspells"]
    t.Assert(cmdData, "NextSpells should be registered.")

    -- Execute
    NextSpells()

    local foundMissedHeader = false
    local foundUpcomingHeader = false
    local foundSWP = false
    local foundSmite = false
    local foundLesserHeal = false
    local foundTotalCost = false

    for _, msg in ipairs(messages) do
        if string.find(msg, "MISSED Spells") then foundMissedHeader = true end
        if string.find(msg, "UPCOMING Spells at Level 6") then foundUpcomingHeader = true end
        if string.find(msg, "Shadow Word: Pain") then foundSWP = true end
        if string.find(msg, "Smite") then foundSmite = true end
        if string.find(msg, "Lesser Heal") then foundLesserHeal = true end
        if string.find(msg, "Total Training Cost") and string.find(msg, "3s") then foundTotalCost = true end
    end

    t.Assert(foundMissedHeader, "Should show MISSED header.")
    t.Assert(foundUpcomingHeader, "Should show UPCOMING header for level 6.")
    t.Assert(foundSWP, "Should show the missed spell (Shadow Word: Pain).")
    t.Assert(foundSmite, "Should show the upcoming spell (Smite).")
    t.Assert(not foundLesserHeal, "Should NOT show already learned spell.")
    t.Assert(foundTotalCost, "Should show combined cost (100c missed + 200c upcoming = 300c = 3s).")

    -- Cleanup
    ScriptExtender_PlayerClass = nil
end
