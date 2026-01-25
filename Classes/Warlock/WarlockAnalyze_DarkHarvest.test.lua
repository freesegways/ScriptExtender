ScriptExtender_Tests["WarlockAnalyze_DarkHarvest"] = function(t)
    -- 1. Setup Data
    local HP_MAX = 2000
    local HP_HIGH = 2000
    local HP_LOW = 400       -- 20% of 2000
    local channelState = nil -- { name }

    local currentMob = { name = "Mob", hp = HP_HIGH, hpMax = HP_MAX, level = 60, classification = "normal" }

    -- 2. Mocks
    t.Mock("UnitLevel", function(u) return 60 end)
    t.Mock("UnitHealth", function(u)
        if u == "player" then return 3000 end
        return currentMob.hp
    end)
    t.Mock("UnitHealthMax", function(u)
        if u == "player" then return 3000 end
        return currentMob.hpMax
    end)
    t.Mock("UnitName", function(u) return currentMob.name end)
    t.Mock("GetTime", function() return 1000 end)

    t.Mock("UnitExists", function(u) return true end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitIsFriend", function(u) return false end)
    t.Mock("UnitAffectingCombat", function(u) return true end)
    t.Mock("GetRaidTargetIndex", function(u) return 0 end)
    t.Mock("UnitCreatureFamily", function(u) return "Demon" end)
    t.Mock("UnitPowerType", function(u) return 0 end)
    t.Mock("UnitMana", function(u) return 1000 end)
    t.Mock("UnitManaMax", function(u) return 1000 end)
    t.Mock("UnitClassification", function(u) return currentMob.classification end)

    t.Mock("UnitDebuff", function(u, i) return nil end)
    t.Mock("UnitBuff", function(u, i) return nil end)

    -- Mock Spell System
    t.Mock("ScriptExtender_GetSpellDamage", function(s) return 500 end)
    t.Mock("ScriptExtender_IsSpellLearned", function(n) return true end)
    t.Mock("ScriptExtender_GetSpellID", function(n)
        if n == "Dark Harvest" then return 999 end
        return 1
    end)
    t.Mock("ScriptExtender_IsSpellReady", function(n) return true end)
    t.Mock("GetSpellCooldown", function(id) return 0, 0, 0 end)

    -- Talent Mocks
    t.Mock("ScriptExtender_HasTalent", function(n) return false end)

    -- Mock Groups
    t.Mock("GetNumRaidMembers", function() return 0 end)
    t.Mock("GetNumPartyMembers", function() return 0 end) -- Solo

    -- Mock Channel Info (mocking global unit check)
    t.Mock("UnitChannelInfo", function(u)
        return channelState
    end)

    t.Mock("ScriptExtender_HasBuff", function() return false end)
    t.Mock("ScriptExtender_HasDebuff", function(u, t)
        -- Check if we said it is active in tracker for test purposes
        -- Or just return true for the CoR texture we want
        if t == "UnholyStrength" then return true end
        if t == "Abomination" then return true end
        if t == "Immolation" then return true end
        return false
    end)

    -- Clear Tracker
    WD_Track = {}

    -- === TEST 1: Mid-Combat (Single Target, Healthy, Solo) ===
    -- Target HP is High (2000). We are Solo.
    -- We assume CoR, Corruption, Immolate are UP (tracked).
    WD_Track["Mob" .. "UnholyStrength"] = 1000 -- CoR active
    WD_Track["Mob" .. "Abomination"] = 1000    -- Corruption active
    WD_Track["Mob" .. "Immolation"] = 1000     -- Immolate active

    -- WarlockAnalyze should return Dark Harvest if not low HP.

    local act, type, score = ScriptExtender_Warlock_Analyze("target", false, 1000)
    t.AssertEqual("Dark Harvest", act, "Should use Dark Harvest mid-combat in single target (Solo).")
    t.AssertEqual("damage", type)

    -- === TEST 2: Execute Phase ===
    -- Target HP Low (300).
    currentMob.hp = 300

    act, type, score = ScriptExtender_Warlock_Analyze("target", false, 1000)
    ScriptExtender_Print("Test 2 Result: Act=" .. tostring(act) .. " Type=" .. tostring(type) ..
        " Score=" .. tostring(score))

    t.AssertEqual(act, "Dark Harvest", "Should use Dark Harvest in Execute phase.")
    t.AssertEqual(type, "kill")

    -- Verify Score is high (Execute priority)
    t.Assert(score > 90, "Execute score should be high > 90 (got " .. tostring(score) .. ")")

    -- === TEST 3: Channel Protection ===
    -- We are channeling Dark Harvest. Analyze should return nil.
    channelState = "Dark Harvest"
    act, type, score = ScriptExtender_Warlock_Analyze("target", false, 1000)
    t.AssertEqual(nil, act, "Should hold fire while channeling Dark Harvest.")

    -- Clear Channel
    channelState = nil

    -- === TEST 4: Group Mode (Disable/Deprioritize Mid-Combat) ===
    -- If in Raid, we shouldn't use Mid-Combat DH (unless Boss).
    t.Mock("GetNumRaidMembers", function() return 10 end)
    currentMob.hp = 2000 -- Healthy again

    act, type, score = ScriptExtender_Warlock_Analyze("target", false, 1000)
    -- Should probably be Filler (Shadow Bolt/Drain or whatever logic is)
    -- Wait, if DoTs are up (WD_Track), loops finish.
    -- DH block skipped (dpsMultiplier > 1).
    -- Falls to Filler (Drain Soul / Drain Life).
    t.Assert(act ~= "Dark Harvest", "Should NOT use Dark Harvest mid-combat in Raid (unless Boss or dying).")

    -- BUT if Target is Boss...
    currentMob.classification = "worldboss"
    currentMob.hp = 20000 -- Healthy (Above Dying Threshold of ~6750)
    currentMob.hpMax = 100000
    act, type, score = ScriptExtender_Warlock_Analyze("target", false, 1000)
    -- Mid-Combat DH enabled for Boss even in raid? (My logic said 'isBoss')
    t.AssertEqual(act, "Dark Harvest", "Should use Dark Harvest on Bosses.")

    -- Reset
    t.Mock("GetNumRaidMembers", function() return 0 end)
    currentMob.classification = "normal"
end
