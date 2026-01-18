-- Tests for GetHealProfile

ScriptExtender_Tests["GetHealProfile_Filter_Level"] = function(t)
    -- Mock Level 10
    t.Mock("UnitLevel", function() return 10 end)

    local report = GetHealProfile()

    t.Assert(report["Lesser Heal(Rank 1)"], "Should have Rank 1 (Lvl 1)")
    t.Assert(report["Lesser Heal(Rank 3)"], "Should have Rank 3 (Lvl 10)")
    t.AssertEqual(report["Heal(Rank 1)"], nil, "Should NOT have Heal (Lvl 16)")
end

ScriptExtender_Tests["GetHealProfile_Calculation"] = function(t)
    -- Mock Level 60
    t.Mock("UnitLevel", function() return 60 end)

    local report = GetHealProfile()
    local gh5 = report["Greater Heal(Rank 5)"] -- lvl 60

    t.Assert(gh5, "Should have Greater Heal Rank 5")

    -- Basic Sanity Check on Math
    -- Base: ~2080. +Heal(87) * Coeff(3/3.5=0.857) -> ~74 bonus. Total ~2154.
    -- Talent * 1.1 -> ~2370.
    -- HPM: 2370 / 710 = ~3.33

    t.Assert(gh5.heal > 2200, "Should heal > 2200 with bonuses.")
    t.Assert(gh5.hpm > 3.0, "Should have > 3.0 HPM.")
end
