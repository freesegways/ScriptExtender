-- Priest Healing Profile Calculator
-- Calculates effective healing and HPM for all Priest spells based on stats.

function GetHealProfile()
    -- --- CONFIGURATION ---
    local PLUS_HEAL = 87    -- Your Total +Healing (Adjust as needed)
    local TALENT_MOD = 1.10 -- Multiplier (e.g. 1.10 for +10% Spiritual Guidance/Focus)
    local RENEW_MOD = 1.15  -- Multiplier for Renew (e.g. Improved Renew talent)

    -- CRITICAL FIX: Get Player Level to filter unknown spells
    local myLevel = UnitLevel("player")
    -- ---------------------

    -- DATABASE: [Level Learned, Mana Cost, Min Heal, Max Heal, Base Cast Time]
    local db = {
        -- LESSER HEAL
        { n = "Lesser Heal", r = 1, lvl = 1, m = 30, min = 46, max = 51, cast = 1.5 },
        { n = "Lesser Heal", r = 2, lvl = 4, m = 45, min = 71, max = 85, cast = 2.0 },
        { n = "Lesser Heal", r = 3, lvl = 10, m = 75, min = 135, max = 157, cast = 2.5 },
        -- HEAL
        { n = "Heal",       r = 1, lvl = 16, m = 155, min = 295, max = 341, cast = 3.0 },
        { n = "Heal",       r = 2, lvl = 22, m = 205, min = 429, max = 491, cast = 3.0 },
        { n = "Heal",       r = 3, lvl = 28, m = 255, min = 566, max = 642, cast = 3.0 },
        { n = "Heal",       r = 4, lvl = 34, m = 305, min = 712, max = 804, cast = 3.0 },
        -- FLASH HEAL
        { n = "Flash Heal", r = 1, lvl = 20, m = 125, min = 193, max = 237, cast = 1.5 },
        { n = "Flash Heal", r = 2, lvl = 26, m = 155, min = 258, max = 314, cast = 1.5 },
        { n = "Flash Heal", r = 3, lvl = 32, m = 185, min = 327, max = 393, cast = 1.5 },
        { n = "Flash Heal", r = 4, lvl = 38, m = 215, min = 400, max = 478, cast = 1.5 },
        { n = "Flash Heal", r = 5, lvl = 44, m = 265, min = 518, max = 616, cast = 1.5 },
        { n = "Flash Heal", r = 6, lvl = 50, m = 315, min = 644, max = 764, cast = 1.5 },
        { n = "Flash Heal", r = 7, lvl = 56, m = 380, min = 812, max = 958, cast = 1.5 },
        -- GREATER HEAL
        { n = "Greater Heal", r = 1, lvl = 40, m = 370, min = 899, max = 1013, cast = 3.0 },
        { n = "Greater Heal", r = 2, lvl = 46, m = 455, min = 1149, max = 1289, cast = 3.0 },
        { n = "Greater Heal", r = 3, lvl = 52, m = 545, min = 1437, max = 1609, cast = 3.0 },
        { n = "Greater Heal", r = 4, lvl = 58, m = 655, min = 1796, max = 2004, cast = 3.0 },
        { n = "Greater Heal", r = 5, lvl = 60, m = 710, min = 1966, max = 2194, cast = 3.0 },
        -- RENEW
        { n = "Renew",      r = 1, lvl = 8, m = 30, min = 45, max = 45, cast = 3.5 },
        { n = "Renew",      r = 2, lvl = 14, m = 65, min = 100, max = 100, cast = 3.5 },
        { n = "Renew",      r = 3, lvl = 20, m = 105, min = 175, max = 175, cast = 3.5 },
        { n = "Renew",      r = 4, lvl = 26, m = 140, min = 245, max = 245, cast = 3.5 },
        { n = "Renew",      r = 5, lvl = 32, m = 170, min = 315, max = 315, cast = 3.5 },
        { n = "Renew",      r = 6, lvl = 38, m = 205, min = 400, max = 400, cast = 3.5 },
        { n = "Renew",      r = 7, lvl = 44, m = 250, min = 510, max = 510, cast = 3.5 },
        { n = "Renew",      r = 8, lvl = 50, m = 305, min = 650, max = 650, cast = 3.5 },
        { n = "Renew",      r = 9, lvl = 56, m = 365, min = 810, max = 810, cast = 3.5 },
        { n = "Renew",      r = 10, lvl = 60, m = 410, min = 970, max = 970, cast = 3.5 },
    }

    local report = {}

    for _, s in ipairs(db) do
        -- *** FILTER: Only process spells we know ***
        if s.lvl <= myLevel then
            -- 1. BASE COEFFICIENT (Cast Time / 3.5)
            local coeff = s.cast / 3.5

            -- 2. LEVEL PENALTY (Spells learned below 60 get penalty)
            local lvlPenalty = (s.lvl + 6) / 60
            if lvlPenalty > 1 then lvlPenalty = 1 end

            -- 3. SUB-20 PENALTY (Massive penalty for lowbie spells)
            local sub20 = 1.0
            if s.lvl < 20 then
                sub20 = 1 - ((20 - s.lvl) * 0.0375)
            end

            -- TOTAL COEFFICIENT
            local finalCoeff = coeff * lvlPenalty * sub20

            -- 4. CALCULATE OUTPUT
            local bonus = PLUS_HEAL * finalCoeff
            local avgHeal = ((s.min + s.max) / 2) + bonus

            -- Apply Talent Multipliers
            local multiplier = TALENT_MOD
            if s.n == "Renew" then multiplier = multiplier * RENEW_MOD end

            avgHeal = avgHeal * multiplier
            local hpm = avgHeal / s.m

            -- 5. FORMAT OUTPUT
            local id = s.n .. "(Rank " .. s.r .. ")"
            report[id] = {
                heal = math.floor(avgHeal),
                mana = s.m,
                hpm = tonumber(string.format("%.2f", hpm)),
                lvl = s.lvl -- For sorting if needed
            }
        end
    end

    return report
end
