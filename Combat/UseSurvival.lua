-- Survival Logic (Health Protection)
-- Handles Defensives, Healthstones, and Healing Potions

-- --- HELPERS ---

local function HasDebuff(textureName)
    local i = 1
    while UnitDebuff("player", i) do
        local d = UnitDebuff("player", i)
        if d and string.find(d, textureName) then return true end
        i = i + 1
    end
    return false
end

local function HasBuff(textureName)
    local i = 1
    while UnitBuff("player", i) do
        local b = UnitBuff("player", i)
        if b and string.find(b, textureName) then return true end
        i = i + 1
    end
    return false
end

local function IsPetSpellReady(spellName)
    local i = 1
    while true do
        local name, rank = GetSpellName(i, BOOKTYPE_PET)
        if not name then break end
        if name == spellName then
            local start, duration = GetSpellCooldown(i, BOOKTYPE_PET)
            if start == 0 then return true end
        end
        i = i + 1
    end
    return false
end

local function IsSpellReady(spellName)
    local i = 1
    while true do
        local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end

        if name == spellName then
            local start, duration = GetSpellCooldown(i, BOOKTYPE_SPELL)
            if start == 0 then return true end
        end
        i = i + 1
    end
    return false
end

local function GetAvailableConsumables(category)
    local available = {}
    local db = ScriptExtender_PotionDB[category]
    if not db then return available end

    for _, entry in ipairs(db) do
        local foundBag, foundSlot = nil, nil
        for b = 0, 4 do
            for s = 1, GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b, s)
                if link and string.find(link, "%[" .. entry.name .. "%]") then
                    local start, duration, enable = GetContainerItemCooldown(b, s)
                    if start == 0 then
                        foundBag = b
                        foundSlot = s
                        break
                    end
                end
            end
            if foundBag then break end
        end
        if foundBag then
            table.insert(available, {
                name = entry.name,
                avg = (entry.min + entry.max) / 2,
                bag = foundBag,
                slot = foundSlot,
                type = entry.type
            })
        end
    end
    table.sort(available, function(a, b) return a.avg > b.avg end)
    return available
end

-- --- CLASS DEFENSIVES ---

local function CastClassDefensive(mobCount, hpPct)
    local _, class = UnitClass("player")
    -- Default hpPct if not provided (safety)
    if not hpPct then hpPct = UnitHealth("player") / UnitHealthMax("player") end

    if class == "PRIEST" then
        if hpPct < 0.45 and not HasDebuff("AshesToAshes") and not HasDebuff("Spell_Holy_PowerWordShield") then
            CastSpellByName("Power Word: Shield")
            return true
        end
        if hpPct < 0.35 and IsSpellReady("Desperate Prayer") then
            CastSpellByName("Desperate Prayer")
            return true
        end
        if hpPct < 0.40 and mobCount > 0 and IsSpellReady("Fade") then
            CastSpellByName("Fade")
            return true
        end
    elseif class == "MAGE" then
        -- Ice Barrier (50%)
        if hpPct < 0.50 and IsSpellReady("Ice Barrier") then
            CastSpellByName("Ice Barrier")
            return true
        end
        -- Mana Shield (35%)
        if hpPct < 0.35 and IsSpellReady("Mana Shield") and (UnitMana("player") / UnitManaMax("player") > 0.4) then
            CastSpellByName("Mana Shield")
            return true
        end
        -- Ice Block (20%)
        if hpPct < 0.20 and IsSpellReady("Ice Block") then
            CastSpellByName("Ice Block")
            return true
        end
    elseif class == "WARRIOR" then
        if hpPct < 0.30 and IsSpellReady("Last Stand") then
            CastSpellByName("Last Stand")
            return true
        end
        if hpPct < 0.25 and IsSpellReady("Shield Wall") then
            CastSpellByName("Shield Wall")
            return true
        end
    elseif class == "ROGUE" then
        if hpPct < 0.45 and IsSpellReady("Evasion") then
            CastSpellByName("Evasion")
            return true
        end
        if hpPct < 0.35 and IsSpellReady("Blind") and UnitExists("target") then
            CastSpellByName("Blind")
            return true
        end
        if hpPct < 0.20 and IsSpellReady("Vanish") then
            CastSpellByName("Vanish")
            return true
        end
    elseif class == "HUNTER" then
        if hpPct < 0.40 and IsSpellReady("Deterrence") then
            CastSpellByName("Deterrence")
            return true
        end
        if hpPct < 0.20 and IsSpellReady("Feign Death") then
            CastSpellByName("Feign Death")
            return true
        end
    elseif class == "PALADIN" then
        local isTank = HasBuff("SealOfFury") or HasBuff("RighteousFury")

        if isTank then
            -- TANK MODE: Use Lay on Hands as last resort (15%).
            if hpPct < 0.15 and IsSpellReady("Lay on Hands") then
                CastSpellByName("Lay on Hands")
                return true
            end
        else
            -- NORMAL MODE
            if hpPct < 0.35 and IsSpellReady("Divine Shield") and not HasDebuff("Banish") then
                CastSpellByName("Divine Shield")
                return true
            end
            if hpPct < 0.35 and IsSpellReady("Divine Protection") and not HasDebuff("Banish") then
                CastSpellByName("Divine Protection")
                return true
            end
            if hpPct < 0.10 and IsSpellReady("Lay on Hands") then
                CastSpellByName("Lay on Hands")
                return true
            end
        end
    elseif class == "WARLOCK" then
        -- 1. Voidwalker Sacrifice
        -- Condition: 3+ mobs OR < 30% HP
        if (mobCount and mobCount >= 3) or hpPct < 0.30 then
            if UnitExists("pet") and not UnitIsDead("pet") and IsPetSpellReady("Sacrifice") then
                CastSpellByName("Sacrifice")
                return true
            end
        end

        -- 2. Spellstone (35%)
        if hpPct < 0.35 then
            local link = GetInventoryItemLink("player", 17)
            if link and string.find(link, "Spellstone") then
                local start, dur, enable = GetInventoryItemCooldown("player", 17)
                if start == 0 and enable == 1 then
                    UseInventoryItem(17)
                    return true
                end
            end
        end

        -- 3. Death Coil (35%)
        if hpPct < 0.35 and IsSpellReady("Death Coil") and UnitExists("target") and UnitCanAttack("player", "target") then
            CastSpellByName("Death Coil")
            return true
        end
    end
    return false
