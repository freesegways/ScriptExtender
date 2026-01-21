-- Utils/FindSpell.lua

--- Searches for spells matching the query string in the Spellbook and internal DB.
-- @param msg The query string.
-- @return a table of matches {name, index}
function FindSpells(msg)
    if not msg then return {} end
    -- Trim leading/trailing whitespace
    local query = string.gsub(msg, "^%s*(.-)%s*$", "%1")
    query = string.lower(query)

    if query == "" then
        ScriptExtender_Print("Usage: /se findspell <name>")
        return {}
    end

    local results = {}
    local found = false
    local i = 1
    while true do
        local name, rank = GetSpellName(i, "spell")
        if not name then break end

        local fullName = name
        if rank and rank ~= "" then
            fullName = fullName .. " (" .. rank .. ")"
        end

        if string.find(string.lower(fullName), query, 1, true) then
            table.insert(results, { name = fullName, index = i })

            -- Only print in debug mode
            ScriptExtender_Log(string.format("Index: %d | %s", i, fullName))
            found = true
        end
        i = i + 1
    end

    if not found then
        ScriptExtender_Log("No spells found matching '" .. query .. "'.")
    end

    return results
end

ScriptExtender_Register("FindSpells", "Search for a spell by name (Smart Match). Return: Table of matches.")
