-- Combat/AutoCombat2/Classes/WarlockPetSpells.lua
-- Decisions for Warlock Demons.
-- Note: Pet actions are GCD-independent of the player.

if ScriptExtender_WarlockPetSpells then return end

local function GetPetActionSlotByTexture(texPattern)
    for i = 1, 10 do
        local name, subtext, texture = GetPetActionInfo(i)
        if texture and string.find(string.lower(texture), string.lower(texPattern)) then
            return i
        end
    end
    return nil
end

ScriptExtender_WarlockPetSpells = {
    ["PetAttack"] = {
        target = "pet_enemy",
        isCommand = true,
        score = function(mob, ws, pet)
            -- Primary goal: Attack the player's primary target
            if ws.context.targetPseudoID == mob.pseudoID then
                -- Even if pet is in combat, we want it attacking our target
                -- However, PetAttack() can stutter the pet if spammed.
                -- We only score it highly if it's the player's target.
                return 100
            end
            return 0
        end,
        execute = function(mob)
            -- Only run PetAttack if the pet is definitely not already targeting anything?
            -- In 1.12 we can't easily check pet target, but we can check pet combat state.
            -- If the pet is idle (OOC) and we have a target, ATTACK.
            if not UnitAffectingCombat("pet") then
                PetAttack()
            end
        end
    },

    ["Consume Shadows"] = {
        target = "pet",
        score = function(mob, ws, pet)
            if pet.inCombat then return 0 end
            if pet.hpPct < 70 then return 90 end
            return 0
        end,
        execute = function()
            -- Use texture pattern "VoidWalker_ConsumeShadows" to be localization-agnostic
            local slot = GetPetActionSlotByTexture("VoidWalker_ConsumeShadows")
            if slot then CastPetAction(slot) end
        end
    },

    ["Sacrifice"] = {
        target = "player",
        score = function(mob, ws, pet)
            local playerHP = (UnitHealth("player") / UnitHealthMax("player")) * 100
            if playerHP < 25 then return 150 end
            return 0
        end,
        execute = function()
            -- Texture pattern "Spell_Shadow_Sacrifice"
            local slot = GetPetActionSlotByTexture("Spell_Shadow_Sacrifice")
            if slot then CastPetAction(slot) end
        end
    },

    ["Spell Lock"] = {
        target = "pet_enemy",
        score = function(mob, ws, pet)
            -- 1.12 limitation: We can't see enemy casting via API.
            -- This will remain at 0 until we have a combat log scanner.
            return 0
        end,
        execute = function(mob)
            local slot = GetPetActionSlotByTexture("Spell_Shadow_MindRot")
            if slot then CastPetAction(slot) end
        end
    }
}
