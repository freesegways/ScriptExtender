-- Ultra-Lightweight Unit Testing Framework for WoW 1.12
-- usage: /se RunTests

ScriptExtender_Tests = {}
local Mocks = {}
local Original = {}
local CurrentTestFailed = false

-- --- ASSERTIONS ---

local function Assert(condition, msg)
    if not condition then
        ScriptExtender_Print("[FAIL] " .. msg)
        CurrentTestFailed = true
        return false
    else
        return true
    end
end

local function AssertEqual(actual, expected, msg)
    if actual ~= expected then
        msg = msg or "Assertion Failed"
        ScriptExtender_Print("[FAIL] " ..
            msg .. " (Expected: " .. tostring(expected) .. ", Got: " .. tostring(actual) .. ")")
        CurrentTestFailed = true
        return false
    else
        return true
    end
end

-- --- MOCKING ---

-- Temporarily replace a global API function
function Mock(funcName, mockFunc)
    if not Original[funcName] then
        Original[funcName] = getglobal(funcName)
    end
    setglobal(funcName, mockFunc)
end

-- Restore all mocked functions
function RestoreMocks()
    for name, func in pairs(Original) do
        setglobal(name, func)
    end
    Original = {}
    Mocks = {}
end

-- --- RUNNER ---

ScriptExtender_Register("RunTests", "Runs the internal test suite.")
function RunTests()
    ScriptExtender_Print("=== Running Tests ===")
    local pass = 0
    local fail = 0

    -- Sorting tests for consistent order (Optional but nice)
    local testNames = {}
    for n in pairs(ScriptExtender_Tests) do table.insert(testNames, n) end
    table.sort(testNames)

    for _, name in ipairs(testNames) do
        ScriptExtender_Print("Running: " .. name)
        local testFunc = ScriptExtender_Tests[name]

        -- Setup Environment (Clean start)
        RestoreMocks()
        CurrentTestFailed = false -- Reset status

        local status, err = pcall(testFunc, { Assert = Assert, AssertEqual = AssertEqual, Mock = Mock })

        if status then
            if CurrentTestFailed then
                fail = fail + 1
            else
                pass = pass + 1
            end
        else
            ScriptExtender_Print("[ERR] " .. name .. ": " .. err)
            fail = fail + 1
        end

        -- Cleanup
        RestoreMocks()
    end

    ScriptExtender_Print("Result: " .. pass .. " Passed, " .. fail .. " Failed.")
    ScriptExtender_Print("=== Done ===")
end
