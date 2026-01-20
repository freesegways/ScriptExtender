-- Classes/Warlock/PetAnalyze.lua
-- Analysis logic for Warlock pet automation.

function ScriptExtender_Warlock_PetAnalyze(u, forceOOC, tm)
    local P = "player"
    if not UnitExists(u) or UnitIsDead(u) or UnitIsFriend(P, u) then return nil, nil, -999 end

    -- forceOOC=true allows OOC targets. If false, we require combat.
    if not forceOOC and not UnitAffectingCombat(u) then return nil, nil, -999 end

    -- CC Check (Using global CC list)
    for i = 1, 16 do
        local d = UnitDebuff(u, i)
        if not d then break end
        for _, t in ipairs(ScriptExtender_CCTextures) do
            if string.find(d, t) then return nil, nil, -999 end
        end
    end

    -- Priority / Seduce Check
    -- Marks: 5=Moon, 1=Star (Usually Seduce targets)
    local m = GetRaidTargetIndex(u) or 0
    local isSeduce = (m == 5 or m == 1)

    if isSeduce then return "Seduction", "pet_cc", -20 end

    -- Base scoring based on mark priority
    -- Skull(8)=40, Cross(7)=30, Others=20
    local score = (m == 8 and 40) or (m == 7 and 30) or 20

    -- Higher priority if the target is attacking the player (Tanking is #1 job)
    if UnitIsUnit(u .. "target", P) then
        score = score + 50
    end

    -- Stickiness: Prefer current target to avoid ping-ponging
    if UnitExists("pettarget") and UnitIsUnit(u, "pettarget") then
        score = score + 15
    end

    return "PetAttack", "pet", score
end

function ScriptExtender_Warlock_PetSpells(action, targetName, tm)
    local P = "player"
    local PT = "pettarget"

    -- If the loop told us to attack or CC, do it
    if action == "PetAttack" then
        PetAttack()
    elseif action == "Seduction" then
        -- The target is already selected by the loop execution phase
        CastSpellByName("Seduction")
        return -- Don't do other spells if we are seducing
    end

    -- Automatic Spells (Imp firebolt, etc.)
    local family = UnitCreatureFamily("pet") or "Imp"
    local pet_hp = UnitHealth("pet")
    local pet_max = UnitHealthMax("pet")
    local pet_mana = UnitMana("pet")

    if family == "Imp" then
        if pet_mana > 20 and (pet_hp / pet_max < 0.2) then CastSpellByName("Phase Shift") end
        if pet_mana > 60 then CastSpellByName("Firebolt") end
    elseif family == "Voidwalker" then
        local pl_hp = UnitHealth("player")
        local pl_max = UnitHealthMax("player")
        if pl_hp / pl_max < 0.2 then CastSpellByName("Sacrifice") end
        if pet_mana > 60 then CastSpellByName("Torment") end
        if pet_mana > 150 and UnitAffectingCombat(P) then CastSpellByName("Suffering") end
    elseif family == "Succubus" then
        if pet_mana > 60 then CastSpellByName("Lash of Pain") end
    elseif family == "Felhunter" then
        if pet_mana > 50 then CastSpellByName("Spell Lock") end
    end
end
