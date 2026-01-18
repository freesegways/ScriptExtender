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

local function CastClassDefensive()
    local _, class = UnitClass("player")

    if class == "PRIEST" then
        if not HasDebuff("AshesToAshes") and not HasDebuff("Spell_Holy_PowerWordShield") then
            CastSpellByName("Power Word: Shield")
            return true
        end
        if IsSpellReady("Desperate Prayer") then
            CastSpellByName("Desperate Prayer")
            return true
        end
        if IsSpellReady("Fade") then
            CastSpellByName("Fade")
            return true
        end
    elseif class == "MAGE" then
        if IsSpellReady("Ice Barrier") then
            CastSpellByName("Ice Barrier")
            return true
        end
        if IsSpellReady("Mana Shield") and (UnitMana("player") / UnitManaMax("player") > 0.4) then
            CastSpellByName("Mana Shield")
            return true
        end
        if IsSpellReady("Ice Block") then
            CastSpellByName("Ice Block")
            return true
        end
    elseif class == "WARRIOR" then
        if IsSpellReady("Last Stand") then
            CastSpellByName("Last Stand")
            return true
        end
        if IsSpellReady("Shield Wall") then
            CastSpellByName("Shield Wall")
            return true
        end
    elseif class == "ROGUE" then
        if IsSpellReady("Evasion") then
            CastSpellByName("Evasion")
            return true
        end
        if IsSpellReady("Blind") and UnitExists("target") then
            CastSpellByName("Blind")
            return true
        end
        if IsSpellReady("Vanish") then
            CastSpellByName("Vanish")
            return true
        end
    elseif class == "HUNTER" then
        if IsSpellReady("Deterrence") then
            CastSpellByName("Deterrence")
            return true
        end
        if IsSpellReady("Feign Death") then
            CastSpellByName("Feign Death")
            return true
        end
    elseif class == "PALADIN" then
        if IsSpellReady("Divine Shield") and not HasDebuff("Banish") then
            CastSpellByName("Divine Shield")
            return true
        end
        if IsSpellReady("Divine Protection") and not HasDebuff("Banish") then
            CastSpellByName("Divine Protection")
            return true
        end
    end
    return false
end

-- --- MAIN EXPORT ---

ScriptExtender_Register("UseSurvival", "Uses Class Defensives, Healthstones, or Potions based on Critical Health.")
function UseSurvival()
    local hp_max = UnitHealthMax('player')
    local hp_current = UnitHealth('player')
    local hp_deficit = hp_max - hp_current

    if hp_current == hp_max then
        ScriptExtender_Print("Health is full.")
        return
    end

    -- 1. CRITICAL HP (< 35%) - USE CLASS ABILITIES
    if hp_current <= (hp_max * 0.35) then
        if CastClassDefensive() then
            ScriptExtender_Log("Survival: Cast Class Defensive!")
        end
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
