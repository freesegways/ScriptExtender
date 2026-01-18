-- Classes/Shaman/AutoShamanBuffs.lua
-- Automatically handles Shaman buffs (Lightning Shield, Weapon Enchants).

function AutoShamanBuffs()
    local tm = GetTime()

    -- 1. Lightning Shield (Self)
    -- Texture: Spell_Nature_LightningShield
    local hasLS = false
    local j = 0
    while GetPlayerBuff(j, "HELPFUL") >= 0 do
        local b = GetPlayerBuff(j, "HELPFUL")
        local tx = GetPlayerBuffTexture(b)
        if tx and string.find(tx, "LightningShield") then
            hasLS = true
            break
        end
        j = j + 1
    end

    if not hasLS then
        -- Check if we know it
        -- (Simplified: Try casting, or scan spellbook. We'll assume if they run this they want it)
        -- To be safe, rely on user knowing their class or add SpellBook scan like others.
        CastSpellByName("Lightning Shield")
        return
    end

    -- 2. Weapon Enchant (Self)
    -- GetWeaponEnchantInfo: hasMainHandEnchant, mainHandExpiration, mainHandCharges, ...
    local hasMH, expMH, _, hasOH, expOH = GetWeaponEnchantInfo()

    if not hasMH then
        -- Logic: Level/Spec based?
        -- Default: Rockbiter (low level), Windfury (30+), Flametongue (Caster?)
        -- Simplest: Use Windfury if 30+, else Rockbiter.
        -- We need to check if spell exists in book ideally.
        -- For now, try Windfury -> Rockbiter

        -- We can scan spellbook once
        local knowWF = false
        local i = 1
        while true do
            local n = GetSpellName(i, 1)
            if not n then break end
            if n == "Windfury Weapon" then
                knowWF = true
                break
            end
            i = i + 1
        end

        if knowWF then
            CastSpellByName("Windfury Weapon")
        else
            CastSpellByName("Rockbiter Weapon")
        end
        return
    end
end

ScriptExtender_Register("AutoShamanBuffs", "Automatically keeps Lightning Shield and Weapon Enchants active.")
