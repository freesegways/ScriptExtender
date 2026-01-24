-- Utils/SpellUtils.lua

ScriptExtender_SpellUtils = {}

--- Retrieves the data for the highest rank of a spell available to the player.
-- @param baseName The base name of the spell (e.g., "Shadowburn").
-- @param class The class to look up (default: player's class).
-- @return The spell data table (name, cost, min, max, etc.) or nil if not found.
function ScriptExtender_GetHighestSpellData(baseName, classToken)
    if not classToken then
        _, classToken = UnitClass("player")
    end

    local spellData = ScriptExtender_SpellLevels[classToken]
    if not spellData then return nil end

    local playerLevel = UnitLevel("player")
    local bestSpell = nil
    local bestRank = -1

    -- Iterate through levels 1 to playerLevel
    for lvl = 1, playerLevel do
        local spellsAtLevel = spellData[lvl]
        if spellsAtLevel then
            for _, spell in ipairs(spellsAtLevel) do
                -- Check if spell name starts with baseName
                -- We look for "BaseName (Rank X)" or just "BaseName"
                local sName = spell.name
                local found = false

                -- Exact match
                if sName == baseName then
                    found = true
                    -- Usually spells without rank are Rank 1 or unique
                elseif string.sub(sName, 1, string.len(baseName)) == baseName then
                    -- Check if it's followed by " (Rank" or is the exact name
                    local remainder = string.sub(sName, string.len(baseName) + 1)
                    if remainder == "" or string.find(remainder, "^ %(Rank %d+%)$") then
                        found = true
                    end
                end

                if found then
                    -- Extract rank
                    local _, _, rankStr = string.find(sName, "Rank (%d+)")
                    local rank = tonumber(rankStr) or 1 -- Default to 1 if no rank specified

                    if rank > bestRank then
                        bestRank = rank
                        bestSpell = spell
                    end
                end
            end
        end
    end

    return bestSpell
end

--- Estimates the average damage of a spell.
-- @param baseName The base name of the spell.
-- @return The average damage (number) or 0.
function ScriptExtender_GetSpellDamage(baseName)
    local data = ScriptExtender_GetHighestSpellData(baseName)
    if data and data.min and data.max then
        return (data.min + data.max) / 2
    elseif data and data.min then
        return data.min
    end
    return 0
end

--- Finds the SpellID in the spellbook by name.
-- @param spellName The full name or base name of the spell.
-- @return The spell ID (integer) or nil.
local BOOKTYPE_SPELL = "spell"

-- Cache IDs to avoid expensive API loops
local SpellIDCache = {}

function ScriptExtender_GetSpellID(spellName)
    -- Check Cache
    local cached = SpellIDCache[spellName]
    if cached then
        -- Verify validity (Spellbook shifts during training)
        local n, _ = GetSpellName(cached, BOOKTYPE_SPELL)
        if n and string.find(spellName, n, 1, true) then
            return cached
        end
        -- Cache invalid, clear it
        SpellIDCache[spellName] = nil
    end

    -- Normalization: Handle "Spell Name(Rank X)" vs "Spell Name (Rank X)"
    local targetBase = spellName
    local targetRank = nil

    local s, e, r = string.find(spellName, "Rank (%d+)")
    if s then
        targetRank = "Rank " .. r
        targetBase = string.sub(spellName, 1, s - 2) -- remove " (Rank X"
        -- Handle space/no-space
        if string.sub(targetBase, -1) == "(" then targetBase = string.sub(targetBase, 1, -2) end
        targetBase = string.gsub(targetBase, "%s+$", "") -- trim tail
    end

    local i = 1
    while true do
        local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end

        if name == targetBase or name == spellName then
            -- Found Base Name match
            if targetRank then
                -- Precise Rank Requested
                if rank == targetRank then
                    SpellIDCache[spellName] = i
                    return i
                end
            else
                -- No Rank Requested (Base Name Only)
                -- We found a rank of it.
                -- If we want "Best Rank", we should keep looping?
                -- Usually, GetSpellID is used for Cooldowns (Shared) or presence check.
                -- Returning the current index is fine.
                -- However, usually we want the Max Rank for 'CastSpell' usage if we used ID.
                -- But we use CastSpellByName.

                -- We return this ID.
                SpellIDCache[spellName] = i
                return i
            end
        end

        i = i + 1
    end
    return nil
end

--- Checks if a spell is ready to cast (not on Cooldown).
-- @param spellName The name of the spell.
-- @return boolean true if ready, false otherwise.
function ScriptExtender_IsSpellReady(spellName)
    local id = ScriptExtender_GetSpellID(spellName)

    -- If we can't find the spell ID, we assume it's NOT ready/valid to avoid spamming failed errors?
    -- User reports "complaining a lot about ability not being ready".
    -- This means IsSpellReady returns FALSE often.
    -- If id is NIL, we returned TRUE previously.
    -- If we return TRUE, script tries to cast -> fails -> WoW Error "Ability not ready yet".

    -- WAIT. User said "complaining ... about ability not being ready".
    -- Checks:
    -- 1. IsSpellReady returns false? Script skips. Silence.
    -- 2. IsSpellReady returns TRUE? Script casts. Game says "Ability not ready".
    -- Conclusion: IsSpellReady returns TRUE incorrectly!
    -- Why? Maybe ID not found -> Returns True.
    -- Fix: If ID not found, return FALSE. We cannot cast what we don't have.

    if not id then return false end

    local start, duration = GetSpellCooldown(id, BOOKTYPE_SPELL)
    if start > 0 and duration > 0 then
        local rem = duration - (GetTime() - start)
        -- GCD is usually 1.5s. If rem > 1.5, it's real CD.
        -- If we want to queue, we permit small REM?
        -- If rem > 0.1, we consider it not ready.
        if rem > 0.1 then
            return false
        end
    end
    return true
end

--- Checks if a specific spell (and rank) is learned in the spellbook.
-- @param spellName The exact name of the spell (e.g., "Create Healthstone (Major)").
-- @return boolean true if learned.
function ScriptExtender_IsSpellLearned(spellName)
    local id = ScriptExtender_GetSpellID(spellName)
    return (id ~= nil)
end
