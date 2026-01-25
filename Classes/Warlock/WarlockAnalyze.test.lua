ScriptExtender_Tests["WarlockAnalyze_Logic"] = function(t)
    -- Verify Logic for Optimization (Skipping DoTs on dying mobs)
    -- And Malediction Cursing

    -- 1. Setup Data
    local HP_LOW = 200 -- Low enough relative to DoTs
    local HP_HIGH = 2000

    local currentMob = { name = "Mob", hp = HP_LOW, level = 50, debuffs = {} }

    -- 2. Mocks
    t.Mock("UnitLevel", function(u)
        if u == "player" then return 60 end
        return currentMob.level
    end)
    t.Mock("UnitHealth", function(u) return currentMob.hp end)
    -- Fix Max HP to be same as HP so pHP=100%, forcing Drain Soul as filler (Predictable)
    t.Mock("UnitHealthMax", function(u) return currentMob.hp end)
    t.Mock("UnitName", function(u) return currentMob.name end)
    t.Mock("GetTime", function() return 1000 end)
    t.Mock("UnitExists", function(u) return true end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitIsFriend", function(u) return false end)
    t.Mock("UnitAffectingCombat", function(u) return true end)
    t.Mock("GetRaidTargetIndex", function(u) return 0 end)
    t.Mock("UnitCreatureFamily", function(u) return "Imp" end)
    t.Mock("UnitPowerType", function(u) return 0 end)
    t.Mock("UnitMana", function(u) return 1000 end)
    t.Mock("UnitManaMax", function(u) return 1000 end)
    t.Mock("UnitClassification", function(u) return "normal" end)

    -- Mock Debuffs
    t.Mock("UnitDebuff", function(u, i)
        return currentMob.debuffs[i] -- Returns texture path
    end)
    t.Mock("UnitBuff", function(u, i) return nil end)

    -- Mock Talents: Give Malediction & Siphon Life
    t.Mock("ScriptExtender_HasTalent", function(name)
        if name == "Malediction" then return true end
        if name == "Siphon Life" then return true end
        return false
    end)

    -- Mock Spells: Assume we know everything
    t.Mock("ScriptExtender_IsSpellLearned", function(n) return true end)
    t.Mock("ScriptExtender_GetSpellID", function(n) return 1 end)
    t.Mock("ScriptExtender_IsSpellReady", function(n) return true end)

    -- Mock Spell Damage (High enough to kill Low HP mob)
    t.Mock("ScriptExtender_GetSpellDamage", function(s)
        if s == "Siphon Life" then return 600 end -- Enough to kill 200 HP
        if s == "Curse of Agony" then return 800 end
        if s == "Corruption" then return 400 end
        return 100
    end)

    -- Mock Tracker
    WD_Track = {}

    -- Mock Cooldowns (Always Ready)
    t.Mock("GetSpellCooldown", function(id) return 0, 0, 1 end)

    -- === TEST 1: LOW LEVEL MOB (Level 25 vs 60) ===
    -- Expectation: Optimization ACTIVE. (25 <= 30)
    currentMob.level = 25
    -- Siphon Life is "Cast" (Mocked via debuff).
    currentMob.debuffs = { "Requiem" } -- Siphon Life texture

    -- Mob HP = 200. Siphon Dmg = 600. killerDotActive -> TRUE.
    -- Next: Curse of Agony (Malediction -> CoR).
    -- Is Curse Slot. Optimization IGNORED (Always cast curses).

    local act, type, score = ScriptExtender_Warlock_Analyze("target", false, 1000)
    t.AssertEqual("Curse of Recklessness(Rank 1)", act, "Should cast CoR on Low Level Mob even if dying (Utility).")

    -- === TEST 2: LOW LEVEL MOB - CORRUPTION ===
    -- Now assume CoR is ALSO up.
    -- We want to see if Corruption is SKIPPED due to optimization.
    currentMob.debuffs = { "Requiem", "CurseOfSargeras" } -- Siphon + Agony(CoR)

    -- Optimization: killerDotActive=True.
    -- Next spell: Corruption.
    -- IsCurseSlot = False.
    -- killerDotActive = True. -> SKIP.

    act, type, score = ScriptExtender_Warlock_Analyze("target", false, 1000)
    t.Assert(act ~= "Corruption", "Should SKIP Corruption on dying Low Level Mob.")
    t.AssertEqual("Drain Soul", act, "Should fall through to Filler.")

    -- === TEST 3: GREEN MOB (Level 50 vs 60) ===
    -- Expectation: Optimization DISABLED. (50 > 30)
    currentMob.level = 50
    currentMob.debuffs = { "Requiem", "CurseOfSargeras" } -- Siphon + Agony up.

    -- killerDotActive -> FALSE (Level check failed).

    act, type, score = ScriptExtender_Warlock_Analyze("target", false, 1000)
    t.AssertEqual("Corruption", act, "Should CAST Corruption on Green Mob (50) (No Optimization).")
end

ScriptExtender_Tests["SpellUtils_Syntax"] = function(t)
    -- Mocks
    t.Mock("GetSpellName", function(i, book)
        if i == 1 then return "Curse of Recklessness", "Rank 1" end
        return nil
    end)

    -- Clear Cache
    ScriptExtender_SpellUtils.IDCache = {}

    -- 1. Test "Name (Rank)" with Space (Standard)
    local id1 = ScriptExtender_GetSpellID("Curse of Recklessness (Rank 1)")
    t.AssertEqual(1, id1, "Should find ID with space.")

    -- 2. Test "Name(Rank)" No Space (User Syntax)
    local id2 = ScriptExtender_GetSpellID("Curse of Recklessness(Rank 1)")
    t.AssertEqual(1, id2, "Should find ID without space.")
end

ScriptExtender_Tests["WarlockAnalyze_Manual_OOC"] = function(t)
    -- Mocking OOC Target
    t.Mock("UnitExists", function(u) return true end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitIsFriend", function(u) return false end)
    t.Mock("UnitAffectingCombat", function(u) return false end) -- OOC
    t.Mock("UnitName", function(u) return "Peaceful" end)
    t.Mock("UnitHealth", function(u) return 2000 end)           -- High HP to avoid short fight logic
    t.Mock("UnitHealthMax", function(u) return 2000 end)
    t.Mock("UnitMana", function(u) return 1000 end)
    t.Mock("UnitManaMax", function(u) return 1000 end)
    t.Mock("UnitPowerType", function(u) return 0 end)
    t.Mock("UnitCreatureFamily", function(u) return "Imp" end)
    t.Mock("UnitLevel", function(u) return 60 end)
    t.Mock("UnitClassification", function(u) return "normal" end)
    t.Mock("ScriptExtender_GetSpellDamage", function() return 100 end)
    t.Mock("GetSpellCooldown", function() return 0, 0, 1 end)
    t.Mock("GetRaidTargetIndex", function() return 0 end)
    t.Mock("UnitDebuff", function() return nil end)
    t.Mock("UnitBuff", function() return nil end)
    WD_Track = {}

    -- Mock Talents (Verify Siphon Life Logic)
    t.Mock("ScriptExtender_HasTalent", function(n)
        if n == "Siphon Life" then return true end
        return false
    end)

    -- Call with ForceOOC = TRUE
    local act, type, score = ScriptExtender_Warlock_Analyze("target", true, 1000)

    t.Assert(act ~= nil, "Analyzer SHOULD return action for OOC target if forceOOC is true.")
    -- Expect Curse of Agony (Siphon Life logic requires low player HP)
    t.AssertEqual(act, "Curse of Agony", "Should open with Curse of Agony (Siphon requires low HP).")

    -- Call with ForceOOC = FALSE (Manual Target assumed by CombatLoop, but Analyzer rejects)
    -- This part of test was checking nonexistent Analyzer logic. Removing/Ignore.
end

ScriptExtender_Tests["AutoWarlockBuffs_Healthstones"] = function(t)
    -- This test verifies that removing the redundant RankMap didn't break Healthstone creation logic.

    -- 1. Setup Data
    local calledCast = nil

    -- 2. Mock Global Dependencies
    t.Mock("UnitClass", function(u) return "Warlock", "WARLOCK" end)
    t.Mock("UnitMana", function(u) return 500 end) -- Enough mana
    t.Mock("ScriptExtender_IsSpellLearned", function(spell) return true end)

    -- Mock Bag: No Healthstones, but have Soul Shard
    -- Logic in AutoWarlockBuffs: FindItemInBag checks GetContainerItemLink.
    t.Mock("GetContainerNumSlots", function(b) return 1 end)

    -- We need to ensure we DO NOT find "Major Healthstone" (so we craft it)
    -- But we DO find "Soul Shard" (reagent)
    t.Mock("GetContainerItemLink", function(b, s)
        -- Simulating Slot 1 (b=0, s=1) having Soul Shard
        if b == 0 and s == 1 then
            return "|cff9d9d9d|Hitem:6265:0:0:0|h[Soul Shard]|h|r"
        end
        return nil
    end)

    -- Mock FindSpells to return success for "Create Healthstone (Major)"
    -- This simulates that we know the spell.
    t.Mock("FindSpells", function(name)
        -- Ensure we can find the spell when searched
        if name == "Create Healthstone (Major)" then
            return { { name = "Create Healthstone (Major)", index = 10 } }
        end
        return {}
    end)

    t.Mock("CastSpell", function(id, book)
        if id == 10 then
            calledCast = "Create Healthstone (Major)"
        end
    end)

    t.Mock("ScriptExtender_Print", function(msg) end)

    -- Mock HasBuff (used in AutoWarlockBuffs) via GetPlayerBuff
    t.Mock("GetPlayerBuff", function(i, filter) return -1 end) -- No buffs

    -- 3. Run Function
    AutoWarlockBuffs()

    -- 4. Assert
    t.AssertEqual("Create Healthstone (Major)", calledCast,
        "Should attempt to cast Create Healthstone (Major) when found in spellbook.")
end
