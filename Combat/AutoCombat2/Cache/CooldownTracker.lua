-- Combat/AutoCombat2/Cache/CooldownTracker.lua
-- Helper to track internal cooldowns or debuff expirations not available via API

if ScriptExtender_CooldownTracker then return end

ScriptExtender_CooldownTracker = {
    cooldowns = {},

    -- Set a cooldown key to expire at specific time
    Set = function(key, duration)
        ScriptExtender_CooldownTracker.cooldowns[key] = GetTime() + duration
    end,

    -- Check if valid (not expired)
    IsReady = function(key)
        local expiry = ScriptExtender_CooldownTracker.cooldowns[key]
        if not expiry then return true end
        return GetTime() > expiry
    end,

    -- Get remaining time
    GetRemaining = function(key)
        local expiry = ScriptExtender_CooldownTracker.cooldowns[key]
        if not expiry then return 0 end
        local remaining = expiry - GetTime()
        return (remaining > 0) and remaining or 0
    end
}
