ScriptExtender_Tests["WarlockPetAnalyze_Outcomes"] = function(t)
    -- Verify Pet Decison Outcomes independent of specific score numbers.
    -- Priority: CC Safety > Tanking Target > Skull > Cross > High Prio Marks > Others.

    -- Mocks
    local currentMob = { index = 0, name = "Mob", debuffs = {} }
    local playerTarget = "TargetA" -- Player's current target

    t.Mock("UnitExists", function(u) return true end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitIsFriend", function(u) return false end)
    t.Mock("UnitAffectingCombat", function(u) return true end) -- In Combat
    t.Mock("UnitDebuff", function(u, i) return currentMob.debuffs[i] end)
    t.Mock("GetRaidTargetIndex", function(u) return currentMob.index end)

    -- Mock UnitIsUnit
    t.Mock("UnitIsUnit", function(u1, u2)
        -- Simulation: "targettarget" == "player" (Tanking check)
        -- We'll control this via a global toggle for the test
        if u1 == "targettarget" and u2 == "player" then return currentMob.isTankingPlayer end
        -- Stickiness: target == pettarget
        if u1 == "target" and u2 == "pettarget" then return currentMob.isPetTarget end
        return false
    end)

    -- Mock Context (Minimal)
    local ctx = {}

    -- TEST 1: CC Safety (Outcome: NIL action)
    currentMob.debuffs = { "Polymorph" }
    -- Mock CC Texture check
    ScriptExtender_CCTextures = { "Polymorph" }

    local act, type, scoreCC = ScriptExtender_Warlock_PetAnalyze("target", false, ctx)
    t.AssertEqual({ actual = act, expected = nil })

    -- Clear CC
    currentMob.debuffs = {}

    -- TEST 2: Skull Priority (Outcome: High Score)
    currentMob.index = 8 -- Skull
    local act, type, scoreSkull = ScriptExtender_Warlock_PetAnalyze("target", false, ctx)
    t.AssertEqual({ actual = act, expected = "PetAttack" })

    -- TEST 3: Cross Priority (Outcome: Score < Skull)
    currentMob.index = 7 -- Cross
    local act, type, scoreCross = ScriptExtender_Warlock_PetAnalyze("target", false, ctx)
    t.AssertEqual({ actual = act, expected = "PetAttack" })
    t.Assert(scoreSkull > scoreCross, "Outcome: Skull should have higher priority than Cross.")

    -- TEST 4: Tanking Priority (Outcome: Score > Skull)
    -- Even if Unmarked, if it is attacking Player, it should be top priority (Peel).
    currentMob.index = 0
    currentMob.isTankingPlayer = true
    local act, type, scoreTanking = ScriptExtender_Warlock_PetAnalyze("target", false, ctx)

    -- Note: My logic in PetAnalyze adds +50. Skull base is 40. 20+50 = 70 > 40.
    t.Assert(scoreTanking > scoreSkull, "Outcome: Mob attacking Player should be prioritized over generic Skull.")

    -- TEST 5: Seduce Logic (Outcome: Seduction Action)
    currentMob.isTankingPlayer = false
    currentMob.index = 5 -- Moon (Seduce Target)
    local act, type, scoreSeduce = ScriptExtender_Warlock_PetAnalyze("target", false, ctx)
    t.AssertEqual({ actual = act, expected = "Seduction" })
    t.AssertEqual({ actual = type, expected = "pet_cc" })
end
