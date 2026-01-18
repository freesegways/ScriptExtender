-- Classes/Paladin/AutoPaladinBuffs.lua
-- Automatically handles Paladin buffs (Blessings).

if not AB_Track then AB_Track = {} end
if not AB_LastPrint then AB_LastPrint = 0 end

function AutoPaladinBuffs(m)
    local tm, th = GetTime(), (m or 5) * 60
    local S = { "Blessing of Kings", "Blessing of Wisdom", "Blessing of Might" }
    local T = { "Magic_MageArmor", "Holy_SealOfWisdom", "Holy_FistOfJustice" } -- Textures need strict verification
    -- Kings: Spell_Magic_MageArmor? Or Spell_Magic_GreaterBlessingofKings
    -- Wisdom: Spell_Holy_SealOfWisdom
    -- Might: Spell_Holy_FistOfJustice

    local D = { 300, 300, 300 } -- 5 Minutes standard
    local W = { 10, 5, 5 }
    local U = { "player", "target", "party1", "party2", "party3", "party4" }

    local av = { false, false, false }
    local i = 1
    while true do
        local n = GetSpellName(i, 1)
        if not n then break end
        for j = 1, 3 do if n == S[j] then av[j] = true end end
        i = i + 1
    end

    -- Heuristic: Which buff for whom?
    local function GetBestBuffFor(u)
        -- 1. Kings (If avail) is usually best for everyone
        if av[1] then return 1 end

        -- 2. Class Based
        -- UnitPowerType: 0=Mana, 1=Rage, 3=Energy
        local pType = UnitPowerType(u)
        local _, cls = UnitClass(u)

        if pType == 0 then                                      -- Mana users
            if cls == "HUNTER" then return av[3] and 3 or 2 end -- Hunters might prefer Might(3) over Wisdom(2)
            return av[2] and 2 or 3
        else                                                    -- Rage/Energy
            return av[3] and 3 or 1                             -- Might, else Kings (if 1 was somehow skipped logic)
        end
        return 3                                                -- Default Might
    end

    local function GetSt(u, id)
        local lim = th
        if u == "player" then
            local j = 0
            while GetPlayerBuff(j, "HELPFUL") >= 0 do
                local b = GetPlayerBuff(j, "HELPFUL")
                local tx = GetPlayerBuffTexture(b)
                -- Crude texture match, might need refining or name checking via tooltip (expensive)
                if tx and string.find(tx, T[id]) then
                    -- Warning: Textures can be ambiguous.
                    return 0, "OK"
                end
                j = j + 1
            end
            return 100, "Miss"
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
            return 0, "OK"
        end
    end

    -- Scan
    local best = { sc = -1 }
    for _, u in ipairs(U) do
        if UnitExists(u) and not UnitIsDeadOrGhost(u) and UnitIsConnected(u) and UnitIsFriend("player", u) then
            local safe = UnitInParty(u) or u == "player"
            if safe then
                local id = GetBestBuffFor(u)
                if id and av[id] then
                    local inRange = (u == "player" or CheckInteractDistance(u, 4))
                    if inRange then
                        local sc, txt = GetSt(u, id)
                        -- Priority: Missing > Expiring
                        if sc > 0 and (sc + W[id]) > best.sc then
                            best = { sc = sc + W[id], u = u, sp = S[id], id = id }
                        end
                    end
                end
            end
        end
    end

    -- Execute
    if best.u then
        TargetUnit(best.u)
        CastSpellByName(best.sp)
        if best.u ~= "target" then TargetLastTarget() end
        AB_Track[UnitName(best.u) .. T[best.id]] = tm
        ScriptExtender_Print("[AB] Casting " .. best.sp .. " > " .. UnitName(best.u))
    end
end

ScriptExtender_Register("AutoPaladinBuffs", "Automatically casts Blessings (Kings, Wisdom, Might) based on class.")
