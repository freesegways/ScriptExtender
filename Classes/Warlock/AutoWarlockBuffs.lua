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
        for b = 0, 4 do
            for s = 1, GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b, s)
                if link then
                    -- Extract name from link to ensure exact match
                    -- Link format: |cQqRrGgBb|Hitem:ID:Enchant:Gem:Gem:suffix|h[Name]|h|r
                    local _, _, name = string.find(link, "%[(.*)%]")

                    if name and string.lower(name) == string.lower(itemName) then
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
            -- Handle Healthstones (Best Rank Strategy)
            -- We iterate Top-Down. We rely on Level Check + IsSpellLearned to pick the best valid one.
            local HS_TYPES = {
                { spell = "Create Healthstone (Major)",   item = "Major Healthstone",   minLevel = 58 },
                { spell = "Create Healthstone (Greater)", item = "Greater Healthstone", minLevel = 46 },
                { spell = "Create Healthstone",           item = "Healthstone",         minLevel = 22 },
                { spell = "Create Healthstone (Lesser)",  item = "Lesser Healthstone",  minLevel = 10 },
                { spell = "Create Healthstone (Minor)",   item = "Minor Healthstone",   minLevel = 1 }
            }

            local pl = UnitLevel("player")

            -- 1. Handle Spellstones (Offhand / Use)
            local SS_TYPES = {
                { spell = "Create Spellstone (Major)",   item = "Major Spellstone",   minLevel = 60 },
                { spell = "Create Spellstone (Greater)", item = "Greater Spellstone", minLevel = 48 },
                { spell = "Create Spellstone",           item = "Spellstone",         minLevel = 36 }
            }

            for _, t in ipairs(SS_TYPES) do
                ScriptExtender_Log("Checking SS: " .. t.item)
                if pl >= t.minLevel then
                    local spellID = ScriptExtender_GetSpellID(t.spell)
                    if spellID then
                        ScriptExtender_Log("Found SpellID: " .. spellID .. " for " .. t.spell)
                        local b, s = FindItemInBag(t.item)
                        if not b then
                            ScriptExtender_Log("Missing " .. t.item .. ". Checking Reagents...")
                            local rb, rs = FindItemInBag("Soul Shard")
                            if rb then
                                if UnitMana("player") > 600 then -- Approx mana cost for high ranks
                                    ScriptExtender_Print("AutoBuff: Creating " .. t.item)
                                    CastSpell(spellID, "spell")
                                    return -- Action taken
                                end
                            else
                                ScriptExtender_Log("AutoBuff: Cannot create " .. t.item .. " - No Soul Shard.")
                                -- Continue to check lower ranks? Usually only want the best one.
                                -- If we have no shard, we can't craft ANY rank.
                                return
                            end
                        else
                            ScriptExtender_Log("Found " .. t.item .. " in Bag " .. b .. " Slot " .. s)
                            -- If we have the best one, stop.
                            break
                        end
                    end
                end
            end

            -- 2. Handle Healthstones (Best Rank Strategy)
            -- We iterate Top-Down. We rely on Level Check + IsSpellLearned to pick the best valid one.
            for _, t in ipairs(HS_TYPES) do
                -- Debug Log
                ScriptExtender_Log("Checking HS: " .. t.item)

                if pl >= t.minLevel then
                    local spellID = ScriptExtender_GetSpellID(t.spell)

                    if spellID then
                        ScriptExtender_Log("Found SpellID: " .. spellID .. " for " .. t.spell)
                        local b, s = FindItemInBag(t.item)

                        if not b then
                            -- Missing this rank. Create it.
                            ScriptExtender_Log("Missing " .. t.item .. ". Checking Reagents...")

                            local rb, rs = FindItemInBag("Soul Shard")
                            if rb then
                                if UnitMana("player") > 200 then
                                    ScriptExtender_Print("AutoBuff: Creating " .. t.item)
                                    -- Cast by ID as requested
                                    CastSpell(spellID, "spell")
                                    return -- Action taken, wait for next tick
                                end
                            else
                                ScriptExtender_Log("AutoBuff: Cannot create " .. t.item .. " - No Soul Shard.")
                                return -- No Shard, cannot craft any
                            end
                        else
                            -- Item exists, continue to next rank
                            ScriptExtender_Log("Found " .. t.item .. " in Bag " .. b .. " Slot " .. s)
                        end
                    else
                        -- Only print if we expected to have it (Level Check passed)
                        if pl >= t.minLevel then
                            ScriptExtender_Log("Spell not learned/found: " .. t.spell)
                        end
                    end
                end
            end
        end
    end
end

ScriptExtender_Register("AutoWarlockBuffs", "Automatically casts Warlock self-buffs (Demon Armor/Skin, Felstone).")
