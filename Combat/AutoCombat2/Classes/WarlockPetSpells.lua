-- Combat/AutoCombat2/Classes/WarlockPetSpells.lua
-- Decisions for Warlock Demons.
-- Note: Pet actions are GCD-independent of the player.

if ScriptExtender_WarlockPetSpells then return end



ScriptExtender_WarlockPetSpells = {
    ["PetAttack"] = {
        target = "pet_enemy",
        isCommand = true,
        score = function(mob, ws, pet)
            if pet.inCombat then return 0 end
            if ws.context.targetPseudoID == mob.pseudoID then
                return 100
            end
            return 0
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
            return 50 -- basic filler
        end,

    }
}
