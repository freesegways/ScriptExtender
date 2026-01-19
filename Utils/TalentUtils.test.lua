-- Utils/TalentUtils.test.lua

ScriptExtender_Tests["TalentUtils_HasTalent"] = function(t)
    -- Mock GetNumTalentTabs
    t.Mock("GetNumTalentTabs", function() return 3 end)

    -- Mock GetNumTalents: let's say 2 talents per tab
    t.Mock("GetNumTalents", function(tab) return 2 end)

    -- Mock GetTalentInfo
    -- Tab 1, Idx 1: "Improved Shadow Bolt", Rank 5/5
    -- Tab 1, Idx 2: "Cataclysm", Rank 0/5
    t.Mock("GetTalentInfo", function(tab, idx)
        if tab == 1 and idx == 1 then
            return "Improved Shadow Bolt", "Texture", 1, 1, 5, 5
        elseif tab == 1 and idx == 2 then
            return "Cataclysm", "Texture", 1, 2, 0, 5
        end
        return "Unknown Talent", "Texture", 1, 1, 0, 5
    end)

    local hasShadowBolt = ScriptExtender_HasTalent("Improved Shadow Bolt")
    t.Assert(hasShadowBolt == true, "Should return TRUE for learned talent")

    local hasCataclysm = ScriptExtender_HasTalent("Cataclysm")
    t.Assert(hasCataclysm == false, "Should return FALSE for unlearned talent (rank 0)")

    local hasFake = ScriptExtender_HasTalent("NonExistent")
    t.Assert(hasFake == false, "Should return FALSE for missing talent")
end
