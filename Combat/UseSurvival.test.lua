-- Tests for Survival Logic
-- Tests: Class Defensives, Healthstone Priority, Efficient Potion Usage, Cooldown Handling

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
