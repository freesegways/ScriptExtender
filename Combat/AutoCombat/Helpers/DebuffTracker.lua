-- Helpers/DebuffTracker.lua
-- Tracks debuffs applied by the player to avoid rescanning games state or handling latency.
-- This is a soft-state tracker; it doesn't hook COMBAT_LOG_EVENT in this simple version,
-- but relies on the Analyze/Cast logic to call TrackDebuff when it attempts a cast.
-- Refinements can hook "SPELLCAST_STOP" or similar later.

if not ScriptExtender_DebuffTracker then
    ScriptExtender_DebuffTracker = {}
end

-- Table to store debuffs: [TargetPseudoID] = { [SpellName] = ExpirationTime }
local trackedDebuffs = {}

-- Duration defaults (if not provided)
-- Helper to get duration from Metadata
local function GetDuration(spellName)
    if ScriptExtender_ClassDebuffs then
        for class, spells in pairs(ScriptExtender_ClassDebuffs) do
            if spells[spellName] then
                -- Handle table or legacy string
                local meta = spells[spellName]
                if type(meta) == "table" and meta.duration then
                    return meta.duration
                end
            end
        end
    end
    -- Fallback defaults
    local defaults = {
        ["Curse of Agony"] = 24,
        ["Corruption"] = 18,
        ["Immolate"] = 15,
        ["Siphon Life"] = 30
    }
    return defaults[spellName] or 15
end

-- Registers a debuff application
function ScriptExtender_TrackDebuff(pseudoID, spellName, duration)
    -- We use PseudoID for tracking.
    if not pseudoID or not spellName then return end

    local now = GetTime()
    if not duration then
        duration = GetDuration(spellName)
    end

    if not trackedDebuffs[pseudoID] then trackedDebuffs[pseudoID] = {} end
    trackedDebuffs[pseudoID][spellName] = now + duration

    -- ScriptExtender_Log("Tracked: " .. spellName .. " on " .. pseudoID .. " until " .. (now + duration))
end

-- Checks if a debuff is currently active (according to our local tracker)
-- Returns: true/false, remainingTime
function ScriptExtender_IsDebuffTracked(pseudoID, spellName)
    if not pseudoID or not spellName then return false, 0 end

    local unitDebuffs = trackedDebuffs[pseudoID]
    if not unitDebuffs then return false, 0 end

    local expire = unitDebuffs[spellName]
    if not expire then return false, 0 end

    local rem = expire - GetTime()
    if rem <= 0 then
        -- Lazy cleanup
        unitDebuffs[spellName] = nil
        return false, 0
    end

    return true, rem
end

-- Debug Access
-- Generic Helper to check if a specific debuff is active, handling Multi-Class/Stacking logic.
-- REPLACES: Local Class-Specific HasDebuff functions.
function ScriptExtender_HasDebuffMatch(unit, spellName, className, pseudoID)
    -- 1. Metadata Lookup
    local meta = nil
    if ScriptExtender_ClassDebuffs and ScriptExtender_ClassDebuffs[className] then
        meta = ScriptExtender_ClassDebuffs[className][spellName]
    end

    local texturePartial = nil
    local isStackable = true -- Default to TRUE (assume per-player if unknown)

    if meta then
        if type(meta) == "table" then
            texturePartial = meta.texture
            isStackable = meta.stackable
        else
            texturePartial = meta -- Legacy string support
        end
    end

    -- 2. Check Personal Tracker (Always Trusted if positive)
    local tracked = false
    if pseudoID and trackedDebuffs[pseudoID] and trackedDebuffs[pseudoID][spellName] then
        -- Verify not expired (lazy check usually handles this but double check)
        if trackedDebuffs[pseudoID][spellName] > GetTime() then
            tracked = true
        end
    end

    if tracked then
        -- Verify Visuals (Prevent Desync)
        if texturePartial then
            if not ScriptExtender_HasDebuff(unit, texturePartial) then
                -- Visual Missing -> Tracker Desync
                return false
            end
        end
        return true
    end

    -- 3. Tracker says NO. Check Visuals + Reconciliation.
    if texturePartial then
        -- Helper from AuraUtils
        local visualCount = 0
        if ScriptExtender_GetVisualDebuffCount then
            visualCount = ScriptExtender_GetVisualDebuffCount(unit, texturePartial)
        else
            -- Fallback if AuraUtils not available (Unit Tests)
            for i = 1, 16 do
                local d = UnitDebuff(unit, i)
                if d and string.find(d, texturePartial) then visualCount = visualCount + 1 end
            end
        end

        if visualCount > 0 then
            -- If NOT stackable (e.g. Fear), finding one means it's active.
            -- We don't care who cast it (unless we want to overwrite, but usually we respect it).
            if not isStackable then
                return true
            end

            -- If Stackable (Corruption), is it mine?
            -- Use global Class Count
            local classCount = 1
            if ScriptExtender_GetClassCount then
                classCount = ScriptExtender_GetClassCount(className)
            end

            -- Case A: Single Class (Me) + Visual Present = Mine (Tracker Lost It)
            if classCount <= 1 then
                return true
            end

            -- Case B: Multi Class
            if visualCount < classCount then
                -- E.g. 2 Warlocks, 1 Corruption. Tracker says NO.
                -- Assume the 1 Corruption belongs to Other.
                -- Return FALSE (Safe to cast).
                return false
            else
                -- E.g. 2 Warlocks, 2 Corruptions. Tracker says NO.
                -- Everyone has it. I must have it.
                -- Return TRUE (Tracker Desync).
                return true
            end
        end
    end

    return false
end
