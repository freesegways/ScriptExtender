-- Combat/ManaWand.test.lua

ScriptExtender_Tests["ManaWand_Analyze_InvalidTarget"] = function(t)
    t.Mock("UnitExists", function(u) return false end)
    local action, spell, score = ScriptExtender_ManaWand_Analyze("target", false, nil)
    t.AssertEqual({ actual = score, expected = -1000 })

    t.Mock("UnitExists", function(u) return true end)
    t.Mock("UnitIsDead", function(u) return true end)
    action, spell, score = ScriptExtender_ManaWand_Analyze("target", false, nil)
    t.AssertEqual({ actual = score, expected = -1000 })
end

ScriptExtender_Tests["ManaWand_Analyze_HasWisdom_Manual"] = function(t)
    t.Mock("UnitExists", function(u) return true end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitCanAttack", function(p, u) return true end)
    t.Mock("UnitDebuff", function(u, i)
        if i == 1 then return "Interface\\Icons\\Spell_Holy_RighteousnessAura" end
        return nil
    end)

    -- Mock Tooltip
    local mockTooltip = {
        ClearLines = function() end,
        SetUnitDebuff = function() end
    }
    t.Mock("ScriptExtender_ScanTooltip", mockTooltip)

    local mockTextLeft1 = {
        GetText = function() return "Judgement of Wisdom" end
    }
    t.Mock("ScriptExtender_ScanTooltipTextLeft1", mockTextLeft1)

    local action, spell, score = ScriptExtender_ManaWand_Analyze("target", false, nil)
    t.AssertEqual({ actual = action, expected = "Shoot" })
    t.AssertEqual({ actual = spell, expected = "wand" })
    t.AssertEqual({ actual = score, expected = 100 })
end

ScriptExtender_Tests["ManaWand_Analyze_NoWisdom_Manual_Fallback"] = function(t)
    t.Mock("UnitExists", function(u) return true end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitCanAttack", function(p, u) return true end)
    t.Mock("UnitDebuff", function(u, i) return nil end)

    local action, spell, score = ScriptExtender_ManaWand_Analyze("target", false, nil)

    t.AssertEqual({ actual = action, expected = "Shoot" })
    t.AssertEqual({ actual = spell, expected = "wand" })
    t.AssertEqual({ actual = score, expected = 50 })
end

ScriptExtender_Tests["ManaWand_Analyze_Scanning_HasWisdom"] = function(t)
    t.Mock("UnitExists", function(u) return true end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitCanAttack", function(p, u) return true end)
    t.Mock("UnitDebuff", function(u, i)
        if i == 1 then return "Interface\\Icons\\Spell_Holy_RighteousnessAura" end
        return nil
    end)

    local mockTooltip = {
        ClearLines = function() end,
        SetUnitDebuff = function() end
    }
    t.Mock("ScriptExtender_ScanTooltip", mockTooltip)

    local mockTextLeft1 = {
        GetText = function() return "Judgement of Wisdom" end
    }
    t.Mock("ScriptExtender_ScanTooltipTextLeft1", mockTextLeft1)

    -- When scanning, we must ensure we don't have a current manual target blocking us
    -- The Analyze function checks: if isScanning then if UnitExists("target") ...
    -- We mock UnitExists(u) at the top based on input, but we need to handle "target" specifically

    local originalUnitExists = UnitExists or function() return false end
    t.Mock("UnitExists", function(u)
        if u == "target" then return false end -- No manual target
        return true                            -- The scanned unit exists
    end)

    local action, spell, score = ScriptExtender_ManaWand_Analyze("mouseover", true, nil)
    t.AssertEqual({ actual = score, expected = 100 })
end

ScriptExtender_Tests["ManaWand_Analyze_Scanning_NoWisdom"] = function(t)
    t.Mock("UnitExists", function(u)
        if u == "target" then return false end
        return true
    end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitCanAttack", function(p, u) return true end)
    t.Mock("UnitDebuff", function(u, i) return nil end)

    local action, spell, score = ScriptExtender_ManaWand_Analyze("mouseover", true, nil)
    t.AssertEqual({ actual = score, expected = -1000 })
end

ScriptExtender_Tests["ManaWand_Analyze_Scanning_AlreadyHasTarget"] = function(t)
    t.Mock("UnitExists", function(u)
        -- Both the unit being analyzed AND the player's target exist
        return true
    end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitCanAttack", function(p, u) return true end)

    local action, spell, score = ScriptExtender_ManaWand_Analyze("mouseover", true, nil)

    -- Should abort scanning if we already have a target
    t.AssertEqual({ actual = score, expected = -1000 })
end
