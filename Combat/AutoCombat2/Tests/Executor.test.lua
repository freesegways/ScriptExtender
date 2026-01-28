-- Combat/AutoCombat2/Tests/Executor.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/Executor.test.lua

-- 1. Mock WoW Environment
if not error then error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end end
BOOKTYPE_SPELL = "spell"

-- Mock State
local CurrentTarget = nil
local CastLog = {}

function UnitName(u)
    if u == "player" then return "Me" end
    if u == "target" then return CurrentTarget end
    if u == "party1target" then return "Mob A" end
    return nil
end

function TargetUnit(u)
    if u == "party1target" then CurrentTarget = "Mob A" end
end

function CastSpellByName(name)
    table.insert(CastLog, "name:" .. name)
end

function CastSpell(id, book)
    table.insert(CastLog, "id:" .. id)
end

-- Mock Spellbook
ScriptExtender_SpellbookCache = {
    GetSpellID = function(name) return 1 end -- All spells ID 1
}

-- 2. Load System Under Test
local f = io.open("Combat/AutoCombat2/Core/Executor.lua", "r")
if f then
    f:close(); dofile("Combat/AutoCombat2/Core/Executor.lua")
end
if not ScriptExtender_Executor then
    print("CRITICAL: Failed to load Executor"); return
end


-- 3. Test Cases
print("Running Executor Tests...")

-- Scenario 1: Self Cast (Life Tap)
local actionSelf = { action = "Life Tap", target = "player", unit = "player" }
local listSelf = { actionSelf }

ScriptExtender_Executor.Execute(listSelf, {})
if CastLog[1] == "name:Life Tap" then
    print("PASS: Self cast executed via CastSpellByName.")
else
    print("FAIL: Self cast failed. Log: " .. tostring(CastLog[1]))
end

-- Scenario 2: Target Switch & Cast
CastLog = {}
CurrentTarget = nil -- No target

local actionAttack = { action = "Shadow Bolt", target = "Mob_Pseudo", unit = "party1target" }
local listAttack = { actionAttack }

ScriptExtender_Executor.Execute(listAttack, {})

-- Expect: TargetUnit called, then CastSpell
if CurrentTarget == "Mob A" then
    print("PASS: Target switched to unit.")
else
    print("FAIL: Target not switched.")
end

if CastLog[1] == "id:1" then
    print("PASS: Spell cast on unit.")
else
    print("FAIL: Spell not cast. Log: " .. tostring(CastLog[1]))
end

-- Scenario 3: Fallback (Target Switch Fails)
CastLog = {}
CurrentTarget = nil
-- Mock TargetUnit failure (target doesn't change)
local oldTargetUnit = TargetUnit
TargetUnit = function(u) end -- Do nothing

local listFail = {
    { action = "Shadow Bolt", unit = "party1target" },          -- Should fail targeting
    { action = "Life Tap",    target = "player",    unit = "player" } -- Should succeed as fallback
}

ScriptExtender_Executor.Execute(listFail, {})

if CastLog[1] == "name:Life Tap" then
    print("PASS: Fallback to second action after targeting failure.")
else
    print("FAIL: Expected fallback to Life Tap. Log: " .. tostring(CastLog[1]))
end

-- Cleanup
TargetUnit = oldTargetUnit
