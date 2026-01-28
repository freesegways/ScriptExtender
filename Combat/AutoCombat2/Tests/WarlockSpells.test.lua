-- Combat/AutoCombat2/Tests/WarlockSpells.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/WarlockSpells.test.lua

-- 1. Mock Environment
if not error then error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end end

-- 2. Load System Under Test
local PathConstraints = {
    "Combat/AutoCombat2/Classes/WarlockSpells.lua",
    "../Classes/WarlockSpells.lua"
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
    print("CRITICAL: Failed to load WarlockSpells.lua"); return
end

-- 3. Test Setup
print("Running WarlockSpells Tests...")

local function CreateMockMob(name, hpPct, isElite, myDebuffs)
    return {
        name = name,
        hpPct = hpPct,
        classification = isElite and "elite" or "normal",
        debuffCheck = {
            myDebuffs = myDebuffs or {},
            hasCC = false
        },
        target = "Tank",
        debuffs = {} -- Legacy compat
    }
end

local function CreatePlayer(hpPct, manaPct)
    return {
        name = "Player",
        hpPct = hpPct,
        manaPct = manaPct
    }
end

local ws = { mobCount = 1 }

-- Test 1: Corruption Scoring
local t1_mob = CreateMockMob("Trash", 100, false, {})
local s1 = ScriptExtender_WarlockSpells["Corruption"].score(t1_mob, ws, CreatePlayer(100, 100))
if s1 == 60 then
    print("PASS: Corruption base score correct (60).")
else
    print("FAIL: Corruption base score wrong. Got: " .. tostring(s1))
end

-- Test 2: Corruption Already Exists
local t2_mob = CreateMockMob("Trash", 100, false, { ["Corruption"] = true })
local s2 = ScriptExtender_WarlockSpells["Corruption"].score(t2_mob, ws, CreatePlayer(100, 100))
if s2 == 0 then
    print("PASS: Corruption score is 0 when already acting.")
else
    print("FAIL: Corruption score should be 0. Got: " .. tostring(s2))
end

-- Test 3: Shadow Bolt Execute
local t3_mob = CreateMockMob("Boss", 25, true, {})
local s3 = ScriptExtender_WarlockSpells["Shadow Bolt"].score(t3_mob, ws, CreatePlayer(100, 100))
if s3 == 70 then -- 30 base + 40 execute
    print("PASS: Shadow Bolt execute score correct (70).")
else
    print("FAIL: Shadow Bolt execute score wrong. Got: " .. tostring(s3))
end

-- Test 4: Life Tap (Low Mana)
local p_low = CreatePlayer(100, 10) -- 10% Mana
local s4 = ScriptExtender_WarlockSpells["Life Tap"].score(nil, ws, p_low)
if s4 == 90 then                    -- 100 - 10
    print("PASS: Life Tap high score on low mana.")
else
    print("FAIL: Life Tap score wrong. Got: " .. tostring(s4))
end

-- Test 5: Life Tap (Unsafe)
local p_unsafe = CreatePlayer(20, 10) -- 20% HP (Unsafe)
local s5 = ScriptExtender_WarlockSpells["Life Tap"].score(nil, ws, p_unsafe)
if s5 == 0 then
    print("PASS: Life Tap score 0 when HP unsafe.")
else
    print("FAIL: Life Tap score should be 0. Got: " .. tostring(s5))
end
