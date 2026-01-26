-- Utils/SpellUtils.lua

ScriptExtender_SpellUtils = {}

-- Scanner Tooltip for Action identification
local scanner = CreateFrame("GameTooltip", "ScriptExtenderScanTooltip", nil, "GameTooltipTemplate")
scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

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
-- Cache IDs to avoid expensive API loops
ScriptExtender_SpellUtils.IDCache = {}

function ScriptExtender_GetSpellID(spellName)
    -- Check Cache
    local cached = ScriptExtender_SpellUtils.IDCache[spellName]
    if cached then
        -- Verify validity (Spellbook shifts during training)
        local n, _ = GetSpellName(cached, BOOKTYPE_SPELL)
        if n and string.find(spellName, n, 1, true) then
            return cached
        end
        -- Cache invalid, clear it
        ScriptExtender_SpellUtils.IDCache[spellName] = nil
    end

    -- Normalization: Handle "Spell Name(Rank X)" vs "Spell Name (Rank X)"
    -- Normalization: Handle "Spell Name(Rank X)" vs "Spell Name (Rank X)"
    -- Also handle user inputs like "Spell Name" (implied any rank) matching "Spell Name" in book.
    local targetBase = spellName
    local targetRank = nil

    local s, e, r = string.find(spellName, "%(Rank (%d+)%)")
    -- If using "Spell Name(Rank X)" syntax without space, s is start of "("
    if not s then
        -- try search for "(Rank " manually if string.find failed due to escaping?
        -- No, the pattern "%(Rank (%d+)%)" handles parens.
        -- Let's try simple match.
        s, e, r = string.find(spellName, "Rank (%d+)")
    end

    if s then
        targetRank = "Rank " .. r
        targetBase = string.sub(spellName, 1, s - 1)
        -- Trim trailing parens or whitespace
        targetBase = string.gsub(targetBase, "%(", "")
        targetBase = string.gsub(targetBase, "%s+$", "")
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
                    ScriptExtender_SpellUtils.IDCache[spellName] = i
                    return i
                end
            else
                -- No Rank Requested (Base Name Only)
                ScriptExtender_SpellUtils.IDCache[spellName] = i
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

ScriptExtender_ActionSlotCache = {}

function ScriptExtender_FindSpellActionSlot(spellName)
    if ScriptExtender_ActionSlotCache[spellName] then
        local i = ScriptExtender_ActionSlotCache[spellName]
        -- Verify it hasn't changed (simple texture check is efficient, exact name check is rigorous)
        -- We'll trust cache for now to avoid perf hit, or clear it occasionally?
        -- Let's just return cached.
        return i
    end

    for i = 1, 120 do
        if HasAction(i) then
            scanner:ClearLines()
            scanner:SetAction(i)
            local txt = ScriptExtenderScanTooltipTextLeft1:GetText()
            if txt == spellName then
                ScriptExtender_ActionSlotCache[spellName] = i
                return i
            end
        end
    end
    return nil
end

--- Checks if a spell is in range of the CURRENT TARGET.
-- Requires the spell to be on an action bar.
-- @param spellName Name of the spell.
-- @return boolean|nil True if in range, False if out of range, Nil if unknown (not on bar).
function ScriptExtender_IsSpellInRange(spellName)
    local slot = ScriptExtender_FindSpellActionSlot(spellName)
    if slot then
        local valid = IsActionInRange(slot)
        if valid == 1 then return true end
        if valid == 0 then return false end
        -- valid is nil if action is not applicable index?
    end
    return nil
end
