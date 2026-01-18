-- Classes/Priest/AutoPriestBuffs.lua
-- Automatically handles Priest buffs (PWF, Spirit, Inner Fire, Fear Ward) for the party.

if not AB_Track then AB_Track = {} end
if not AB_LastPrint then AB_LastPrint = 0 end

function AutoPriestBuffs(m)
    local tm, th = GetTime(), (tonumber(m) or 5) * 60
    local S = { "Power Word: Fortitude", "Divine Spirit", "Inner Fire", "Fear Ward" }
    local T = { "Fortitude", "Spirit", "InnerFire", "Excorcism" }
    local D = { 1800, 1800, 600, 600 }
    local W = { 4, 3, 5, 2 }
    local U = { "player", "target", "party1", "party2", "party3", "party4" }

    -- 1. Check Spell Availability
    local av = { false, false, false, nil }
    local i = 1
    while true do
        local n = GetSpellName(i, 1)
        if not n then break end
        for j = 1, 4 do if n == S[j] then av[j] = (j == 4 and i or true) end end
        i = i + 1
    end

    -- HELPER: Get Buff State {Score, Text}
    -- Score: 100=Missing, 50=Expiring, 0=Fine
    local function GetSt(u, id)
        local lim = (id == 4 and 180 or th)
        -- PLAYER
        if u == "player" then
            local j = 0
            while GetPlayerBuff(j, "HELPFUL") >= 0 do
                local b = GetPlayerBuff(j, "HELPFUL")
                local tx = GetPlayerBuffTexture(b)
                if tx and string.find(tx, T[id]) then
                    local rem = GetPlayerBuffTimeLeft(b)
                    if id == 3 and GetPlayerBuffApplications(b) <= 5 then return 100, "Low" end
                    if rem < lim then return 50, math.floor(rem / 60) .. "m" end
                    return 0, math.floor(rem / 60) .. "m"
                end
                j = j + 1
            end
            return 100, "Miss"
            -- PARTY
        else
            local f, j = false, 1
            while UnitBuff(u, j) do
                if string.find(UnitBuff(u, j), T[id]) then
                    f = true
                    break
                end
                j = j + 1
            end
            local k = UnitName(u) .. T[id]
            if not f then
                AB_Track[k] = nil
                return 100, "Miss"
            end
            if not AB_Track[k] then return 0, "?" end
            local rem = D[id] - (tm - AB_Track[k])
            if rem < lim then return 50, math.floor(rem / 60) .. "m" end
            return 0, math.floor(rem / 60) .. "m"
        end
    end

    -- 2. Scan Loop (Find Best Candidate)
    local best = { sc = -1 }

    for _, u in ipairs(U) do
        if UnitExists(u) and not UnitIsDeadOrGhost(u) and UnitIsConnected(u) and UnitIsFriend("player", u) then
            local safe = UnitInParty(u) or u == "player" or (not UnitIsPVP("player") and not UnitIsPVP(u)) or
                UnitIsPVP("player")
            if safe then
                for id = 1, 4 do
                    local ok = false
                    if id == 3 then
                        if u == "player" and av[3] then ok = true end
                    elseif id == 4 then
                        if av[4] then
                            local s, d = GetSpellCooldown(av[4], 1)
                            if s == 0 or d <= 1.5 then ok = true end
                        end
                    else
                        if av[id] and (id == 1 or UnitPowerType(u) == 0) then ok = true end
                    end

                    if ok then
                        local inRange = (u == "player" or CheckInteractDistance(u, 4))
                        if inRange then
                            local sc, txt = GetSt(u, id)
                            if sc > 0 and (sc + W[id]) > best.sc then
                                best = { sc = sc + W[id], u = u, sp = S[id], id = id }
                            end
                        end
                    end
                end
            end
        end
    end

    -- 3. Execute OR Dashboard
    if best.u then
        TargetUnit(best.u)
        CastSpellByName(best.sp)
        if best.u ~= "target" then TargetLastTarget() end
        AB_Track[UnitName(best.u) .. T[best.id]] = tm
        ScriptExtender_Print("[AB] Casting " .. best.sp .. " > " .. UnitName(best.u))
    else
        -- NO CAST NEEDED: Print Status (With 10s Cooldown)
        if (tm - AB_LastPrint) > 10 then
            AB_LastPrint = tm -- Reset Timer

            ScriptExtender_Print("--- AutoBuffs Status ---")
            for _, u in ipairs(U) do
                if UnitExists(u) and UnitIsConnected(u) then
                    local line = " > " .. UnitName(u) .. ": "
                    for id = 1, 4 do
                        local show = false
                        if id == 3 and u == "player" then
                            show = true
                        elseif id == 2 and UnitPowerType(u) == 0 then
                            show = true
                        elseif id == 1 or id == 4 then
                            show = true
                        end

                        if show and (av[id] or (id == 4 and av[4])) then
                            local sc, txt = GetSt(u, id)
                            if u ~= "player" and not CheckInteractDistance(u, 4) and sc > 0 then txt = "OOR" end
                            local abbr = (id == 1 and "PWF" or (id == 2 and "DS" or (id == 3 and "IF" or "FW")))
                            line = line .. "[" .. abbr .. ":" .. txt .. "] "
                        end
                    end
                    ScriptExtender_Print(line)
                end
            end
        end
    end
end

ScriptExtender_Register("AutoPriestBuffs",
    "Automatically casts Priest buffs (Fort, Spirit, Inner Fire, Fear Ward) on party members.")
