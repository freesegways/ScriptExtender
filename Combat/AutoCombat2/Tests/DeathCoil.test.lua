-- Combat/AutoCombat2/Tests/DeathCoil.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/DeathCoil.test.lua

-- 1. Mock Environment
if not error then
    error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end
end

-- Mock logic dependencies
ScriptExtender_TalentCache = { HasTalent = function() return false end }
ScriptExtender_WarlockSpells = nil -- clear previous load

-- 2. Load System Under Test
local f = io.open("Combat/AutoCombat2/Classes/WarlockSpells.lua", "r")
if not f then
    print("Error: Cannot open WarlockSpells.lua"); os.exit(1)
end
f:close()
dofile("Combat/AutoCombat2/Classes/WarlockSpells.lua")

if not ScriptExtender_WarlockSpells["Death Coil"] then
    print("FAIL: Death Coil not defined in WarlockSpells.lua yet.")
    return -- Expected failure until implemented
end

local dc = ScriptExtender_WarlockSpells["Death Coil"]
local scoreFunc = dc.score

-- 3. Define Helper for Assertions
local function CheckScore(caseName, playerHP, mobTargetPlayer, rangeBucket, expectedScoreMin, expectedScoreMax)
    local player = { hpPct = playerHP, name = "Player" }
    local mob = {
        target = (mobTargetPlayer and "Player" or "Other"),
        rangeBucket = rangeBucket
    }
    local ws = {}

    local score = scoreFunc(mob, ws, player)

    if score >= expectedScoreMin and score <= expectedScoreMax then
        print("PASS: " .. caseName .. " -> Score: " .. score)
    else
        print("FAIL: " ..
        caseName .. " -> Score: " .. score .. " (Expected " .. expectedScoreMin .. "-" .. expectedScoreMax .. ")")
    end
end

print("Running Death Coil Scoring Tests (With Range Penalty)...")

-- Case 1: Safe (Bucket 0)
-- 90% HP, Melee, No Aggro -> Pressure 10. (Below 45). Score 0.
CheckScore("Safe", 90, false, 0, 0, 0)

-- Case 2: Trading Blows (Bucket 0 - Melee) - GOOD
-- 70% HP, Melee, Aggro -> Pressure (30+25)=55. (55-45)*6 = 60. Factor 1.0. Score 60.
CheckScore("Trading Blows (Melee)", 70, true, 0, 60, 60)

-- Case 3: Danger (Bucket 2 - 20y) - RARE
-- 35% HP, Range 20y. Pressure 65. Base (65-45)*6 = 120.
-- Factor 0.1 (Rare) -> 12.
CheckScore("Danger (20y)", 35, false, 2, 12, 12)

-- Case 4: Critical (Bucket 0 - Melee) - MUST CAST
-- 20% HP, Melee, Aggro -> Pressure (80+25)=105. Base (105-45)*6 = 360.
-- Factor 1.0 -> 360.
CheckScore("Critical (Melee)", 20, true, 0, 360, 360)

-- Case 5: Critical (Bucket 3 - 30y+) - AVOID
-- 20% HP, Range 30y+. Pressure 80 (No aggro bonus). Base (80-45)*6 = 210.
-- Factor 0.0 -> 0.
CheckScore("Critical (30y)", 20, true, 3, 0, 0)

-- Case 6: Critical (Bucket 1 - ~10y) - RARE/OK
-- 20% HP, Range 10y. Pressure 80. Base 210.
-- Factor 0.5 -> 105.
CheckScore("Critical (Close 10y)", 20, true, 1, 105, 105)
