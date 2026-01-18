-- Classes/Warlock/WarlockAnalyze.lua
-- Analysis logic for Warlock combat automation.

if not WD_Track then WD_Track = {} end
if not WD_MarkSafe then WD_MarkSafe = {} end

local DoTs = { "Curse of Agony", "Corruption", "Immolate" }
local Tex = { "CurseOfSargeras", "Abomination", "Immolation" }
local Dur = { 24, 18, 15 }

-- ANALYZER
function ScriptExtender_Warlock_Analyze(u, forceOOC, tm)
    local pl = "player"
    if not UnitExists(u) or UnitIsDead(u) or UnitIsFriend(pl, u) then return nil, nil, -1000 end
    if not forceOOC and not UnitAffectingCombat(u) then return nil, nil, -1000 end

    local mark = GetRaidTargetIndex(u)
    local SafeTime = 5

    -- === IMMUNITY CHECK (BUFFS) ===
    for i = 1, 16 do
        local b = UnitBuff(u, i)
        if not b then break end
        for _, t in ipairs(ScriptExtender_ImmuneTextures) do
            if string.find(b, t) then return nil, nil, -1000 end
        end
    end

    -- === CC SAFETY CHECK (MARK BASED) ===
    local ccFound = false
    for i = 1, 16 do
        local d = UnitDebuff(u, i)
        if not d then break end
        for _, t in ipairs(ScriptExtender_CCTextures) do
            if string.find(d, t) then
                ccFound = true
                break
            end
        end
    end

    if ccFound then
        if mark then WD_MarkSafe[mark] = tm end
        return nil, nil, -1000
    end

    if mark and WD_MarkSafe[mark] and (tm - WD_MarkSafe[mark]) < SafeTime then
        return nil, nil, -1000
    end

    -- === LOGIC START ===
    local pHp = math.floor((UnitHealth(pl) / UnitHealthMax(pl)) * 100)
    local pMana = math.floor((UnitMana(pl) / UnitManaMax(pl)) * 100)

    -- 0. SELF MAINTENANCE (Life Tap)
    if pMana < 35 and pHp > 75 then
        return "Life Tap", "self", 110
    end

    local hp = math.floor((UnitHealth(u) / UnitHealthMax(u)) * 100)
    local prio = ScriptExtender_GetTargetPriority(u)
    local n = UnitName(u)

    -- 1. KILL / BURST / DRAIN
    if pHp < 50 and hp > 10 then
        return "Drain Life", "kill", (prio >= 2 and 95 or 35)
    end

    if hp < 33 then
        -- Shadowburn (HP < 25%, Shards > 0, Not on CD)
        if hp <= 25 then
            local shards = 0
            for b = 0, 4 do
                for s = 1, GetContainerNumSlots(b) do
                    local l = GetContainerItemLink(b, s)
                    if l and string.find(l, "item:6265") then shards = shards + 1 end
                end
            end
            if shards > 0 and (not WD_Track["SB"] or (tm - WD_Track["SB"]) > 15) then
                WD_Track["SB"] = tm
                return "Shadowburn", "kill", (prio >= 2 and 105 or 45)
            end
        end
        return "Drain Soul", "kill", (prio >= 2 and 90 or 30)
    end

    if pMana < 35 and UnitPowerType(u) == 0 and UnitMana(u) > 0 then
        return "Drain Mana", "kill", (prio >= 2 and 85 or 25)
    end

    -- 2. DOTS
    for x, s in ipairs(DoTs) do
        local k = n .. Tex[x]
        local tmr = (WD_Track[k] and (tm - WD_Track[k]) < (Dur[x] - 2))

        -- Check Visual Debuff on Unit (to fix Identity issues)
        local hasDot = false
        for i = 1, 16 do
            local d = UnitDebuff(u, i)
            if not d then break end
            if string.find(d, Tex[x]) then
                hasDot = true
                break
            end
        end

        if not tmr or (tmr and not hasDot) then
            local dotScore = (prio >= 2 and 80 or 20)
            return s, "dot", dotScore
        end
    end

    -- 3. FILLER
    local action = (pHp < 60 and "Drain Life" or "Drain Soul")
    local fillScore = (prio >= 2 and 60 or 10)
    return action, "fill", fillScore
end

function ScriptExtender_Warlock_UpdateTracker(s, n, tm)
    for x, dS in ipairs(DoTs) do
        if s == dS then
            WD_Track[n .. Tex[x]] = tm
            return
        end
    end
end
