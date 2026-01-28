-- Tests/DataIntegrity.test.lua
-- Run with: lua Tests/DataIntegrity.test.lua

-- 1. Mock WoW Environment
if not error then
    error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end
end
if not ScriptExtender_Error then
    ScriptExtender_Error = function(msg) print("MOCK SE ERROR: " .. msg) end
end

-- 2. Load System Under Test
local PathConstraints = {
    "BuffsAndDebuffs.lua",
    "Constants/BuffsAndDebuffs.lua",
    "../Constants/BuffsAndDebuffs.lua"
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
    print("CRITICAL: Could not find BuffsAndDebuffs.lua")
    return
end

-- 3. Test Cases
print("Running DataIntegrity Tests...")

-- Verify ClassDebuffs Table (Exists)


-- Verify ClassDebuffs Table
if not ScriptExtender_ClassDebuffs then
    print("FAIL: ScriptExtender_ClassDebuffs is missing.")
else
    if ScriptExtender_ClassDebuffs.Warlock and ScriptExtender_ClassDebuffs.Warlock["Corruption"] then
        print("PASS: ClassDebuffs contains Warlock data.")
    else
        print("FAIL: ClassDebuffs missing Warlock data.")
    end
end
