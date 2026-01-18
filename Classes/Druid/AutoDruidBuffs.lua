-- Classes/Druid/AutoDruidBuffs.lua
-- Automatically handles Druid buffs (Mark of the Wild, Thorns, Omen of Clarity).

if not AB_Track then AB_Track = {} end
if not AB_LastPrint then AB_LastPrint = 0 end

function AutoDruidBuffs(m)
    local tm, th = GetTime(), (m or 5) * 60
    local S = { "Mark of the Wild", "Thorns", "Omen of Clarity" }
    local T = { "Regeneration", "Thorns", "CrystalBall" } -- Textures: Spell_Nature_Regeneration, Spell_Nature_Thorns
    local D = { 1800, 600, 600 }
    local W = { 5, 3, 2 }                               -- Priorities: Mark > Thorns > Omen
    local U = { "player", "target", "party1", "party2", "party3", "party4" }

    -- 1. Check Spell Availability
    local av = { false, false, false }
    local i = 1
    while true do
        local n = GetSpellName(i, 1)
        if not n then break end
        for j = 1, 3 do if n == S[j] then av[j] = true end end
        i = i + 1
    end

    -- HELPER: Get Buff State
    local function GetSt(u, id)
        local lim = th
        -- PLAYER
        if u == "player" then
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

    -- 2. Scan Loop
    local best = { sc = -1 }

    for _, u in ipairs(U) do
        if UnitExists(u) and not UnitIsDeadOrGhost(u) and UnitIsConnected(u) and UnitIsFriend("player", u) then
            local safe = UnitInParty(u) or u == "player"
            if safe then
                for id = 1, 3 do
                    local ok = false

                    if id == 1 then
                        -- Mark of the Wild: Cast on everyone
                        if av[1] then ok = true end
                    elseif id == 2 then
                        -- Thorns: Cast on self, Warriors, Paladins, Rogues (Melee)
                        -- Assuming 'UnitClass' returns uppercase LOCALE independent string in Vanilla is tricky,
                        -- usually returns localized. We'll try standard check or just apply to tanks if we had a tank detector.
                        -- For now, simplified: Apply to Warriors (1), Paladins (2), Rogues (4), Druids (11).
                        if av[2] then
                            local _, cls = UnitClass(u) -- Returns localized name, class filename (e.g. "WARRIOR")
                            if cls == "WARRIOR" or cls == "PALADIN" or cls == "ROGUE" or cls == "DRUID" then
                                ok = true
                            end
                        end
                    elseif id == 3 then
                        -- Omen of Clarity: Self only
                        if u == "player" and av[3] then ok = true end
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

    -- 3. Execute
    if best.u then
        TargetUnit(best.u)
        CastSpellByName(best.sp)
        if best.u ~= "target" then TargetLastTarget() end
        AB_Track[UnitName(best.u) .. T[best.id]] = tm
        ScriptExtender_Print("[AB] Casting " .. best.sp .. " > " .. UnitName(best.u))
    else
        if (tm - AB_LastPrint) > 10 then
            AB_LastPrint = tm
            -- ScriptExtender_Print("--- AutoBuffs Status (Druid) ---")
        end
    end
end

ScriptExtender_Register("AutoDruidBuffs", "Automatically casts Druid buffs (Mark of the Wild, Thorns, Omen).")
