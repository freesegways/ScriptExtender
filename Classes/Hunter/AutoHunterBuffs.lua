-- Classes/Hunter/AutoHunterBuffs.lua
-- Automatically handles Hunter buffs (Aspects, Trueshot Aura).

if not AB_Track then AB_Track = {} end

function AutoHunterBuffs()
    local tm = GetTime()

    -- 1. Trueshot Aura (Party Buff, 30 min)
    -- Texture: Spell_Magic_MageArmor (Placeholder, need real texture: Spell_Holy_AuraOfLight?)
    -- Name scan is safer if possible via tooltip, but texture is faster.
    -- Trueshot Aura texture: 'Spell_Magic_LesserInvisibilty' ? No. 'Ability_TrueShot'

    local hasTS = false
    local knowTS = false

    -- Check Spellbook for Trueshot
    local i = 1
    while true do
        local n = GetSpellName(i, 1)
        if not n then break end
        if n == "Trueshot Aura" then
            knowTS = true
            break
        end
        i = i + 1
    end

    if knowTS then
        local j = 0
        while GetPlayerBuff(j, "HELPFUL") >= 0 do
            local b = GetPlayerBuff(j, "HELPFUL")
            local tx = GetPlayerBuffTexture(b)
            if tx and string.find(tx, "TrueShot") then
                hasTS = true
                break
            end
            j = j + 1
        end

        if not hasTS then
            CastSpellByName("Trueshot Aura")
            return
        end
    end

    -- 2. Aspect (Self)
    -- Check if ANY aspect is up. If not, Cast Hawk.
    local activeAspect = nil
    local j = 0
    while GetPlayerBuff(j, "HELPFUL") >= 0 do
        local b = GetPlayerBuff(j, "HELPFUL")
        local tx = GetPlayerBuffTexture(b)
        if tx and string.find(tx, "Aspect") then
            activeAspect = tx
            break
        end
        j = j + 1
    end

    if not activeAspect then
        CastSpellByName("Aspect of the Hawk")
        -- Fallback to Monkey if Hawk not learned? Hawk is lvl 10.
        -- If spell fails, nothing happens, safe enough.
    end
end

ScriptExtender_Register("AutoHunterBuffs", "Automatically maintains Trueshot Aura and ensures an Aspect is active.")
