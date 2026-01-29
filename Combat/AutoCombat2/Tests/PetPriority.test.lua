-- Combat/AutoCombat2/Tests/PetPriority.test.lua
-- Run with: lua Combat/AutoCombat2/Tests/PetPriority.test.lua

-- 1. Mock WoW Environment
if not error then error = function(msg)
        print("MOCK ERROR: " .. msg); os.exit(1)
    end end
if not ScriptExtender_Log then ScriptExtender_Log = function(msg) print("LOG: " .. msg) end end
if not ScriptExtender_Error then ScriptExtender_Error = function(msg) print("ERROR: " .. msg) end end
if not table.getn then table.getn = function(t) return #t end end

BOOKTYPE_SPELL = "spell"

-- Mock API
function UnitClass() return "Warlock", "WARLOCK" end

function UnitName(u) return "Player" end

function UnitHealth(u) return 100 end

function UnitHealthMax(u) return 100 end

function UnitMana(u) return 100 end

function UnitManaMax(u) return 100 end

function GetTime() return 1000 end

function GetSpellCooldown() return 0, 0 end

function GetPetActionInfo(i) return "PetAttack" end

function GetPetActionCooldown() return 0, 0 end

function IsActionInRange() return 0 end -- Mock range failure

-- 2. Mock Classes
ScriptExtender_CooldownTracker = { IsReady = function() return true end }
ScriptExtender_SpellbookCache = { GetSpellID = function() return 1 end }
ScriptExtender_RangeSlotCache = { GetSlot = function() return 10 end }
ScriptExtender_TalentCache = { HasTalent = function() return false end }

-- 3. Load Project Files
dofile("Combat/AutoCombat2/Classes/WarlockPetSpells.lua")
dofile("Combat/AutoCombat2/Core/Analyzer.lua")

print("Running PetPriority Test Case...")

-- Test Scenario: Player has a target, pet is idle.
-- We want to see if PetAttack is returned even if IsActionInRange fails (command skip)
-- and if score is high.

local ws = {
    mobs = {
        ["Mob_1"] = {
            pseudoID = "Mob_1",
            unit = "target",
            isTarget = true,
            inCombat = false,
            debuffs = { hasCC = false },
            target = "None"
        }
    },
    context = {
        pet = {
            inCombat = false,
            hpPct = 100,
            manaPct = 100
        },
        inCombat = true, -- Player is in combat
        targetPseudoID = "Mob_1"
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

local actions = ScriptExtender_Analyzer.Analyze(params)

if table.getn(actions) > 0 then
    local top = actions[1]
    print("Top Action: " .. top.action .. " Score: " .. top.score)

    -- Score Calculation:
    -- isTarget: 150
    -- idle during combat: 50
    -- Total: 200

    if top.action == "PetAttack" and top.score == 200 then
        print("PASS: PetAttack correctly prioritized with score 200.")
    else
        print("FAIL: Unexpected top action or score. Got: " ..
        tostring(top.action) .. " with score " .. tostring(top.score))
    end
else
    print("FAIL: No actions returned. (Check if range check was correctly skipped for commands)")
end
