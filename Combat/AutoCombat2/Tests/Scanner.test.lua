-- Combat/AutoCombat2/Tests/Scanner.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/Scanner.test.lua

-- 1. Mock WoW Environment
if not error then
    error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end
end
if not ScriptExtender_Error then
    ScriptExtender_Error = function(msg) print("MOCK SE ERROR: " .. msg) end
end

-- Mock Globals
function UnitHealth(u) return 100 end

function UnitHealthMax(u) return 100 end

function UnitMana(u) return 100 end

function UnitManaMax(u) return 100 end

function UnitAffectingCombat(u) return true end

function UnitName(u)
    if u == "target" then return "Defias Bandit" end
    return nil
end

function UnitLevel(u) return 10 end

function UnitClassification(u) return "normal" end

function UnitCreatureType(u) return "Humanoid" end

function GetRaidTargetIndex(u) return 8 end -- Skull

function CheckInteractDistance(u, index)
    if index == 2 then return true end      -- 10y range
    return false
end

function UnitDebuff(u, i)
    -- Mock: Index 1 = Corruption
    if i == 1 then return "Interface\\Icons\\Spell_Shadow_Abomination" end
    return nil
end

function UnitClass() return "Warlock", "WARLOCK" end

function UnitExists(u) return (u == "target") end

function UnitIsDead(u) return false end

function UnitCanAttack(u1, u2) return true end

-- Mock Constants
ScriptExtender_CCTextures = { "Polymorph" }
ScriptExtender_ClassDebuffs = {
    WARLOCK = {
        ["Corruption"] = { texture = "Abomination", stackable = true }
    }
}

-- 2. Load System Under Test
-- We need to load Scanner, but Scanner might depend on GlobalUtils (which we don't strictly need if we mock SE_Error)
local PathConstraints = {
    "Combat/AutoCombat2/Core/Scanner.lua",
    "../Core/Scanner.lua"
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
    print("CRITICAL: Failed to load Scanner.lua"); return
end

-- 3. Test Cases
print("Running Scanner Tests...")

-- Verify Initialization
if not ScriptExtender_Scanner then
    print("FAIL: Scanner table missing.")
    return
end

-- Test 1: Basic Scan & PseudoID Generation
local ws = ScriptExtender_Scanner.Scan()
local mobCount = 0
local lastID = nil

for id, mob in pairs(ws.mobs) do
    mobCount = mobCount + 1
    lastID = id

    -- Verify Data Population
    if mob.name == "Defias Bandit" then
        print("PASS: Mob name captured.")
    else
        print("FAIL: Mob name incorrect. Got: " .. tostring(mob.name))
    end

    -- Verify Range Bucket (Mocked to 10y -> Bucket 1)
    if mob.rangeBucket == 1 then
        print("PASS: Range Bucket correct (1).")
    else
        print("FAIL: Range Bucket incorrect. Got: " .. tostring(mob.rangeBucket))
    end

    -- Verify Debuffs (Corruption)
    if mob.debuffCheck.myDebuffs["Corruption"] then
        print("PASS: Corruption detected and owned.")
    else
        print("FAIL: Corruption not detected/owned.")
    end
end

if mobCount == 1 then
    print("PASS: Found exactly 1 mob.")
else
    print("FAIL: Mob count incorrect. Got: " .. mobCount)
end

-- Test 2: PseudoID Stability
-- Run Scan again with exact same mock data
local ws2 = ScriptExtender_Scanner.Scan()
local newID = nil
for id, _ in pairs(ws2.mobs) do newID = id end

if newID == lastID then
    print("PASS: PseudoID is stable given same state.")
else
    print("FAIL: PseudoID changed! " .. tostring(lastID) .. " -> " .. tostring(newID))
end

-- Test 3: PseudoID Sensitivity (Change HP Bucket)
-- Modifying Global Mock for next run
UnitHealth = function(u) return 10 end -- 10% HP -> Bucket 1 (was 100% -> Bucket 10)
local ws3 = ScriptExtender_Scanner.Scan()
local changedID = nil
for id, _ in pairs(ws3.mobs) do changedID = id end

if changedID ~= lastID then
    print("PASS: PseudoID changed when HP Bucket changed.")
else
    print("FAIL: PseudoID did NOT change despite HP drop.")
end
