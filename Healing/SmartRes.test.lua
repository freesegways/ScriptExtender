-- Healing/SmartRes.test.lua

ScriptExtender_Tests["SmartRes_Priest_Target"] = function(t)
    local cast = nil
    t.Mock("UnitClass", function(u) return "Priest", "PRIEST" end)

    -- Target Valid
    t.Mock("UnitExists", function(u) return u == "target" end)
    t.Mock("UnitIsDeadOrGhost", function(u) return u == "target" end)
    t.Mock("UnitIsFriend", function(u, t) return true end)
    t.Mock("UnitName", function(u) return "DeadGuy" end)
    t.Mock("CastSpellByName", function(s) cast = s end)

    SmartRes()
    t.Assert(cast == "Resurrection", "Priest should cast Resurrection on target.")
end

ScriptExtender_Tests["SmartRes_Shaman_Mouseover"] = function(t)
    local cast = nil
    local targeted = nil
    local retargeted = false
    t.Mock("UnitClass", function(u) return "Shaman", "SHAMAN" end)

    -- Mouseover Valid
    t.Mock("UnitExists", function(u) return u == "mouseover" or u == "target" end)
    t.Mock("UnitIsDeadOrGhost", function(u) return true end)
    t.Mock("UnitIsFriend", function(u) return true end)
    t.Mock("UnitName", function(u) return "DeadMouse" end)

    t.Mock("TargetUnit", function(u) targeted = u end)
    t.Mock("TargetLastTarget", function() retargeted = true end)
    t.Mock("CastSpellByName", function(s) cast = s end)

    SmartRes()
    t.Assert(cast == "Ancestral Spirit", "Shaman should cast Ancestral Spirit.")
    t.Assert(targeted == "mouseover", "Should target mouseover.")
    t.Assert(retargeted, "Should return to previous target.")
end

ScriptExtender_Tests["SmartRes_AutoTarget_Priority"] = function(t)
    local cast = nil
    local targeted = nil

    t.Mock("UnitClass", function(u)
        if u == "player" then return "Paladin", "PALADIN" end
        if u == "party1" then return "Warrior", "WARRIOR" end
        if u == "party2" then return "Priest", "PRIEST" end
        return "Warrior", "WARRIOR"
    end)

    -- No Target, No Mouseover
    t.Mock("UnitExists", function(u) return u == "party1" or u == "party2" end)
    t.Mock("UnitIsDeadOrGhost", function(u) return true end) -- All dead
    t.Mock("UnitIsFriend", function(u) return true end)
    t.Mock("UnitIsUnit", function(a, b) return a == b end)

    t.Mock("CheckInteractDistance", function(u, i) return true end) -- All in range
    t.Mock("GetNumRaidMembers", function() return 0 end)
    t.Mock("UnitName", function(u) return u end)

    t.Mock("TargetUnit", function(u) targeted = u end)
    t.Mock("CastSpellByName", function(s) cast = s end)

    SmartRes()

    t.Assert(cast == "Redemption", "Paladin should cast Redemption.")
    t.Assert(targeted == "party2", "Should prioritize Party2 (Priest) over Party1 (Warrior).")
end

ScriptExtender_Tests["SmartRes_AutoTarget_Range"] = function(t)
    local targeted = nil

    t.Mock("UnitClass", function(u) return "Priest", "PRIEST" end)

    t.Mock("UnitExists", function(u) return u == "party1" end)
    t.Mock("UnitIsDeadOrGhost", function(u) return true end)
    t.Mock("UnitIsFriend", function(u) return true end)
    t.Mock("UnitIsUnit", function(a, b) return a == b end)

    -- Party1 Out of Range
    t.Mock("CheckInteractDistance", function(u, i) return false end)
    t.Mock("GetNumRaidMembers", function() return 0 end)

    t.Mock("TargetUnit", function(u) targeted = u end)

    SmartRes()

    t.Assert(targeted == nil, "Should NOT target units out of range.")
end

ScriptExtender_Tests["SmartRes_NoValid"] = function(t)
    local cast = nil
    t.Mock("UnitClass", function(u) return "Priest", "PRIEST" end)
    t.Mock("UnitExists", function(u) return u == "target" end)
    t.Mock("UnitIsDeadOrGhost", function(u) return false end) -- Alive
    t.Mock("UnitIsFriend", function(u) return true end)
    t.Mock("CastSpellByName", function(s) cast = s end)

    SmartRes()

    t.Assert(cast == nil, "Should not cast if target is alive.")
end
