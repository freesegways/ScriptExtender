ScriptExtender_Tests["WarlockAnalyze_GroupLogic"] = function(t)
    -- Mock Data
    local HP = 1000
    local currentMob = { name = "Mob", hp = HP, hpMax = HP, level = 60, debuffs = {}, classification = "normal" }

    -- Basic Mocks
    t.Mock("UnitLevel", function(u)
        if u == "player" then return 60 end
        return currentMob.level
    end)
    t.Mock("UnitHealth", function(u)
        if u == "player" then return 400 end -- 40% HP to enable Siphon Life
        return currentMob.hp
    end)
    t.Mock("UnitHealthMax", function(u) return currentMob.hpMax end)
    t.Mock("UnitName", function(u) return currentMob.name end)
    t.Mock("GetTime", function() return 1000 end)
    t.Mock("UnitExists", function(u) return true end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitIsFriend", function(u) return false end)
    t.Mock("UnitAffectingCombat", function(u) return true end)
    t.Mock("GetRaidTargetIndex", function(u) return 0 end)
    t.Mock("UnitPowerType", function(u) return 0 end)
    t.Mock("UnitMana", function(u) return 1000 end)
    t.Mock("UnitManaMax", function(u) return 1000 end)
    t.Mock("UnitClassification", function(u) return currentMob.classification end)
    t.Mock("UnitDebuff", function(u, i) return currentMob.debuffs[i] end)
    t.Mock("UnitBuff", function(u, i) return nil end)
    t.Mock("ScriptExtender_GetSpellDamage", function() return 100 end)
    t.Mock("GetSpellCooldown", function() return 0, 0, 1 end)
    t.Mock("ScriptExtender_HasTalent", function(n) return true end) -- All talents
    -- Mock Priority (Force Normal Prio 2)
    t.Mock("ScriptExtender_GetTargetPriority", function(u) return 2 end)
    -- Mock Spell Learned (Assume all learned)
    t.Mock("ScriptExtender_IsSpellLearned", function(n) return true end)
    WD_Track = {}

    -- Group Mocks (Mutable)
    local numParty = 0
    t.Mock("GetNumPartyMembers", function() return numParty end)
    t.Mock("GetNumRaidMembers", function() return 0 end)

    -- TEST 1: SOLO - Siphon Life on Normal Mob
    numParty = 0
    local act = ScriptExtender_Warlock_Analyze("target", false, 1000)
    t.AssertEqual("Siphon Life", act, "SOLO: Should cast Siphon Life on normal mob.")

    -- TEST 2: GROUP - Skip Siphon Life on Normal Mob
    numParty = 2
    act = ScriptExtender_Warlock_Analyze("target", false, 1000)
    t.Assert(act ~= "Siphon Life", "GROUP: Should SKIP Siphon Life on normal mob.")

    -- TEST 3: GROUP - Elite Mob - Use Siphon Life & Elements
    currentMob.classification = "elite"
    -- Siphon Life should be allowed on Elite
    act = ScriptExtender_Warlock_Analyze("target", false, 1000)
    t.AssertEqual("Siphon Life", act, "GROUP: Should cast Siphon Life on ELITE mob.")

    -- Let's pretend Siphon Life is up, check Curse
    currentMob.debuffs = { "Requiem" } -- Siphon Up
    act = ScriptExtender_Warlock_Analyze("target", false, 1000)
    t.AssertEqual("Curse of the Elements", act, "GROUP: Should cast Curse of Elements on ELITE mob (Malediction).")

    -- TEST 4: GROUP - Execute Phase Logic (IsDying)
    -- In Group, effective bolt dmg is 1.5x (Updated).
    -- Bolt Dmg = 100. Effective = 150.
    -- Threshold = 2 * 150 = 300 HP ISH (Actually 1.5 * 150 = 225 for isDying).
    -- Mob HP is 500. Not Dying.
    currentMob.hp = 500
    currentMob.debuffs = {} -- Reset debuffs
    currentMob.classification = "normal"

    act = ScriptExtender_Warlock_Analyze("target", false, 1000)
    -- With 500 HP > 225, we should APPLY DoTs (Spread Love).
    t.Assert(act ~= "Drain Life" and act ~= "Drain Soul",
        "GROUP: Should NOT skip DoTs on 500HP mob (Got: " .. tostring(act) .. ")")

    -- TEST 5: GROUP - REALLY LOW HP (100 HP)
    currentMob.hp = 100
    act = ScriptExtender_Warlock_Analyze("target", false, 1000)
    -- 100 < 225. Should skip DoTs.
    t.Assert(act == "Drain Life" or act == "Drain Soul",
        "GROUP: Should skip DoTs on 100HP mob (Got: " .. tostring(act) .. ")")
end
