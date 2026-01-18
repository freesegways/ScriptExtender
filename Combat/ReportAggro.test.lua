-- Tests for ReportAggro

ScriptExtender_Tests["ReportAggro_HasAggro"] = function(t)
    local msgPrinted = false

    -- Mock External Dep
    t.Mock("GetMobDistribution", function() return 1, { ["player"] = 1 } end)
    t.Mock("UnitName", function() return "Player" end)

    -- Mock Print to verify output
    -- Note: StandaloneRunner mocks it to print to stdout. We want to capture it.
    t.Mock("ScriptExtender_Print", function(msg)
        if string.find(msg, "is tanking 1") then msgPrinted = true end
    end)

    ReportAggro()

    t.Assert(msgPrinted, "Should print tanking report.")
end

ScriptExtender_Tests["ReportAggro_NoAggro"] = function(t)
    local msgPrinted = false

    t.Mock("GetMobDistribution", function() return 0, {} end)

    t.Mock("ScriptExtender_Print", function(msg)
        if string.find(msg, "No aggro") then msgPrinted = true end
    end)

    ReportAggro()

    t.Assert(msgPrinted, "Should print 'No aggro detected'.")
end
