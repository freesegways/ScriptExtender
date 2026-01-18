-- Features/NextSpells.lua
-- Prints the list of spells available at the next learnable level and their total cost.

local function GetMoneyString(copper)
    if not copper then return "0c" end
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local cop = copper % 100

    local str = ""
    if gold > 0 then str = str .. gold .. "g " end
    if silver > 0 then str = str .. silver .. "s " end
    str = str .. cop .. "c"
    return str
end

ScriptExtender_Register("NextSpells", "Lists available spells at the next learnable level.")

function NextSpells()
    local _, class = UnitClass("player")
    local level = UnitLevel("player")

    if not ScriptExtender_SpellLevels then
        ScriptExtender_Print("Spell data not loaded.")
        return
    end

    local classSpells = ScriptExtender_SpellLevels[class]
    if not classSpells then
        ScriptExtender_Print("No spell data for class " .. tostring(class))
        return
    end

    -- Find the next level with spells greater than current level
    local nextLevel = 100
    local found = false
    local maxKnownLevel = 0

    for lvl, _ in pairs(classSpells) do
        if lvl > maxKnownLevel then maxKnownLevel = lvl end
        if lvl > level and lvl < nextLevel then
            nextLevel = lvl
            found = true
        end
    end

    if not found then
        ScriptExtender_Print("No future spells found. You are at max known spell level!")
        return
    end

    local spells = classSpells[nextLevel]
    if not spells then return end

    ScriptExtender_Print("Next Spells at Level " .. nextLevel .. ":")

    local totalCost = 0
    for _, spell in ipairs(spells) do
        local cost = spell.learnCost or spell.cost or 0
        totalCost = totalCost + cost
        DEFAULT_CHAT_FRAME:AddMessage(" - " .. spell.name .. " (" .. GetMoneyString(cost) .. ")")
    end

    DEFAULT_CHAT_FRAME:AddMessage("Total Training Cost: " .. GetMoneyString(totalCost))
end
