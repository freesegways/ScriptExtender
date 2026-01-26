-- Classes/Warlock/WarlockAnalyze.lua

if not WD_Track then WD_Track = {} end
if not WD_MarkSafe then WD_MarkSafe = {} end

-- Simple Helper to check if we know a spell
local function HasSpell(name)
    if ScriptExtender_HasTalent and ScriptExtender_HasTalent(name) then return true end
    return ScriptExtender_IsSpellLearned(name)
end

function ScriptExtender_Warlock_Analyze(u, forceOOC, ctx)
    local pl = "player"
    -- Use Context for validation if available (fallback to raw if nil)
    if not ctx then ctx = ScriptExtender_GetCombatContext(u) end

    if not ctx.targetHP then return nil, nil, -1000 end -- Invalid unit

    if ctx.isDead or ctx.isFriend then return nil, nil, -1000 end

    -- Combat Status Enforcer (Unless Manual Target)
    -- Context doesn't strictly track if *this specific unit* is in combat in the generic block,
    -- but usually we check UnitAffectingCombat(u).
    -- Let's stick to raw check for safety or ensure Context has it.
    -- Context has `inCombat` (player).
    -- Context does NOT have 'targetInCombat' explicitly in my previous write, let's check.
    -- I wrote: `ctx.inCombat = UnitAffectingCombat("player")`.
    -- I did NOT write target combat status. I should fix that or keep raw check.
    -- keeping raw check for now for safety.
    if not forceOOC and not UnitAffectingCombat(u) and u ~= "target" then return nil, nil, -1000 end

    -- Range Check Use Context
    -- Warlock wants ~30-36y.
    -- Context has buckets for 10, 28, and defaults to 100.
    -- If we are beyond 28 but not '100', we'll assume we are in the 30-35y sweet spot.
    if ctx.range > 35 then return nil, nil, -1000 end

    -- Channel Protection
    local c = UnitChannelInfo("player")
    if c == "Drain Soul" or c == "Rain of Fire" or c == "Hellfire" or c == "Dark Harvest" or c == "Drain Life" then
        return nil, nil, -1000
    end

    -- CC Safety: Do not break Polymorph, Sap, etc.
    -- (TODO: Centralize CC list)
    if ScriptExtender_HasDebuff(u, "Polymorph") or ScriptExtender_HasDebuff(u, "Sap") or ScriptExtender_HasDebuff(u, "Gouge") or ScriptExtender_HasDebuff(u, "Blind") or ScriptExtender_HasDebuff(u, "Hibernate") or ScriptExtender_HasDebuff(u, "Freezing Trap") or ScriptExtender_HasDebuff(u, "Wyvern Sting") or ScriptExtender_HasDebuff(u, "Seduction") or ScriptExtender_HasDebuff(u, "Shackle Undead") then
        return nil, nil, -1000
    end

    -- === STATE (From Context) ===
    local hp = ctx.targetHP
    local hpMax = ctx.targetMaxHP
    local hpPct = ctx.targetHPPct
    if hpMax == 100 then hp = hpPct * 40 end -- Fallback

    local myMana = ctx.playerManaPct
    local myHP = ctx.playerHPPct

    local isBoss = ctx.isBoss
    local isLowHP = (hpPct < 25)

    -- === CANDIDATE ACTIONS ===
    local candidates = {}

    -- 1. SHADOWBURN (Execute)
    table.insert(candidates, {
        name = "Shadowburn",
        type = "kill",
        base = 95,
        cond = function()
            return isLowHP and HasSpell("Shadowburn") and ScriptExtender_IsSpellReady("Shadowburn")
        end
    })

    -- 2. DRAIN SOUL (Execute / Shard)
    table.insert(candidates, {
        name = "Drain Soul",
        type = "kill",
        base = 90,
        cond = function()
            -- Only Execute Range.
            if hpPct > 20 then return false end
            return HasSpell("Drain Soul")
        end
    })

    -- 3. DARK HARVEST (Burst)
    table.insert(candidates, {
        name = "Dark Harvest",
        type = "damage",
        base = 80,
        cond = function()
            -- Use on healthy mobs (Time to tick)
            if isLowHP then return false end
            return HasSpell("Dark Harvest") and ScriptExtender_IsSpellReady("Dark Harvest")
        end
    })

    -- 4. CURSE OF AGONY (DoT)
    table.insert(candidates, {
        name = "Curse of Agony",
        type = "dot",
        base = 70,
        cond = function()
            if isLowHP then return false end                            -- Don't waste on dying
            if ScriptExtender_HasDebuff(u, "CurseOfSargeras") then return false end
            if HasSpell("Malediction") and isBoss then return false end -- Prefer Elements/Shadow on Boss
            return HasSpell("Curse of Agony")
        end
    })

    -- 4b. MALEDICTION (Elements/Shadow)
    table.insert(candidates, {
        name = "Curse of the Elements",
        type = "dot",
        base = 75,
        cond = function()
            if not HasSpell("Malediction") then return false end
            if ScriptExtender_HasDebuff(u, "ChillTouch") then return false end
            return true
        end
    })

    -- 5. CORRUPTION (DoT)
    table.insert(candidates, {
        name = "Corruption",
        type = "dot",
        base = 60,
        cond = function()
            if isLowHP then return false end
            if ScriptExtender_HasDebuff(u, "Abomination") then return false end
            return HasSpell("Corruption")
        end
    })

    -- 6. SHADOW BOLT (Nightfall Only)
    table.insert(candidates, {
        name = "Shadow Bolt",
        type = "fill",
        base = 100, -- High Priority if proc
        cond = function()
            if ScriptExtender_HasBuff("player", "Spell_Shadow_Twilight") then return true end
            return false -- Only on proc
        end
    })

    -- 7. SHOOT (Filler)
    table.insert(candidates, {
        name = "Shoot",
        type = "fill",
        base = 20,
        cond = function()
            return true -- Always valid
        end
    })

    -- 8. LIFE TAP (Resource)
    table.insert(candidates, {
        name = "Life Tap",
        type = "self",
        base = 0, -- Calc dynamic
        cond = function()
            if myHP < 50 or myMana > 80 then return false end
            return true
        end,
        scoreMod = function(s) return 100 - myMana end -- Score = Deficit
    })

    -- === SELECTION LOOP ===
    local bestName, bestType, bestScore = nil, nil, -1

    for _, c in ipairs(candidates) do
        if c.cond() then
            local s = c.base
            if c.scoreMod then s = c.scoreMod(s) end

            if s > bestScore then
                bestScore = s
                bestName = c.name
                bestType = c.type
            end
        end
    end

    return bestName, bestType, bestScore
end

function ScriptExtender_Warlock_UpdateTracker(s, n, tm)
    -- Stub
end
