-- Classes/Warrior/AutoWarriorBuffs.lua
-- Automatically handles Warrior buffs (Battle Shout).

if not AB_Track then AB_Track = {} end
if not AB_LastPrint then AB_LastPrint = 0 end

function AutoWarriorBuffs(m)
    local tm, th = GetTime(), (tonumber(m) or 2) * 60
    local S = { "Battle Shout" }
    local T = { "BattleShout" }
    local D = { 120 }      -- 2 Minutes
    local U = { "player" } -- Battle Shout is AoE, checking player is sufficient tracking

    local av = { false }
    local i = 1
    while true do
        local n = GetSpellName(i, 1)
        if not n then break end
        if n == S[1] then av[1] = true end
        i = i + 1
    end

    if not av[1] then return end

    local function GetSt(u, id)
        local lim = th
        local j = 0
        while GetPlayerBuff(j, "HELPFUL") >= 0 do
            local b = GetPlayerBuff(j, "HELPFUL")
            local tx = GetPlayerBuffTexture(b)
            if tx and string.find(tx, T[id]) then
                local rem = GetPlayerBuffTimeLeft(b)
                if rem < lim then return 50, math.floor(rem / 60) .. "m" end
                return 0, math.floor(rem / 60) .. "m"
            end
            j = j + 1
        end
        return 100, "Miss"
    end

    local best = { sc = -1 }

    -- Check Player for Battle Shout
    if UnitExists("player") then
        local sc, txt = GetSt("player", 1)
        if sc > 0 then
            -- Check Rage
            local rage = UnitMana("player")
            if rage >= 10 then
                best = { sc = sc, u = "player", sp = S[1] }
            else
                -- Try Bloodrage to get rage?
                -- Only if we are really missing it (Score 100) and healthy
                if sc == 100 and (UnitHealth("player") / UnitHealthMax("player")) > 0.5 then
                    -- Check Bloodrage availability?
                    -- For now, just warn or skip. Simpler to just skip if no rage.
                    -- best.error = "No Rage"
                end
            end
        end
    end

    if best.u then
        CastSpellByName(best.sp)
        ScriptExtender_Print("[AB] Casting " .. best.sp)
    end
end

ScriptExtender_Register("AutoWarriorBuffs", "Automatically maintains Battle Shout (if Rage permits).")
