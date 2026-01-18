-- Classes/Warlock/AutoWarlock.test.lua

ScriptExtender_Tests["AutoWarlock_FullCycle"] = function(t)
    local castSpells = {}
    local petActions = {}
    local targetsScanned = 0
    local currentTarget = nil

    -- Mock Data
    local mobs = {
        { name = "Mob_Skull", hp = 100, max = 100, mark = 8, combat = true },
        { name = "Mob_CC",    hp = 100, max = 100, mark = 1, debuffs = { "Polymorph" }, combat = true },
        { name = "Mob_Low",   hp = 100, max = 100, mark = 0, combat = true }
    }

    -- Standard Mocks
    t.Mock("GetTime", function() return 1000 end)
    t.Mock("UnitHealth", function(u)
        if u == "player" then return 1000 end
        if u == "pet" then return 500 end
        if u == "target" and currentTarget then return currentTarget.hp end
        return 100
    end)
    t.Mock("UnitHealthMax", function(u) return 1000 end)
    t.Mock("UnitMana", function(u)
        if u == "player" then return 1000 end
        if u == "pet" then return 200 end
        return 0
    end)
    t.Mock("UnitManaMax", function(u) return 1000 end)
    t.Mock("UnitExists", function(u)
        if u == "pet" then return true end
        if u == "target" then return currentTarget ~= nil end
        return false
    end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitIsFriend", function(u1, u2) return false end)
    t.Mock("UnitAffectingCombat", function(u) return true end)
    t.Mock("UnitName", function(u) return currentTarget and currentTarget.name or "Unknown" end)
    t.Mock("GetRaidTargetIndex", function(u) return currentTarget and currentTarget.mark or 0 end)

    t.Mock("UnitBuff", function(u, i) return nil end)
    t.Mock("UnitDebuff", function(u, i)
        if currentTarget and currentTarget.debuffs and currentTarget.debuffs[i] then
            return currentTarget.debuffs[i]
        end
        return nil
    end)

    t.Mock("UnitCreatureFamily", function(u) return "Imp" end)
    t.Mock("UnitPowerType", function(u) return 0 end)

    -- Actions
    t.Mock("CastSpellByName", function(s) table.insert(castSpells, s) end)
    t.Mock("PetAttack", function() table.insert(petActions, "Attack") end)
    t.Mock("PetFollow", function() table.insert(petActions, "Follow") end)
    t.Mock("ClearTarget", function() currentTarget = nil end)

    t.Mock("TargetNearestEnemy", function()
        targetsScanned = targetsScanned + 1
        local idx = ((targetsScanned - 1) % table.getn(mobs)) + 1
        currentTarget = mobs[idx]
    end)

    -- TEST: Target prioritization and simultaneous pet command
    AutoWarlock()

    local foundDot = false
    for _, s in ipairs(castSpells) do
        if s == "Shadow Word: Pain" or s == "Corruption" or s == "Immolate" or s == "Drain Soul" or s == "Drain Life" then
            foundDot = true
        end
    end

    t.Assert(targetsScanned > 0, "Should have scanned targets.")
    t.Assert(foundDot, "Player should have cast something on the prioritized target.")

    local petAttacked = false
    for _, a in ipairs(petActions) do if a == "Attack" then petAttacked = true end end
    t.Assert(petAttacked, "Pet should have been ordered to attack.")
end

ScriptExtender_Tests["AutoWarlock_CC_Safety"] = function(t)
    local castSpells = {}
    local petActions = {}

    -- Only one mob, and it is CC'd
    local mob = { name = "SheepedBoy", hp = 100, max = 100, mark = 1, debuffs = { "Polymorph" }, combat = true }
    local currentTarget = nil

    t.Mock("GetTime", function() return 1000 end)
    t.Mock("UnitExists", function(u) return u == "pet" or (u == "target" and currentTarget ~= nil) end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitIsFriend", function(u1, u2) return false end)
    t.Mock("UnitAffectingCombat", function(u) return true end)
    t.Mock("UnitName", function(u) return mob.name end)
    t.Mock("GetRaidTargetIndex", function(u) return mob.mark end)
    t.Mock("UnitDebuff", function(u, i)
        if i == 1 then return "Polymorph" end
        return nil
    end)
    t.Mock("UnitBuff", function(u, i) return nil end)
    t.Mock("UnitHealth", function(u) return 100 end)
    t.Mock("UnitHealthMax", function(u) return 100 end)
    t.Mock("UnitMana", function(u) return 100 end)
    t.Mock("UnitManaMax", function(u) return 100 end)
    t.Mock("UnitCreatureFamily", function(u) return "Imp" end)
    t.Mock("UnitPowerType", function(u) return 0 end)

    t.Mock("CastSpellByName", function(s) table.insert(castSpells, s) end)
    t.Mock("PetAttack", function() table.insert(petActions, "Attack") end)
    t.Mock("PetFollow", function() table.insert(petActions, "Follow") end)
    t.Mock("TargetNearestEnemy", function() currentTarget = mob end)
    t.Mock("ClearTarget", function() currentTarget = nil end)

    AutoWarlock()

    t.Assert(table.getn(castSpells) == 0, "Should NOT cast spells on a CC'd target.")

    local petWasAngry = false
    for _, a in ipairs(petActions) do if a == "Attack" then petWasAngry = true end end
    t.Assert(not petWasAngry, "Pet should NOT attack a CC'd target.")
end

ScriptExtender_Tests["AutoWarlock_LifeTap_Logic"] = function(t)
    local tapped = false
    local currentTarget = nil
    local mob = { name = "Training Dummy", mark = 0 }

    t.Mock("GetTime", function() return 1000 end)
    t.Mock("UnitHealth", function(u) return 900 end) -- High Health
    t.Mock("UnitHealthMax", function(u) return 1000 end)
    t.Mock("UnitMana", function(u) return 200 end)   -- Low Mana
    t.Mock("UnitManaMax", function(u) return 1000 end)
    t.Mock("UnitExists", function(u) return u == "pet" or (u == "target" and currentTarget ~= nil) end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitIsFriend", function(u1, u2) return false end)
    t.Mock("UnitAffectingCombat", function(u) return true end)
    t.Mock("UnitName", function(u) return mob.name end)
    t.Mock("GetRaidTargetIndex", function(u) return mob.mark end)
    t.Mock("UnitBuff", function(u, i) return nil end)
    t.Mock("UnitDebuff", function(u, i) return nil end)
    t.Mock("UnitCreatureFamily", function(u) return "Imp" end)
    t.Mock("UnitPowerType", function(u) return 0 end)

    t.Mock("TargetNearestEnemy", function() currentTarget = mob end)
    t.Mock("ClearTarget", function() currentTarget = nil end)
    t.Mock("PetAttack", function() end)

    t.Mock("CastSpellByName", function(s) if s == "Life Tap" then tapped = true end end)

    AutoWarlock()

    t.Assert(tapped, "Should Life Tap when Mana is low and Health is high (detected via Analyze).")
end
