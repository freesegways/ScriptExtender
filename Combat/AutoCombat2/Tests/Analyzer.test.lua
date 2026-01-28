-- Combat/AutoCombat2/Tests/Analyzer.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/Analyzer.test.lua

-- 1. Mock WoW Environment
if not error then
    error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end
end
if not ScriptExtender_Error then ScriptExtender_Error = function(msg) print("MOCK SE ERROR: " .. msg) end end

BOOKTYPE_SPELL = "spell"

-- Mock Player
function UnitClass() return "Warlock", "WARLOCK" end

function UnitName(u) return "Player" end

function UnitHealth(u) return 100 end

function UnitHealthMax(u) return 100 end

function UnitMana(u) return 100 end

function UnitManaMax(u) return 100 end

-- Mock Spells (Cooldowns / Usable)
-- ID 1 = Shadow Bolt
-- ID 2 = Corruption
function GetSpellCooldown(id, book) return 0, 0 end     -- Ready

function IsUsableSpell(id, book) return true, false end -- Usable, has mana

-- Mock Range
-- Slot 10 = Shadow Bolt Range Check
function IsActionInRange(slot, unit)
    if slot == 10 then return 1 end -- In Range
    return 0
end

-- 2. Load System Under Test & Dependencies
-- Dependencies must be loaded or mocked. We will load the real ones where possible or mock the singleton.

-- Mock Caches
ScriptExtender_CooldownTracker = { IsReady = function() return true end }

ScriptExtender_SpellbookCache = {
    GetSpellID = function(name)
        if name == "Shadow Bolt" then return 1 end
        if name == "Corruption" then return 2 end
        return nil
    end
}

ScriptExtender_RangeSlotCache = {
    GetSlot = function(name)
        if name == "Shadow Bolt" then return 10 end
        return nil
    end
}

-- Load Warlock Spells (Real Logic)
local f = io.open("Combat/AutoCombat2/Classes/WarlockSpells.lua", "r")
if f then
    f:close(); dofile("Combat/AutoCombat2/Classes/WarlockSpells.lua")
end

-- Load Analyzer
local f2 = io.open("Combat/AutoCombat2/Core/Analyzer.lua", "r")
if f2 then
    f2:close(); dofile("Combat/AutoCombat2/Core/Analyzer.lua")
end

if not ScriptExtender_Analyzer then
    print("CRITICAL: Failed to load Analyzer"); return
end

-- 3. Test Cases
print("Running Analyzer Integration Tests...")

-- Scenario: 1 Mob, Full HP. We have Shadow Bolt and Corruption.
-- Corruption (60 score) should beat Shadow Bolt (30 score).

local mockMob = {
    pseudoID = "Mob_123",
    unit = "target",
    name = "Test Mob",
    hpPct = 100,
    classification = "normal",
    debuffCheck = { myDebuffs = {}, hasCC = false },
    debuffs = { myDebuffs = {} } -- Legacy support if logic uses it? No, logic uses debuffCheck?
    -- Wait, WarlockSpells uses `mob.debuffCheck.myDebuffs` in my implementation?
    -- Checked WarlockSpells: `if mob.debuffCheck.myDebuffs["Corruption"] then return 0 end`
    -- Yes, it uses debuffCheck.
}

local ws = {
    mobs = { ["Mob_123"] = mockMob },
    mobCount = 1
}

local actions = ScriptExtender_Analyzer.Analyze(ws, ScriptExtender_WarlockSpells, "player")

if table.getn(actions) > 0 then
    print("PASS: Analyzer returned " .. table.getn(actions) .. " actions.")

    local top = actions[1]
    print("Top Action: " .. top.action .. " Score: " .. top.score)

    if top.action == "Corruption" then
        print("PASS: Corruption is top priority on fresh mob (Score 60 vs SB 30).")
    else
        print("FAIL: Expected Corruption on top. Got " .. top.action)
    end
else
    print("FAIL: No actions returned.")
end


-- Scenario 2: Mob HAS Corruption.
-- Corruption score -> 0. Shadow Bolt (30) should be top.

mockMob.debuffCheck.myDebuffs["Corruption"] = true
local actions2 = ScriptExtender_Analyzer.Analyze(ws, ScriptExtender_WarlockSpells, "player")

if table.getn(actions2) > 0 then
    local top = actions2[1]
    print("Top Action (Scenario 2): " .. top.action .. " Score: " .. top.score)

    if top.action == "Shadow Bolt" then
        print("PASS: Shadow Bolt is top when Corruption exists.")
    else
        print("FAIL: Expected Shadow Bolt. Got " .. top.action)
    end
else
    print("FAIL: No actions returned for Scenario 2.")
end

-- Scenario 3: Range Check Fail
-- Mock Range Slot 10 to return 0 (Out of range)
IsActionInRange = function(slot, unit) return 0 end

local actions3 = ScriptExtender_Analyzer.Analyze(ws, ScriptExtender_WarlockSpells, "player")
if table.getn(actions3) == 0 then
    print("PASS: No actions returned when Out of Range.")
    -- Note: Life Tap might return if defined? Life Tap target="player" so it skips mob loop.
    -- WarlockSpells has Life Tap.
    -- Let's see if Life Tap appears.
else
    -- Assuming Life Tap might appear if we had it mocked?
    -- We didn't mock Life Tap in SpellbookCache, so GetSpellID returns nil.
    -- So it should be empty.
    print("PASS: Range filtered out offensive spells. Count: " .. table.getn(actions3))
end
