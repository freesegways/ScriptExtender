-- Combat/AutoCombat2/Classes/WarlockPetSpells.lua
-- Decisions for Warlock Demons.
-- Note: Pet actions are GCD-independent of the player.

if ScriptExtender_WarlockPetSpells then return end



ScriptExtender_WarlockPetSpells = {
    ["PetAttack"] = {
        target = "pet_enemy",
        isCommand = true,
        score = function(mob, ws, pet)
            if mob.debuffs.hasCC then return 0 end -- Never break CC

            local score = 0

            -- 1. Focus Fire: Attack Player's Target (Absolute Priority)
            if mob.isTarget then
                score = 500
            end

            -- 2. Defend Player: If mob is attacking player, increase priority
            if mob.target == UnitName("player") then
                score = score + 100 -- Heavy weight to peel aggro
            end

            -- 3. Avoid Runners (Risk of body pull)
            if mob.isFleeing then
                score = score - 150
            end

            -- 4. Aggressive Engagement: If pet is idle but player is in combat
            if not pet.inCombat and ws.context.inCombat then
                score = score + 200
            end

            return score
        end,

    },

    -- VOIDWALKER
    ["Consume Shadows"] = {
        target = "pet",
        score = function(mob, ws, pet)
            if pet.inCombat then return 0 end
            if pet.hpPct < 70 then return 90 end
            return 0
        end,

    },

    ["Sacrifice"] = {
        target = "player",
        score = function(mob, ws, pet)
            local playerHP = (UnitHealth("player") / UnitHealthMax("player")) * 100
            if playerHP < 25 then return 150 end
            return 0
        end,

    },

    -- FELHUNTER
    ["Spell Lock"] = {
        target = "pet_enemy",
        score = function(mob, ws, pet)
            -- 1.12 limitation: requires combat log for casting detection.
            return 0
        end,

    },

    -- SUCCUBUS
    ["Lash of Pain"] = {
        target = "pet_enemy",
        score = function(mob, ws, pet)
            if mob.debuffs.hasCC then return 0 end
            if not pet.inCombat then return 0 end -- Must be in melee range (assumed by combat)
            if pet.manaPct > 20 then return 60 end
            return 0
        end,

    },

    ["Seduction"] = {
        target = "pet_enemy",
        score = function(mob, ws, pet)
            -- Emergency CC on secondary targets?
            -- For now, manual trigger or specific logic needed.
            return 0
        end,

    },

    -- IMP
    ["Firebolt"] = {
        target = "pet_enemy",
        score = function(mob, ws, pet)
            if mob.debuffs.hasCC then return 0 end
            local score = 50

            -- Prioritize defensive targets
            if mob.target == UnitName("player") then
                score = score + 20
            end

            -- Prioritize current target slightly more to prevent switching mid-cast
            if mob.isTarget then
                score = score + 10
            end

            return score
        end,

    }
}
