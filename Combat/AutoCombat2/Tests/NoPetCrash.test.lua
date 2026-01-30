-- Combat/AutoCombat2/Tests/NoPetCrash.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/NoPetCrash.test.lua

-- 1. Mock WoW Environment
if not error then
    error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end
end
if not ScriptExtender_Log then ScriptExtender_Log = function(msg) print("LOG: " .. msg) end end
if not ScriptExtender_Error then ScriptExtender_Error = function(msg) print("ERROR: " .. msg) end end
if not table.getn then table.getn = function(t) return #t end end

-- Mock API
function UnitClass() return "Warlock", "WARLOCK" end

function UnitName(u) return "Player" end

function UnitHealth() return 100 end

function UnitHealthMax() return 100 end

-- 2. Mock Classes
ScriptExtender_CooldownTracker = { IsReady = function() return true end }
ScriptExtender_SpellbookCache = { IsReady = function() return true end }
ScriptExtender_PetCache = {
    IsReady = function() return false end,
    actions = {}
}

-- 3. Load Project Files
dofile("Combat/AutoCombat2/Classes/WarlockPetSpells.lua")
dofile("Combat/AutoCombat2/Core/Analyzer.lua")

print("Running NoPetCrash Test Case...")

local ws = {
    mobs = {
        ["Mob_1"] = {
            pseudoID = "Mob_1",
            unit = "target",
            isTarget = true,
            inCombat = true,
            foundInRange = true,
            rangeBucket = 0,
            debuffs = { hasCC = false },
            target = "None"
        }
    },
    context = {
        pet = nil, -- CRITICAL: NO PET
        inCombat = true,
        playerHP_Pct = 100,
        playerMana_Pct = 100,
        playerShards = 1
    },
    aggregations = {
        mobCount = 1
    }
}

local params = {
    worldState = ws,
    spellTables = {
        pet = ScriptExtender_WarlockPetSpells
    },
    casterUnit = "player"
}

-- We use pcall to catch the crash
local status, err = pcall(function()
    ScriptExtender_Analyzer.Analyze(params)
end)

if not status then
    print("FAIL: Analyzer crashed as expected: " .. tostring(err))
    os.exit(1)
else
    print("PASS: Analyzer handled nil pet context without crashing.")
end
