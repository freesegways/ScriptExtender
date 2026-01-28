-- Combat/AutoCombat2/Tests/DebuffPriority.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/DebuffPriority.test.lua

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
    "Combat/AutoCombat2/Cache/DebuffPriority.lua",
    "../Cache/DebuffPriority.lua" -- Relative to test file if run from Tests dir
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
    print("CRITICAL: Could not find DebuffPriority.lua")
    return
end

-- 3. Test Cases
print("Running DebuffPriority Tests...")

if not ScriptExtender_DebuffPriority then
    print("FAIL: ScriptExtender_DebuffPriority is missing.")
else
    local count = 0
    for k, v in pairs(ScriptExtender_DebuffPriority) do
        count = count + 1
        if type(v.type) ~= "string" or type(v.priority) ~= "number" then
            print("FAIL: Invalid entry for " .. k)
        end
    end

    if count > 0 then
        print("PASS: DebuffPriority table has " .. count .. " entries.")

        -- Spot check a known value
        if ScriptExtender_DebuffPriority["Polymorph"] and ScriptExtender_DebuffPriority["Polymorph"].priority == 100 then
            print("PASS: Polymorph priority is 100.")
        else
            print("FAIL: Polymorph priority incorrect or missing.")
        end
    else
        print("FAIL: DebuffPriority table is empty.")
    end
end
