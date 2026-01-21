-- Utils/FindSpell.lua

local BOOKTYPE_SPELL = "spell"

--- Searches for spells matching the query string in the Spellbook and internal DB.
-- @param msg The query string.
function FindSpell(msg)
    ScriptExtender_Log("DEBUG: FindSpell executing with: " .. tostring(msg))

    local query = string.lower(msg)
    -- Ignore tokenization for now, just search for raw string match
    ScriptExtender_Print("Searching Spellbook for: " .. query)

    local i = 1
    while true do
        local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end

        local fullName = name
        if rank then fullName = fullName .. " (" .. rank .. ")" end

        -- Simple check: does the name contain the query text?
        if string.find(string.lower(fullName), query, 1, true) then
            ScriptExtender_Print(string.format("ID: %d | %s", i, fullName))
        end
        i = i + 1
    end
end

ScriptExtender_Register("FindSpell", "Search for a spell by name (Smart Match).")
