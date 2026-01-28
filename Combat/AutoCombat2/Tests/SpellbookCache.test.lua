-- Combat/AutoCombat2/Tests/SpellbookCache.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/SpellbookCache.test.lua

-- 1. Mock WoW Environment
if not error then
    error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end
end
if not ScriptExtender_Error then
    ScriptExtender_Error = function(msg) print("MOCK SE ERROR: " .. msg) end
end
BOOKTYPE_SPELL = "spell"

-- Mock Spellbook
local MockSpells = {
    [1] = { "Attack", "" },
    [2] = { "Shadow Bolt", "Rank 1" },
    [3] = { "Corruption", "Rank 1" },
    [4] = { "Shadow Bolt", "Rank 2" }, -- ID 4 is Max Rank for Shadow Bolt
    [5] = { "Demon Skin", "Rank 1" }
}
function GetSpellName(id, bookType)
    if MockSpells[id] then
        return MockSpells[id][1], MockSpells[id][2]
    end
    return nil
end

-- 2. Load System Under Test
local PathConstraints = {
    "Combat/AutoCombat2/Cache/SpellbookCache.lua",
    "../Cache/SpellbookCache.lua"
}
local loaded = false
for _, path in ipairs(PathConstraints) do
    local f = io.open(path, "r")
    if f then
        f:close()
        dofile(path)
        loaded = true
        break
    end
end
if not loaded then
    print("CRITICAL: Failed to load SpellbookCache.lua"); return
end

-- 3. Test Cases
print("Running SpellbookCache Tests...")

ScriptExtender_SpellbookCache.Update()

-- Test 1: Max Rank Retrieval
local sbMaxId = ScriptExtender_SpellbookCache.GetSpellID("Shadow Bolt")
if sbMaxId == 4 then
    print("PASS: Retrieved max rank (2) for Shadow Bolt.")
else
    print("FAIL: Max rank ID incorrect. Got: " .. tostring(sbMaxId))
end

-- Test 2: Specific Rank Retrieval
local sbRank1Id = ScriptExtender_SpellbookCache.GetSpellID("Shadow Bolt", 1)
if sbRank1Id == 2 then
    print("PASS: Retrieved specific rank (1) for Shadow Bolt.")
else
    print("FAIL: Rank 1 ID incorrect. Got: " .. tostring(sbRank1Id))
end

-- Test 3: Spell without rank number (Attack)
local attackId = ScriptExtender_SpellbookCache.GetSpellID("Attack")
if attackId == 1 then
    print("PASS: Retrieved ID for rank-less spell (Attack).")
else
    print("FAIL: Attack ID incorrect. Got: " .. tostring(attackId))
end

-- Test 4: Missing Spell
if ScriptExtender_SpellbookCache.GetSpellID("NonExistent") == nil then
    print("PASS: Returns nil for missing spell.")
else
    print("FAIL: Returned ID for missing spell.")
end
