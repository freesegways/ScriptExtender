-- Utils/NextSpells.lua
-- Utility and command to check which spells are available at the next learnable level and their cost.

function GetMoneyString_NextSpells(copper)
    if not copper then return "0c" end
    -- Modulo operator (%) is not available in WoW 1.12 Lua
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper - (gold * 10000)) / 100)
    local cop = copper - (gold * 10000) - (silver * 100)

    local str = ""
    if gold > 0 then str = str .. gold .. "g " end
    if silver > 0 then str = str .. silver .. "s " end
    if cop > 0 or str == "" then str = str .. cop .. "c" end
    return str
end

-- Utility function that returns raw data categorized by missed and upcoming
function GetNextSpellsData()
    local _, class = UnitClass("player")
    local level = UnitLevel("player")

    if not ScriptExtender_SpellLevels or not ScriptExtender_SpellLevels[class] then
        return nil, "No spell data found."
    end

    local classSpells = ScriptExtender_SpellLevels[class]

    -- 1. Collect and sort all levels available for this class
    local levels = {}
    for lvl, _ in pairs(classSpells) do
        table.insert(levels, tonumber(lvl))
    end
    table.sort(levels)

    local missedSpells = {}
    local upcomingSpells = {}
    local nextLevelAt = nil

    -- 2. Categorize spells into missed (<= level) and upcoming (first level > current level)
    for i = 1, table.getn(levels) do
        local lvl = levels[i]
        local spellsAtLvl = classSpells[lvl]

        if lvl <= level then
            -- Collect unlearned spells from current or past levels
            for j = 1, table.getn(spellsAtLvl) do
                local spell = spellsAtLvl[j]
                if not ScriptExtender_IsSpellLearned(spell.name, class) then
                    table.insert(missedSpells,
                        { name = spell.name, cost = (spell.learnCost or spell.cost or 0), level = lvl })
                end
            end
        elseif nextLevelAt == nil then
            -- This is the first learnable level in the future
            nextLevelAt = lvl
            for j = 1, table.getn(spellsAtLvl) do
                local spell = spellsAtLvl[j]
                if not ScriptExtender_IsSpellLearned(spell.name, class) then
                    table.insert(upcomingSpells,
                        { name = spell.name, cost = (spell.learnCost or spell.cost or 0), level = lvl })
                end
            end
        end
    end

    local result = {
        missed = missedSpells,
        upcoming = upcomingSpells,
        upcomingLevel = nextLevelAt
    }

    return result
end

-- Command function registered with ScriptExtender
function NextSpells()
    local data, err = GetNextSpellsData()

    if not data then
        ScriptExtender_Print(tostring(err))
        return
    end

    local totalCost = 0
    local foundAnything = false

    -- Display Missed Spells
    if table.getn(data.missed) > 0 then
        ScriptExtender_Print("MISSED Spells (Current/Past Levels):")
        for i = 1, table.getn(data.missed) do
            local s = data.missed[i]
            local cost = s.cost or 0
            totalCost = totalCost + cost
            if DEFAULT_CHAT_FRAME then
                DEFAULT_CHAT_FRAME:AddMessage(" - [Lvl " ..
                s.level .. "] " .. s.name .. " (" .. GetMoneyString_NextSpells(cost) .. ")")
            end
        end
        foundAnything = true
    end

    -- Display Upcoming Spells
    if data.upcomingLevel and table.getn(data.upcoming) > 0 then
        ScriptExtender_Print("UPCOMING Spells at Level " .. data.upcomingLevel .. ":")
        for i = 1, table.getn(data.upcoming) do
            local s = data.upcoming[i]
            local cost = s.cost or 0
            totalCost = totalCost + cost
            if DEFAULT_CHAT_FRAME then
                DEFAULT_CHAT_FRAME:AddMessage(" - " .. s.name .. " (" .. GetMoneyString_NextSpells(cost) .. ")")
            end
        end
        foundAnything = true
    end

    if not foundAnything then
        ScriptExtender_Print("All spells up to your next training level are already learned!")
    else
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("Total Training Cost: " .. GetMoneyString_NextSpells(totalCost))
        end
    end
end

-- Register the command
ScriptExtender_Register("NextSpells", "Lists unlearned spells from past levels and your next level.")
