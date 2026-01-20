-- Classes/Warlock/AutoWarlockBuffs.lua
-- Automatically handles Warlock buffs (Demon Skin/Armor, Unending Breath, Felstone).

if not AB_Track then AB_Track = {} end
if not AB_LastPrint then AB_LastPrint = 0 end

-- Create scanning tooltip for name-based buff detection
local SE_ScanTooltip = CreateFrame("GameTooltip", "SE_ScanTooltip", nil, "GameTooltipTemplate")
SE_ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

function AutoWarlockBuffs(m)
    local tm, th = GetTime(), (tonumber(m) or 5) * 60
    local _, pClass = UnitClass("player")

    -- Configuration
    -- Item Type: 'item_hold' means we want to HAVE the item in bags.
    -- Item Type: 'item_use' (like Felstone) means we want the BUFF from the item.
    local BUFFS = {
        {
            -- 1. Demon Armor / Demon Skin
            type = "spell",
            spells = { "Demon Armor", "Demon Skin" },
            buffName = "Demon " -- Common substring
        },
        {
            -- 2. Unending Breath
            type = "spell",
            spells = { "Unending Breath" },
            buffName = "Unending Breath"
        },
        {
            -- 3. Felstone (Spellstone/Firestone generic logic placeholder - user specifically asked for Healthstones)
            -- Actually, Felstone gives a buff.
            type = "item_use",
            buffName = "Felstone", -- Check exact buff name in game if possible
            itemName = "Felstone",
            createSpell = "Create Felstone",
            reagent = "Soul Shard"
        },
        {
            -- 4. Healthstone
            type = "item_hold",
            -- List generic names to matching specific ranks?
            -- We'll just list the Create Spells in priority order.
            createSpells = {
                "Create Healthstone (Major)",
                "Create Healthstone (Greater)",
                "Create Healthstone",
                "Create Healthstone (Lesser)",
                "Create Healthstone (Minor)"
            },
            -- The resulting items usually match the suffix, but we need to check if we HAVE it.
            -- Map Spell -> Item Name
            map = {
                ["Create Healthstone (Major)"] = "Major Healthstone",
                ["Create Healthstone (Greater)"] = "Greater Healthstone",
                ["Create Healthstone"] = "Healthstone",
                ["Create Healthstone (Lesser)"] = "Lesser Healthstone",
                ["Create Healthstone (Minor)"] = "Minor Healthstone"
            }
        }
    }

    local function FindItemInBag(itemName)
        -- ScriptExtender_Print("DEBUG: Searching bags for '" .. itemName .. "'")
        for b = 0, 4 do
            for s = 1, GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b, s)
                if link then
                    -- local name = GetItemInfo(link) -- sometimes link is enough
                    -- Case insensitive check on the full link text
                    if string.find(string.lower(link), string.lower(itemName)) then
                        return b, s
                    end
                end
            end
        end
        return nil, nil
    end

    local function HasBuff(unit, buffName)
        local i = 0
        while GetPlayerBuff(i, "HELPFUL") >= 0 do
            local index = GetPlayerBuff(i, "HELPFUL")

            -- Use Tooltip to get the real name
            SE_ScanTooltip:ClearLines()
            SE_ScanTooltip:SetPlayerBuff(index)
            local name = SE_ScanTooltipTextLeft1:GetText()

            if name and string.find(name, buffName) then
                local rem = GetPlayerBuffTimeLeft(index)
                return true, rem
            end
            i = i + 1
        end
        return false, 0
    end

    -- Execution
    for _, buffDef in ipairs(BUFFS) do
        if buffDef.type == "spell" then
            -- Handle Standard Spells
            local bestSpell = nil
            for _, sp in ipairs(buffDef.spells) do
                if ScriptExtender_IsSpellLearned(sp, pClass) then
                    bestSpell = sp
                    break
                end
            end

            if bestSpell then
                local hasIt, rem = HasBuff("player", buffDef.buffName or bestSpell)

                if not hasIt or rem < 300 then
                    ScriptExtender_Print("AutoBuff: Need " .. bestSpell .. " (Rem: " .. (rem or 0) .. "s)")
                    CastSpellByName(bestSpell)
                    return -- One action per tick
                end
            end
        elseif buffDef.type == "item_use" then
            -- Handle Item Buffs (Felstone) - Check if we have the BUFF
            local hasIt, rem = HasBuff("player", buffDef.buffName)

            if not hasIt or rem < 300 then
                -- 1. Try to use item
                local b, s = FindItemInBag(buffDef.itemName)

                if b and s then
                    UseContainerItem(b, s)
                    ScriptExtender_Print("AutoBuff: Using " .. buffDef.itemName)
                    return
                else
                    -- 2. Create item
                    if ScriptExtender_IsSpellLearned(buffDef.createSpell, pClass) then
                        local rb, rs = FindItemInBag(buffDef.reagent)
                        if rb and rs then
                            if UnitMana("player") > 139 then
                                CastSpellByName(buffDef.createSpell)
                                ScriptExtender_Print("AutoBuff: Creating " .. buffDef.itemName)
                                return
                            end
                        end
                    end
                end
            end
        elseif buffDef.type == "item_hold" then
            -- Handle Items we just want to POSSESS (Healthstone)
            -- Iterate spells to find the best one we can cast
            for _, spellName in ipairs(buffDef.createSpells) do
                if ScriptExtender_IsSpellLearned(spellName) then
                    local itemName = buffDef.map[spellName]
                    local b, s = FindItemInBag(itemName)

                    if not b then
                        -- We don't have it. Create it.
                        -- Check Shard
                        local rb, rs = FindItemInBag("Soul Shard")
                        if rb and rs then
                            -- Check Mana (Estimating cost or just trying)
                            if UnitMana("player") > 200 then
                                CastSpellByName(spellName)
                                ScriptExtender_Print("AutoBuff: Creating " .. itemName)
                                return -- Stop after one action
                            end
                        else
                            -- No Shard, can't make it.
                            ScriptExtender_Print("AutoBuff: Need Shard for " .. itemName)
                            return
                        end
                    else
                        -- We have this rank.
                        -- User Request: Continue to check lower ranks to stack multiple unique Healthstones.
                    end
                end
            end
        end
    end
end

ScriptExtender_Register("AutoWarlockBuffs", "Automatically casts Warlock self-buffs (Demon Armor/Skin, Felstone).")
