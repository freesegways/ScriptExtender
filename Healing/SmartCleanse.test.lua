-- Tests for SmartCleanse Logic (Priority & Filtering)

-- 1. HEALER PRIORITY
ScriptExtender_Tests["SmartCleanse_Priority_Healer"] = function(t)
    local target = nil
    t.Mock("UnitClass", function() return "PRIEST", "PRIEST" end)
    t.Mock("GetHealerInfo", function() return "HealerBob", "party1" end)
    t.Mock("GetTankInfo", function() return "TankDave", "party2" end)

    t.Mock("UnitDebuff", function(u, i)
        if i > 1 then return nil end
        if u == "party1" then return "Interface\\Icons\\Spell_Shadow_Curse", 1, "Magic" end -- Healer
        if u == "party2" then return "Interface\\Icons\\Spell_Shadow_Curse", 1, "Magic" end -- Tank
        return nil
    end)

    t.Mock("CheckInteractDistance", function() return true end)
    t.Mock("UnitIsVisible", function() return true end)
    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitIsConnected", function() return true end)
    t.Mock("UnitIsDeadOrGhost", function() return false end)
    t.Mock("UnitCanAssist", function() return true end)

    t.Mock("TargetUnit", function(u) target = u end)
    t.Mock("CastSpellByName", function(s) end)
    t.Mock("ClearTarget", function() end)
    t.Mock("SpellIsTargeting", function() return false end)

    SmartCleanse()
    t.AssertEqual(target, "party1", "Should prioritize Healer over Tank.")
end

-- 2. TANK PRIORITY
ScriptExtender_Tests["SmartCleanse_Priority_Tank"] = function(t)
    local target = nil
    t.Mock("UnitClass", function() return "PRIEST", "PRIEST" end)
    t.Mock("GetHealerInfo", function() return "HealerBob", "party1" end)
    t.Mock("GetTankInfo", function() return "TankDave", "party2" end)

    t.Mock("UnitDebuff", function(u, i)
        if i > 1 then return nil end
        if u == "party1" then return nil end                                                -- Healer OK
        if u == "party2" then return "Interface\\Icons\\Spell_Shadow_Curse", 1, "Magic" end -- Tank Cursed
        if u == "party3" then return "Interface\\Icons\\Spell_Shadow_Curse", 1, "Magic" end -- DPS Cursed
        return nil
    end)

    t.Mock("CheckInteractDistance", function() return true end)
    t.Mock("UnitIsVisible", function() return true end)
    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitIsConnected", function() return true end)
    t.Mock("UnitIsDeadOrGhost", function() return false end)
    t.Mock("UnitCanAssist", function() return true end)
    t.Mock("TargetUnit", function(u) target = u end)
    t.Mock("CastSpellByName", function(s) end)
    t.Mock("ClearTarget", function() end)

    SmartCleanse()
    t.AssertEqual(target, "party2", "Should prioritize Tank over DPS.")
end

-- 3. RANGE CHECK SKIP
ScriptExtender_Tests["SmartCleanse_Skip_Range"] = function(t)
    -- Healer is Cursed but OOR. Tank is Cursed and In Range. Should Cleanse Tank.
    local target = nil
    t.Mock("UnitClass", function() return "PRIEST", "PRIEST" end)
    t.Mock("GetHealerInfo", function() return "HealerBob", "party1" end)
    t.Mock("GetTankInfo", function() return "TankDave", "party2" end)

    t.Mock("UnitDebuff", function(u, i)
        if i > 1 then return nil end
        if u == "party1" then return "Debuff", 1, "Magic" end
        if u == "party2" then return "Debuff", 1, "Magic" end
        return nil
    end)

    -- Mock Range: Party1 False, Party2 True
    t.Mock("CheckInteractDistance", function(u)
        if u == "party2" then return true end
        return false
    end)
    t.Mock("UnitIsVisible", function(u)
        if u == "party2" then return true end
        return false -- Party1 invisible/oor
    end)
    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitIsConnected", function() return true end)
    t.Mock("UnitIsDeadOrGhost", function() return false end)
    t.Mock("UnitCanAssist", function() return true end)
    t.Mock("IsActionInRange", function() return 1 end) -- For fallback check

    t.Mock("TargetUnit", function(u) target = u end)
    t.Mock("CastSpellByName", function(s) end)
    t.Mock("ClearTarget", function() end)

    SmartCleanse()
    t.AssertEqual(target, "party2", "Should skip OOR Healer and cleanse Tank.")
end
