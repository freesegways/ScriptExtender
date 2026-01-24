-- Tests for Survival Logic
-- Tests: Class Defensives, Healthstone Priority, Efficient Potion Usage, Cooldown Handling
BOOKTYPE_PET = "pet"
BOOKTYPE_SPELL = "spell"

-- 1. PRIEST PANIC (Shield)
ScriptExtender_Tests["UseSurvival_Panic_Priest"] = function(t)
    local spellCast = nil
    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 200 end) -- 10%
    t.Mock("UnitClass", function() return "PRIEST", "PRIEST" end)
    t.Mock("CastSpellByName", function(spell) spellCast = spell end)
    t.Mock("UnitDebuff", function() return nil end)

    UseSurvival()
    t.AssertEqual(spellCast, "Power Word: Shield", "Priest should cast Shield in panic.")
end

-- 2. MAGE PANIC (Ice Barrier > Mana Shield)
ScriptExtender_Tests["UseSurvival_Panic_Mage"] = function(t)
    local spellCast = nil
    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 200 end)
    t.Mock("UnitClass", function() return "MAGE", "MAGE" end)
    t.Mock("CastSpellByName", function(spell) spellCast = spell end)

    -- Mock SpellBook: Ice Barrier Learned and Ready
    t.Mock("GetSpellName", function(i)
        if i == 1 then return "Ice Barrier" end
        return nil
    end)
    t.Mock("GetSpellCooldown", function(i) return 0, 0 end) -- Ready

    UseSurvival()
    t.AssertEqual(spellCast, "Ice Barrier", "Mage should cast Ice Barrier.")
end

-- 3. ROGUE PANIC (Evasion)
ScriptExtender_Tests["UseSurvival_Panic_Rogue"] = function(t)
    local spellCast = nil
    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 200 end)
    t.Mock("UnitClass", function() return "ROGUE", "ROGUE" end)
    t.Mock("CastSpellByName", function(spell) spellCast = spell end)
    t.Mock("GetSpellName", function(i) if i == 1 then return "Evasion" end end)
    t.Mock("GetSpellCooldown", function() return 0, 0 end)

    UseSurvival()
    t.AssertEqual(spellCast, "Evasion", "Rogue should cast Evasion.")
end

-- 4. POTION EFFICIENCY (Skip Overkill)
ScriptExtender_Tests["UseSurvival_Potion_Overkill"] = function(t)
    -- Deficit 100. Best Potion: Major Healthstone (1200).
    -- Should SKIP because 100 < (1200 * 0.6) and HP is safe.
    local usedBag = nil

    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 1900 end) -- 95%
    t.Mock("UnitClass", function() return "WARRIOR" end)

    t.Mock("GetContainerNumSlots", function(b) return 5 end)
    t.Mock("GetContainerItemLink", function(b, s)
        if b == 0 and s == 1 then return "item:123:Major Healthstone" end
        return nil
    end)
    t.Mock("GetContainerItemCooldown", function() return 0, 0, 1 end)
    t.Mock("UseContainerItem", function(b, s) usedBag = b end)

    UseSurvival()
    t.AssertEqual(usedBag, nil, "Should NOT use expensive potion for tiny scratch.")
end

-- 5. COOLDOWN SKIP
ScriptExtender_Tests["UseSurvival_Skip_Cooldown"] = function(t)
    -- Deficit 1000. Major HS (1200) on CD. Major Pot (1400) Ready.
    -- Should use Major Pot.
    local usedSlot = nil

    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 1000 end)
    t.Mock("UnitClass", function() return "WARRIOR" end)

    t.Mock("GetContainerNumSlots", function(b) return 5 end)
    t.Mock("GetContainerItemLink", function(b, s)
        if b == 0 and s == 1 then return "item:123:[Major Healthstone]" end
        if b == 0 and s == 2 then return "item:456:[Major Healing Potion]" end
        return nil
    end)

    t.Mock("GetContainerItemCooldown", function(b, s)
        if s == 1 then return 123, 10, 1 end -- HS on CD
        return 0, 0, 1                       -- Pot Ready
    end)

    t.Mock("UseContainerItem", function(b, s) usedSlot = s end)

    UseSurvival()
    t.AssertEqual(usedSlot, 2, "Should skip Slot 1 (CD) and use Slot 2.")
end

-- 6. WARLOCK PANIC (Spellstone)
ScriptExtender_Tests["UseSurvival_Panic_Warlock_Spellstone"] = function(t)
    local usedSlot = nil
    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 200 end) -- 10%
    t.Mock("UnitClass", function() return "WARLOCK", "WARLOCK" end)

    t.Mock("UnitExists", function(u) return false end) -- No pet
    t.Mock("UnitIsDead", function(u) return false end) -- Safety

    -- Mock Slot 17 (Spellstone)
    t.Mock("GetInventoryItemLink", function(p, slot)
        if slot == 17 then return "item:123:Major Spellstone" end
        return nil
    end)
    t.Mock("GetInventoryItemCooldown", function(p, slot) return 0, 0, 1 end) -- Ready
    t.Mock("UseInventoryItem", function(slot) usedSlot = slot end)

    UseSurvival()
    t.AssertEqual(usedSlot, 17, "Warlock should use Spellstone (Slot 17).")
