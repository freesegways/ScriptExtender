-- Mana Management Module
-- Handles Mana Potions, Runes, and other efficient mana restoration.

-- --- HELPER ---
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
                type = entry.type,
                healthCost = entry.healthCost or 0
            })
        end
    end
    table.sort(available, function(a, b) return a.avg > b.avg end) -- Descending Order (Big to Small)
    return available
end

-- --- MAIN EXPORT ---

ScriptExtender_Register("UseSmartMana", "Uses Mana Potions or Runes efficiently based on missing Mana.")
function UseSmartMana()
    local m_max = UnitManaMax("player")
    local m_curr = UnitMana("player")
    local m_deficit = m_max - m_curr

    if m_deficit < 300 then
        -- ScriptExtender_Print("Mana almost full.")
        return
    end -- Don't bother for small amounts

    local items = GetAvailableConsumables("MANA")
    if table.getn(items) == 0 then
        ScriptExtender_Print("No mana consumables found.")
        return
    end

    -- Goal: Use the Largest potion that does NOT overfill (waste) mana.
    -- If even the smallest potion overfills, and we are desperate? No, usually mana is about efficiency.
    -- Exception: If we are OOM (< 10%), use Biggest immediately regardless of efficiency.

    local chosen = nil

    if m_curr < (m_max * 0.10) then
        -- PANIC: Use Biggest Safe Item immediately
        local bestPanic = nil
        for _, item in ipairs(items) do
            local safe = true
            if item.healthCost > 0 and UnitHealth("player") < (item.healthCost + 500) then safe = false end
            if safe then
                bestPanic = item
                break -- Found biggest safe one
            end
        end
        chosen = bestPanic
    else
        -- EFFICIENCY: Find the Biggest item that is <= deficit (No waste)
        local bestEfficient = nil

        for _, item in ipairs(items) do
            local safe = true
            if item.healthCost > 0 and UnitHealth("player") < (item.healthCost + 500) then safe = false end

            if safe then
                if item.avg <= m_deficit then
                    bestEfficient = item
                    break -- Since we sort Big->Small, the first one that fits is the Biggest Efficient one.
                end
            end
        end
        chosen = bestEfficient
    end

    if chosen then
        ScriptExtender_Log("Mana: Using " .. chosen.name .. " (Gain ~" .. chosen.avg .. ")")
        UseContainerItem(chosen.bag, chosen.slot)
    else
        ScriptExtender_Log("Mana: Waiting for larger deficit.")
    end
end
