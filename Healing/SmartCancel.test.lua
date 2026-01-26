-- Tests for SmartCancel Logic
-- Tests: Overheal protection, Snipe detection, Damage passthrough

ScriptExtender_Tests["SmartCancel_Keep_Damage"] = function(t)
    local cancelled = false

    -- Setup Global State directly (simulating TrackHeal call)
    HC_Target = "party1"
    HC_StartHP = 1000 -- Started at 1000
    HC_Amount = 2000

    -- Mock: Now at 800 (took 200 dmg)
    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitHealth", function() return 800 end)
    t.Mock("UnitHealthMax", function() return 5000 end) -- Deficit 4200
    t.Mock("SpellStopCasting", function() cancelled = true end)

    SmartCancel()
    t.AssertEqual({ actual = cancelled, expected = false })
end

ScriptExtender_Tests["SmartCancel_Stop_Full"] = function(t)
    local cancelled = false

    HC_Target = "party1"
    HC_StartHP = 1000
    HC_Amount = 2000

    -- Mock: Now at 4900/5000 (Deficit 100)
    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitHealth", function() return 4900 end)
    t.Mock("UnitHealthMax", function() return 5000 end)
    t.Mock("SpellStopCasting", function() cancelled = true end)

    -- Mock UI Error Frame Global
    local fakeFrame = { AddMessage = function() end }
    t.Mock("UIErrorsFrame", fakeFrame) -- Mock the global object

    SmartCancel()
    t.AssertEqual({ actual = cancelled, expected = true })
end

ScriptExtender_Tests["SmartCancel_Stop_Sniped"] = function(t)
    local cancelled = false

    HC_Target = "party1"
    HC_StartHP = 2000
    HC_Amount = 2000 -- Casting 2000 heal

    -- Mock: Healer snipe! Target now at 4000/5000 (80%).
    -- Deficit = 1000.
    -- Cond: Deficit (1000) < Amount*0.8 (1600)? YES.
    -- Cond: HP% (0.8) >= 0.80 ? YES.

    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitHealth", function() return 4100 end)
    t.Mock("UnitHealthMax", function() return 5000 end)
    t.Mock("SpellStopCasting", function() cancelled = true end)

    local fakeFrame = { AddMessage = function() end }
    t.Mock("UIErrorsFrame", fakeFrame)

    SmartCancel()
    t.AssertEqual({ actual = cancelled, expected = true })
end

ScriptExtender_Tests["SmartCancel_Keep_Snipe_Fail"] = function(t)
    local cancelled = false

    HC_Target = "party1"
    HC_StartHP = 500
    HC_Amount = 2000

    -- Mock: Target healed slightly to 1000/5000 (20%).
    -- Deficit = 4000.
    -- Cond: Deficit(4000) < 1600? NO.
    -- Cond: HP 20% > 80%? NO.
    -- Result: KEEP CASTING.

    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitHealth", function() return 1000 end)
    t.Mock("UnitHealthMax", function() return 5000 end)
    t.Mock("SpellStopCasting", function() cancelled = true end)

    SmartCancel()
    t.AssertEqual({ actual = cancelled, expected = false })
end
