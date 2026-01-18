-- Classes/Warlock/AutoWarlockBuffs.lua
-- Automatically handles Warlock buffs (Demon Skin/Armor, Unending Breath, Detect Invisibility).

if not AB_Track then AB_Track = {} end
if not AB_LastPrint then AB_LastPrint = 0 end

function AutoWarlockBuffs(m)
    local tm, th = GetTime(), (tonumber(m) or 5) * 60
    local S = { "Demon Armor", "Demon Skin", "Unending Breath", "Detect Greater Invisibility" }
    local T = { "RagingScream", "RagingScream", "Shadow_DemonBreath", "Shadow_DetectInvisibility" } -- Textures need verification
    local D = { 1800, 1800, 600, 600 }
    local W = { 5, 5, 1, 1 }
    local U = { "player" } -- Warlocks mostly buff self, maybe Breath for others

    -- 1. Check Spell Availability
    local av = { false, false, false, false }
    local i = 1
    while true do
        local n = GetSpellName(i, 1)
        if not n then break end
        for j = 1, 4 do if n == S[j] then av[j] = true end end
        -- Demon Armor overrides Demon Skin
        if n == "Demon Armor" then
            av[2] = false
            av[1] = true
        end
        i = i + 1
    end

    -- HELPER: Get Buff State
    local function GetSt(u, id)
        local lim = th
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
        end
        return 0, "?"
    end

    -- 2. Scan
    local best = { sc = -1 }

    for _, u in ipairs(U) do
        if UnitExists(u) then
            for id = 1, 4 do
                local ok = false
                if id == 1 or id == 2 then if av[id] then ok = true end end -- Armor/Skin
                -- Skip others for basic automation for now

                if ok then
                    local sc, txt = GetSt(u, id)
                    if sc > 0 and (sc + W[id]) > best.sc then
                        best = { sc = sc + W[id], u = u, sp = S[id], id = id }
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
        ScriptExtender_Print("[AB] Casting " .. best.sp .. " > " .. UnitName(best.u))
    end
end

ScriptExtender_Register("AutoWarlockBuffs", "Automatically casts Warlock self-buffs (Demon Armor/Skin).")