end

-- 7. WARLOCK PANIC (Death Coil)
ScriptExtender_Tests["UseSurvival_Panic_Warlock_DeathCoil"] = function(t)
    local spellCast = nil
    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 200 end)
    t.Mock("UnitClass", function() return "WARLOCK", "WARLOCK" end)

    t.Mock("UnitExists", function(u)
        if u == "target" then return true end
        return false
    end)
    t.Mock("UnitCanAttack", function(p, u) return true end)
    t.Mock("UnitIsDead", function() return false end)             -- Safety

    t.Mock("GetInventoryItemLink", function(p, s) return nil end) -- No Spellstone

    t.Mock("CastSpellByName", function(s) spellCast = s end)

    -- Mock Spellbook for IsSpellReady
    t.Mock("GetSpellName", function(i)
        if i == 1 then return "Death Coil" end
    end)
    t.Mock("GetSpellCooldown", function(i) return 0, 0 end)

    UseSurvival()
    t.AssertEqual(spellCast, "Death Coil", "Warlock should cast Death Coil if no Spellstone.")
end

-- 8. PALADIN TANK PANIC (No Bubble)
ScriptExtender_Tests["UseSurvival_Panic_Paladin_Tank"] = function(t)
    local spellCast = nil
    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 200 end) -- 10%
    t.Mock("UnitClass", function() return "PALADIN", "PALADIN" end)

    t.Mock("UnitBuff", function(u, i)
        if i == 1 then return "Interface\\Icons\\Spell_Holy_SealOfFury" end
        return nil
    end)
    t.Mock("UnitDebuff", function() return nil end)

    t.Mock("CastSpellByName", function(s) spellCast = s end)

    -- Mock Spells: Bubble Ready, LoH Ready
    t.Mock("GetSpellName", function(i)
        if i == 1 then return "Divine Shield" end
        if i == 2 then return "Lay on Hands" end
    end)
    t.Mock("GetSpellCooldown", function(i) return 0, 0 end)

    UseSurvival()
    t.AssertEqual(spellCast, "Lay on Hands", "Paladin Tank should SKIP bubble and cast Lay on Hands.")
end

-- 9. PALADIN NORMAL PANIC (Bubble)
ScriptExtender_Tests["UseSurvival_Panic_Paladin_Normal"] = function(t)
    local spellCast = nil
    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 200 end)
    t.Mock("UnitClass", function() return "PALADIN", "PALADIN" end)

    t.Mock("UnitBuff", function() return nil end) -- No Tank Buff
    t.Mock("UnitDebuff", function() return nil end)

    t.Mock("CastSpellByName", function(s) spellCast = s end)

    t.Mock("GetSpellName", function(i)
        if i == 1 then return "Divine Shield" end
        if i == 2 then return "Lay on Hands" end
    end)
    t.Mock("GetSpellCooldown", function(i) return 0, 0 end)

    UseSurvival()
    t.AssertEqual(spellCast, "Divine Shield", "Paladin Normal should cast Bubble.")
end

-- 10. WARLOCK SACRIFICE (Panic < 20%)
ScriptExtender_Tests["UseSurvival_Panic_Warlock_Sacrifice"] = function(t)
    local spellCast = nil
    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 300 end) -- 15%
    t.Mock("UnitClass", function() return "WARLOCK", "WARLOCK" end)

    t.Mock("UnitExists", function(u)
        if u == "pet" then return true end
        return false
    end)
    t.Mock("UnitIsDead", function(u) return false end)

    t.Mock("CastSpellByName", function(s) spellCast = s end)

    -- Mock Pet Spellbook
    t.Mock("GetSpellName", function(i, book)
        if book == BOOKTYPE_PET and i == 1 then return "Sacrifice" end
    end)
    t.Mock("GetSpellCooldown", function(i, book) return 0, 0 end)

    UseSurvival()
    t.AssertEqual(spellCast, "Sacrifice", "Warlock should cast Sacrifice at low HP.")
end

-- 11. WARLOCK SACRIFICE (Mob Count >= 3)
ScriptExtender_Tests["UseSurvival_Panic_Warlock_Sacrifice_Mobs"] = function(t)
    local spellCast = nil
    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitHealth", function() return 600 end) -- 30% (Not Panic Threshold < 20, but < 35 Critical)
    t.Mock("UnitClass", function() return "WARLOCK", "WARLOCK" end)

    t.Mock("UnitExists", function(u)
        if u == "pet" then return true end
        return false
    end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("CastSpellByName", function(s) spellCast = s end)
    t.Mock("GetSpellName", function(i, book)
        if book == BOOKTYPE_PET and i == 1 then return "Sacrifice" end
    end)
    t.Mock("GetSpellCooldown", function(i, book) return 0, 0 end)

    -- Mock Mob Distribution
    GetMobDistribution = function()
        return 5, { ["player"] = 4 } -- 4 mobs on player
    end

    UseSurvival()
    t.AssertEqual(spellCast, "Sacrifice", "Warlock should cast Sacrifice if 3+ mobs on me.")

    GetMobDistribution = nil -- Cleanup
end
