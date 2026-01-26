-- Tests for Role Detection

ScriptExtender_Tests["GetTankInfo_Buff"] = function(t)
    -- Party1 has Bear Form. Should be Tank.
    t.Mock("UnitName", function(u) return "BearDruid" end)
    t.Mock("UnitExists", function(u)
        if u == "party1" then return true end
        return false
    end)
    t.Mock("UnitIsConnected", function() return true end)
    t.Mock("UnitBuff", function(u, i)
        if u == "party1" and i == 1 then return "Interface\\Icons\\Ability_Racial_BearForm" end
        return nil
    end)

    local name, id = GetTankInfo()
    t.AssertEqual({ actual = id, expected = "party1" })
end

ScriptExtender_Tests["GetTankInfo_HP_Fallback"] = function(t)
    -- No Buffs. Party2 has 5000 HP. Party1 has 2000. Player 1000.
    t.Mock("UnitName", function(u) return "BigHPWarrior" end)
    t.Mock("UnitExists", function(u) return true end) -- Everyone exists
    t.Mock("UnitIsConnected", function() return true end)
    t.Mock("UnitBuff", function() return nil end)

    t.Mock("UnitHealthMax", function(u)
        if u == "party2" then return 5000 end
        return 2000
    end)

    local name, id = GetTankInfo()
    t.AssertEqual({ actual = id, expected = "party2" })
end