end

-- --- MAIN EXPORT ---

ScriptExtender_Register("UseSurvival", "Uses Class Defensives, Healthstones, or Potions based on Critical Health.")
function UseSurvival()
    -- MOB SCAN (Distribution)
    local totalMobs, dist = 0, {}
    if GetMobDistribution then
        totalMobs, dist = GetMobDistribution()
    end
    local mobsOnMe = dist["player"] or 0
    if mobsOnMe > 0 then
        ScriptExtender_Log("Survival: Mobs attacking me: " .. mobsOnMe)
    end

    local hp_max = UnitHealthMax('player')
    local hp_current = UnitHealth('player')
    local hp_deficit = hp_max - hp_current

    if hp_current == hp_max then
        ScriptExtender_Print("Health is full.")
        return
    end

    -- 1. CLASS ABILITIES / DEFENSIVES (Check Logic)
    -- We pass hp_pct to let class logic decide (e.g. Tank LoH < 15%, Mage IceBlock < 20%)
    local hp_pct = hp_current / hp_max
    if CastClassDefensive(mobsOnMe, hp_pct) then
        ScriptExtender_Log("Survival: Cast Class Defensive!")
        -- If we used a defensive, do we stop? Or do we also pop a potion?
        -- Usually if we popped a panic button like Ice Block or Bubble, we are safe.
        return
    end

    -- 2. CONSUMABLES
    local items = GetAvailableConsumables("HEALTH")
    if table.getn(items) == 0 then return end

    local chosen = nil

    if hp_current < (hp_max * 0.30) then
        chosen = items[1] -- Maximum Panic (Largest Heal)
    else
        -- Efficiency: Find smallest >= deficit
        local bestFit = nil
        for i = table.getn(items), 1, -1 do
            local item = items[i]
            if item.avg >= hp_deficit then
                bestFit = item
                chosen = bestFit
                break
            end
        end
        if not chosen then chosen = items[1] end
    end

    if chosen then
        -- Overkill protection for non-panic situations
        if hp_deficit < (chosen.avg * 0.6) and hp_current > (hp_max * 0.40) then
            -- ScriptExtender_Log("Survival: Saving " .. chosen.name .. " for bigger damage.")
            return
        end

        ScriptExtender_Log("Survival: " .. chosen.name)
        UseContainerItem(chosen.bag, chosen.slot)
    end
end
