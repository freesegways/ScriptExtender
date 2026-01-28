-- Combat/AutoCombat2/Tests/CooldownTracker.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/CooldownTracker.test.lua

-- 1. Mock WoW Environment
if not error then
    error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end
end
if not ScriptExtender_Error then
    ScriptExtender_Error = function(msg) print("MOCK SE ERROR: " .. msg) end
end

-- Mock Time
local MockTime = 1000
function GetTime() return MockTime end

-- 2. Load System Under Test
local PathConstraints = {
    "Combat/AutoCombat2/Cache/CooldownTracker.lua",
    "../Cache/CooldownTracker.lua"
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
    print("CRITICAL: Failed to load CooldownTracker.lua"); return
end

-- 3. Test Cases
print("Running CooldownTracker Tests...")

-- Ensure clean state
ScriptExtender_CooldownTracker.cooldowns = {}

-- Test 1: IsReady when never set
if ScriptExtender_CooldownTracker.IsReady("TestSpell") then
    print("PASS: Spell is ready by default.")
else
    print("FAIL: Spell should be ready if never set.")
end

-- Test 2: Set Cooldown
ScriptExtender_CooldownTracker.Set("TestSpell", 10) -- COOLDOWN for 10s (Ends at 1010)

if not ScriptExtender_CooldownTracker.IsReady("TestSpell") then
    print("PASS: Spell is not ready immediately after Set.")
else
    print("FAIL: Spell should be on cooldown.")
end

-- Test 3: Advance Time PARTIALLY
MockTime = 1005
local remain = ScriptExtender_CooldownTracker.GetRemaining("TestSpell")
if remain == 5 then
    print("PASS: Remaining time correct (5s).")
else
    print("FAIL: Remaining time incorrect. Got: " .. tostring(remain))
end

-- Test 4: Advance Time FULLY
MockTime = 1011
if ScriptExtender_CooldownTracker.IsReady("TestSpell") then
    print("PASS: Spell is ready after duration.")
else
    print("FAIL: Spell should be ready after time passes.")
end
