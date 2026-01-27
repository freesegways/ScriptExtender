-- Classes/Warlock/PetAnalyze.lua
-- Analysis logic for Warlock pet automation.

local function IsPetSpellReady(spellName)
    local i = 1
    while true do
        local name, _ = GetSpellName(i, "pet")
        if not name then break end
        if name == spellName then
            local start, duration = GetSpellCooldown(i, "pet")
            if start > 0 and duration > 0 then
                local rem = duration - (GetTime() - start)
                if rem > 0.1 then return false end
            end
            return true
        end
        i = i + 1
    end
    -- If not found (pet not summoned or spell not known), cannot cast
    return false
end

function ScriptExtender_Warlock_PetAnalyze(params)
    local u = params.unit
    local allowManualPull = params.allowManualPull
    local ctx = params.context

    local P = "player"

    -- Use context if available, otherwise raw checks (backwards compat)
    if ctx then
        if ctx.isDead or ctx.isFriend then return nil, nil, -999 end
        if not allowManualPull and ctx.targetHP and ctx.targetHP > 0 then
            -- Context doesn't strictly track if target is in combat, so check raw
            if not UnitAffectingCombat(u) then return nil, nil, -999 end
        end
    else
        -- Fallback to raw checks if no context
        if not UnitExists(u) or UnitIsDead(u) or UnitIsFriend(P, u) then return nil, nil, -999 end
        if not allowManualPull and not UnitAffectingCombat(u) then return nil, nil, -999 end
    end

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

    if isSeduce then return "Seduction", "pet_cc", 100 end

    -- Base scoring based on mark priority
    -- Skull(8)=40, Cross(7)=30, Others=20
    local score = (m == 8 and 40) or (m == 7 and 30) or 20

    -- Higher priority if the target is attacking the player (Tanking is #1 job)
    if UnitIsUnit(u .. "target", P) then
        score = score + 50
    end

    -- Stickiness: Prefer current target to avoid ping-ponging
    -- If the pet is already attacking this unit, give it a HUGE boost to keep it there.
    -- Unless the player explicitly prioritizes something else significantly higher (e.g. manual target logic in main loop).
    if UnitName("pettarget") == UnitName(u) then
        score = score + 200 -- Massive sticky bonus
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
        if pet_mana > 20 and (pet_hp / pet_max < 0.2) and IsPetSpellReady("Phase Shift") then
            CastSpellByName("Phase Shift")
        end
        if pet_mana > 60 and IsPetSpellReady("Firebolt") then
            CastSpellByName("Firebolt")
        end
    elseif family == "Voidwalker" then
        local pl_hp = UnitHealth("player")
        local pl_max = UnitHealthMax("player")
        if pl_hp / pl_max < 0.2 and IsPetSpellReady("Sacrifice") then
            CastSpellByName("Sacrifice")
        end
        if pet_mana > 60 and IsPetSpellReady("Torment") then
            CastSpellByName("Torment")
        end
        if pet_mana > 150 and UnitAffectingCombat(P) and IsPetSpellReady("Suffering") then
            CastSpellByName("Suffering")
        end
    elseif family == "Succubus" then
        if pet_mana > 60 and IsPetSpellReady("Lash of Pain") then
            CastSpellByName("Lash of Pain")
        end
    elseif family == "Felhunter" then
        if pet_mana > 50 and IsPetSpellReady("Spell Lock") then
            CastSpellByName("Spell Lock")
        end
    end
end
