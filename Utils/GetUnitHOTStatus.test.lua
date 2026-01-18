-- Tests for GetUnitHOTStatus

ScriptExtender_Tests["GetUnitHOTStatus_Renew_Shield"] = function(t)
    -- SCENARIO: Unit has Renew and Shield active.
    
    t.Mock("UnitExists", function() return true end)
    
    t.Mock("UnitBuff", function(u, i)
        if i == 1 then return "Interface\\Icons\\Spell_Holy_Renew" end
        if i == 2 then return "Interface\\Icons\\Spell_Holy_PowerWordShield" end
        return nil
    end)
    
    t.Mock("UnitDebuff", function() return nil end)
    
    local status = GetUnitHOTStatus("player")
    
    t.Assert(status.renew, "Should detect Renew")
    t.Assert(status.shield, "Should detect Shield")
    t.Assert(status.weakened == false, "Should NOT detect Weakened Soul")
end

ScriptExtender_Tests["GetUnitHOTStatus_WeakenedSoul"] = function(t)
    -- SCENARIO: Unit has Weakened Soul debuff.
    
    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitBuff", function() return nil end)
    
    t.Mock("UnitDebuff", function(u, i)
        if i == 1 then return "Interface\\Icons\\Spell_Shadow_GatherShadows" end
        return nil
    end)
    
    local status = GetUnitHOTStatus("player")
    
    t.Assert(status.weakened, "Should detect Weakened Soul")
    t.Assert(status.renew == false, "Should not have Renew")
end
