-- Tests for SmartCleanse Logic (Priority & Filtering)

-- Shared mock setup helper
local function SetupBasicMocks(t, opts)
    opts = opts or {}
    t.Mock("UnitClass", function() return "PRIEST", "PRIEST" end)
    t.Mock("GetHealerInfo", function() return opts.healerName or "HealerBob", opts.healerID or "party1" end)
    t.Mock("GetTankInfo",   function() return opts.tankName  or "TankDave",  opts.tankID  or "party2" end)
    t.Mock("CheckInteractDistance", function() return true end)
    t.Mock("UnitIsVisible",         function() return true end)
    t.Mock("UnitExists",            function() return true end)
    t.Mock("UnitIsConnected",       function() return true end)
    t.Mock("UnitIsDeadOrGhost",     function() return false end)
    t.Mock("UnitCanAssist",         function() return true end)
    t.Mock("GetNumRaidMembers",     function() return opts.raidSize or 0 end)
    t.Mock("CastSpellByName",       function() end)
    t.Mock("UnitIsFriend",          function() return true end)
    t.Mock("UnitIsUnit",            function() return false end)
    t.Mock("UnitBuff",              function() return nil end)
end

-- 1. HEALER PRIORITY
ScriptExtender_Tests["SmartCleanse_Priority_Healer"] = function(t)
    local spellTargeted = nil
    SetupBasicMocks(t)

    t.Mock("UnitDebuff", function(u, i)
        if i > 1 then return nil end
        if u == "party1" then return "Interface\\Icons\\Spell_Shadow_Curse", 1, "Magic" end -- Healer
        if u == "party2" then return "Interface\\Icons\\Spell_Shadow_Curse", 1, "Magic" end -- Tank
        return nil
    end)

    t.Mock("SpellTargetUnit", function(u) spellTargeted = u end)
    t.Mock("UnitName", function(u) return u end)

    SmartCleanse()
    t.AssertEqual({ actual = spellTargeted, expected = "party1" })
end

-- 2. TANK PRIORITY
ScriptExtender_Tests["SmartCleanse_Priority_Tank"] = function(t)
    local spellTargeted = nil
    SetupBasicMocks(t)

    t.Mock("UnitDebuff", function(u, i)
        if i > 1 then return nil end
        if u == "party1" then return nil end                                                -- Healer OK
        if u == "party2" then return "Interface\\Icons\\Spell_Shadow_Curse", 1, "Magic" end -- Tank Cursed
        if u == "party3" then return "Interface\\Icons\\Spell_Shadow_Curse", 1, "Magic" end -- DPS Cursed
        return nil
    end)

    t.Mock("SpellTargetUnit", function(u) spellTargeted = u end)
    t.Mock("UnitName", function(u) return u end)

    SmartCleanse()
    t.AssertEqual({ actual = spellTargeted, expected = "party2" })
end

-- 3. RANGE CHECK SKIP
ScriptExtender_Tests["SmartCleanse_Skip_Range"] = function(t)
    -- Healer is Cursed but OOR. Tank is Cursed and In Range. Should Cleanse Tank.
    local spellTargeted = nil
    SetupBasicMocks(t)

    t.Mock("UnitDebuff", function(u, i)
        if i > 1 then return nil end
        if u == "party1" then return "Debuff", 1, "Magic" end
        if u == "party2" then return "Debuff", 1, "Magic" end
        return nil
    end)

    -- Override: party1 is OOR
    t.Mock("CheckInteractDistance", function(u)
        if u == "party2" then return true end
        return false
    end)
    t.Mock("UnitIsVisible", function(u)
        if u == "party2" then return true end
        return false
    end)

    t.Mock("SpellTargetUnit", function(u) spellTargeted = u end)
    t.Mock("UnitName", function(u) return u end)

    SmartCleanse()
    t.AssertEqual({ actual = spellTargeted, expected = "party2" })
end

-- 4. RAID SUPPORT: picks the right raid member
ScriptExtender_Tests["SmartCleanse_Raid_Member"] = function(t)
    local spellTargeted = nil
    -- 10-man raid
    SetupBasicMocks(t, { raidSize = 10, healerID = "raid2", tankID = "raid3" })

    t.Mock("UnitDebuff", function(u, i)
        if i > 1 then return nil end
        -- Only raid5 has a debuff
        if u == "raid5" then return "Interface\\Icons\\Spell_Shadow_Curse", 1, "Magic" end
        return nil
    end)

    t.Mock("SpellTargetUnit", function(u) spellTargeted = u end)
    t.Mock("UnitName", function(u) return u end)

    SmartCleanse()
    t.AssertEqual({ actual = spellTargeted, expected = "raid5" })
end

-- 5. NO TARGET DROP: verifies TargetUnit is never called
ScriptExtender_Tests["SmartCleanse_NoTargetDrop"] = function(t)
    local targetDropped = false
    SetupBasicMocks(t)

    t.Mock("UnitDebuff", function(u, i)
        if i > 1 then return nil end
        if u == "party1" then return "Debuff", 1, "Magic" end
        return nil
    end)

    t.Mock("TargetUnit",      function() targetDropped = true end)
    t.Mock("TargetLastTarget",function() targetDropped = true end)
    t.Mock("SpellTargetUnit", function() end)
    t.Mock("UnitName",        function(u) return u end)

    SmartCleanse()
    t.AssertEqual({ actual = targetDropped, expected = false })
end
