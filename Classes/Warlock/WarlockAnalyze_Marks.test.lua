ScriptExtender_Tests["WarlockAnalyze_Marks"] = function(t)
    -- Verify scoring priority for Raid Targets (Skull > Cross > Normal)

    -- Mock Data
    local currentMark = 0
    local markScores = {}

    -- Mocks
    t.Mock("UnitLevel", function(u) return 60 end)
    t.Mock("UnitHealth", function(u) return 2000 end)
    t.Mock("UnitHealthMax", function(u) return 2000 end)
    t.Mock("UnitName", function(u) return "Mob" end)
    t.Mock("GetTime", function() return 1000 end)
    t.Mock("UnitExists", function(u) return true end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitIsFriend", function(u) return false end)
    t.Mock("UnitAffectingCombat", function(u) return true end) -- must be in combat
    t.Mock("UnitPowerType", function(u) return 0 end)
    t.Mock("UnitMana", function(u) return 1000 end)
    t.Mock("UnitManaMax", function(u) return 1000 end)
    t.Mock("UnitClassification", function(u) return "normal" end)
    t.Mock("UnitDebuff", function(u, i) return nil end)
    t.Mock("UnitBuff", function(u, i) return nil end)
    t.Mock("ScriptExtender_GetSpellDamage", function() return 100 end)
    t.Mock("GetSpellCooldown", function() return 0, 0, 1 end)
    t.Mock("ScriptExtender_HasTalent", function(n) return true end)

    -- IMPORTANT: Mock ScriptExtender_GetTargetPriority directly
    t.Mock("ScriptExtender_GetTargetPriority", function(u)
        if currentMark == 8 then return 4 end -- Skull
        if currentMark == 7 then return 3 end -- Cross
        return 2                              -- Normal (0/None)
    end)

    WD_Track = {}
    WD_MarkSafe = {} -- Reset global safety tracker to avoid pollution from other tests

    -- TEST 1: Unmarked Score (Prio 2 -> Base 90. Decay 5 -> 85)
    currentMark = 0 -- None -> nil
    local act, type, scoreNone = ScriptExtender_Warlock_Analyze("target", false, 1000)

    -- TEST 2: Skull Score (8 -> Prio 4 -> Base 105. Decay 5 -> 100)
    currentMark = 8
    local act, type, scoreSkull = ScriptExtender_Warlock_Analyze("target", false, 1000)

    -- TEST 3: Cross Score (7 -> Prio 3 -> Base 100. Decay 5 -> 95)
    currentMark = 7
    local act, type, scoreCross = ScriptExtender_Warlock_Analyze("target", false, 1000)

    print("DEBUG: Scores -> Skull: " ..
        tostring(scoreSkull) .. ", Cross: " .. tostring(scoreCross) .. ", None: " .. tostring(scoreNone))

    -- Assert Specific Values to confirm calculation logic
    -- Base Scores: Skull=105, Cross=100, None=90
    -- Decay: -5 (Index 1)
    -- Siphon Bonus (Prio>=3): +10
    -- Skull: 105 - 5 + 10 = 110
    -- Cross: 100 - 5 + 10 = 105
    -- None:   90 - 5 + 0  = 85

    t.AssertEqual(110, scoreSkull, "Skull Score should be 110")
    t.AssertEqual(105, scoreCross, "Cross Score should be 105")
    t.AssertEqual(85, scoreNone, "None Score should be 85")

    t.Assert(scoreSkull > scoreCross, "Skull Score should be higher than Cross")
    t.Assert(scoreCross > scoreNone, "Cross Score should be higher than None")
end
