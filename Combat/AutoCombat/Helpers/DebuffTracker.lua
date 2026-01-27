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
local defaultDurations = {
    ["Curse of Agony"] = 24,
    ["Corruption"] = 18,
    ["Immolate"] = 15,
    ["Siphon Life"] = 30,
    ["Curse of the Elements"] = 300,
    ["Curse of Shadow"] = 300,
    ["Curse of Recklessness"] = 120,
    ["Curse of Tongues"] = 30,
    ["Curse of Weakness"] = 120,
    ["Fear"] = 20,
    ["Howl of Terror"] = 15,
    ["Banish"] = 30,
    ["Dark Harvest"] = 30 -- Assuming 30s or similar
}

-- Helper to clean old entries (Garbage Collection)
-- Call this periodically (e.g. every few seconds or on Analyze)
function ScriptExtender_DebuffTracker_Cleanup()
    local now = GetTime()
    for pid, debuffs in pairs(trackedDebuffs) do
        local count = 0
        for name, expire in pairs(debuffs) do
            if expire < now then
                debuffs[name] = nil
            else
                count = count + 1
            end
        end
        -- If table empty, remove the unit key
        if count == 0 then
            trackedDebuffs[pid] = nil
        end
    end
end

-- Registers a debuff application
function ScriptExtender_TrackDebuff(pseudoID, spellName, duration)
    -- We use PseudoID for tracking.
    if not pseudoID or not spellName then return end

    local now = GetTime()
    if not duration then
        duration = defaultDurations[spellName] or 15
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
function ScriptExtender_GetTrackedDebuffs()
    return trackedDebuffs
end
