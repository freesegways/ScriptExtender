-- Combat/AutoCombat2/Tests/RangeSlotCache.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/RangeSlotCache.test.lua

-- 1. Mock WoW Environment
if not error then
    error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end
end
if not ScriptExtender_Error then
    ScriptExtender_Error = function(msg) print("MOCK SE ERROR: " .. msg) end
end

-- Mock Action Slots
local MockSlots = {
    [1] = "Attack",
    [5] = "Hammer of Justice",
    [12] = "Corruption"
}
function HasAction(slot) return MockSlots[slot] ~= nil end

function GetActionTexture(slot) return "Interface\\Icons\\Inv_Misc_QuestionMark" end

-- Mock Tooltip
ScriptExtender_TooltipTextLeft1 = {
    SetText = function(self, msg) self.text = msg end,
    GetText = function(self) return self.text end,
    text = nil
}
ScriptExtender_Tooltip = {
    SetOwner = function() end,
    SetAction = function(self, slot)
        ScriptExtender_TooltipTextLeft1:SetText(MockSlots[slot])
    end
}
WorldFrame = {}

-- 2. Load System Under Test
local PathConstraints = {
    "Combat/AutoCombat2/Cache/RangeSlotCache.lua",
    "../Cache/RangeSlotCache.lua"
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
    print("CRITICAL: Failed to load RangeSlotCache.lua"); return
end

-- 3. Test Cases
print("Running RangeSlotCache Tests...")

-- Verify Initial State
if not ScriptExtender_RangeSlotCache.cache then
    print("FAIL: Cache table missing initialization.")
end

-- Run Update
ScriptExtender_RangeSlotCache.Update()

-- Test 1: Expect 'Hammer of Justice' at slot 5
local hojSlot = ScriptExtender_RangeSlotCache.GetSlot("Hammer of Justice")
if hojSlot == 5 then
    print("PASS: Correctly mapped Hammer of Justice to slot 5.")
else
    print("FAIL: HOJ mapping incorrect. Got: " .. tostring(hojSlot))
end

-- Test 2: Expect 'Corruption' at slot 12
local corrSlot = ScriptExtender_RangeSlotCache.GetSlot("Corruption")
if corrSlot == 12 then
    print("PASS: Correctly mapped Corruption to slot 12.")
else
    print("FAIL: Corruption mapping incorrect. Got: " .. tostring(corrSlot))
end

-- Test 3: Missing Spell
local missing = ScriptExtender_RangeSlotCache.GetSlot("Shadow Bolt")
if missing == nil then
    print("PASS: Returns nil for missing spell.")
else
    print("FAIL: Returned slot for missing spell: " .. tostring(missing))
end
