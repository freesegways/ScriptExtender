-- Tests/GlobalUtils.test.lua
-- Run with: lua Tests/GlobalUtils.test.lua

-- 1. Mock WoW Environment
if not error then
    error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end
end

-- Mock Globals required by ScriptExtender.lua
DEFAULT_CHAT_FRAME = { AddMessage = function() end }
SlashCmdList = {}
function CreateFrame()
    return {
        RegisterEvent = function() end,
        SetScript = function() end
    }
end

function getglobal(name) return nil end

-- 2. Load the System Under Test
local PathConstraints = {
    "ScriptExtender.lua",
    "../ScriptExtender.lua"
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
    print("CRITICAL: Could not find ScriptExtender.lua")
    return
end

-- 3. Test Cases
print("Running GlobalUtils Tests...")

-- Test 1: Verify Error Thrown
local status, err = pcall(function()
    ScriptExtender_Error("Test Failure Message")
end)

if status then
    print("FAIL: ScriptExtender_Error did not throw an error.")
else
    -- Test 2: Verify Message Formatting
    if string.find(err, "ScriptExtender: Test Failure Message") then
        print("PASS: Error correctly formatted and thrown.")
    else
        print("FAIL: Error message format incorrect. Got: " .. tostring(err))
    end
end
