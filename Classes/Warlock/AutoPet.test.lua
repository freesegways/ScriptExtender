-- Classes/Warlock/AutoPet.test.lua

ScriptExtender_Tests["AutoPet_ClearsLeftoverOOCTarget"] = function(t)
    local petActions = {}
    local currentTarget = nil
    local clearedTarget = false

    -- Scenario:
    -- Player is IN COMBAT.
    -- Target is initially NIL.
    -- Scan finds an OOC mob "Peaceful".
    -- Analyzer should reject "Peaceful" (Strict check).
    -- AutoPet should CLEAR the target at the end because no action was taken.
    -- This prevents the "Peaceful" mob from remaining targeted for the next run.

    local mob = { name = "Peaceful", combat = false }

    -- Mocks
    t.Mock("GetTime", function() return 1000 end)
    t.Mock("UnitExists", function(u) return u == "pet" or (u == "target" and currentTarget ~= nil) end)
    t.Mock("UnitIsDead", function(u) return false end)
    t.Mock("UnitIsFriend", function(u) return false end)
    t.Mock("UnitAffectingCombat", function(u)
        if u == "player" then return true end -- Player in combat
        if u == "target" and currentTarget then return currentTarget.combat end
        return false                          -- Others are OOC
    end)
    t.Mock("UnitName", function(u) return currentTarget and currentTarget.name or nil end)
    t.Mock("GetRaidTargetIndex", function() return 0 end)

    t.Mock("UnitHealth", function() return 100 end)
    t.Mock("UnitHealthMax", function() return 100 end)
    t.Mock("UnitMana", function() return 100 end)

    -- Scan Logic: Loop finds "Peaceful"
    t.Mock("TargetNearestEnemy", function()
        currentTarget = mob
    end)

    t.Mock("ClearTarget", function()
        currentTarget = nil
        clearedTarget = true
    end)

    t.Mock("PetAttack", function() table.insert(petActions, "Attack") end)
    t.Mock("PetFollow", function() table.insert(petActions, "Follow") end)

    -- Run AutoPet
    AutoPet()

    -- Assertions
    t.Assert(clearedTarget, "Target should have been cleared because no valid action was found.")
    t.Assert(table.getn(petActions) == 0, "No pet actions should have been taken.")
end
