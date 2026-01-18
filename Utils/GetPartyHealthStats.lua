-- GetPartyHealthStats Utility
-- Tracks health velocity (damage taken per sec) of party members.

-- Global History (Preserved between clicks)
if not WD_HealthHistory then WD_HealthHistory = {} end

function GetPartyHealthStats()
    local units = {"player", "party1", "party2", "party3", "party4"}
    local stats = {}
    local currTime = GetTime()

    for _, u in ipairs(units) do
        if UnitExists(u) then
            local currHP = UnitHealth(u)
            local maxHP = UnitHealthMax(u)
            local name = UnitName(u)
            
            -- 1. VELOCITY CALCULATION
            -- Init memory if missing or unit changed
            if not WD_HealthHistory[u] or WD_HealthHistory[u].name ~= name then
                WD_HealthHistory[u] = { hp = currHP, time = currTime, vel = 0, name = name }
            end
            
            local hist = WD_HealthHistory[u]
            local timeDiff = currTime - hist.time
            
            -- Only update Velocity if > 0.1s has passed to avoid math errors
            if timeDiff >= 0.1 then
                hist.vel = (currHP - hist.hp) / timeDiff
                hist.hp = currHP
                hist.time = currTime
            end
            
            -- 2. COMPILE STATS
            stats[u] = {
                current = currHP,
                max = maxHP,
                percent = (currHP / maxHP) * 100,
                deficit = maxHP - currHP,
                velocity = hist.vel,
                name = name
            }
        else
            WD_HealthHistory[u] = nil -- Cleanup
        end
    end

    -- Returns: stats['party1'].velocity, stats['party1'].deficit, etc.
    return stats
end
