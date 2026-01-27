-- Classes/Warlock/WarlockAnalyze.lua

if not WD_Track then WD_Track = {} end
if not WD_MarkSafe then WD_MarkSafe = {} end

-- Simple Helper to check if we know a spell
local function HasSpell(name)
    if ScriptExtender_HasTalent and ScriptExtender_HasTalent(name) then return true end
    return ScriptExtender_IsSpellLearned(name)
end


function ScriptExtender_Warlock_UpdateTracker(s, n, tm)
    if ScriptExtender_TrackDebuff then
        ScriptExtender_TrackDebuff(n, s, tm)
    end
end

function ScriptExtender_Warlock_Analyze(params)
    local u = params.unit
    local allowManualPull = params.allowManualPull
    local ctx = params.context

    local pl = "player"
    -- Use Context for validation if available (fallback to raw if nil)
    if not ctx then ctx = ScriptExtender_GetCombatContext(u) end

    if not ctx.targetHP then
        return nil, nil, -1000
    end

    if ctx.isDead or ctx.isFriend then
        return nil, nil, -1000
    end

    -- Combat Status Enforcer (Unless Manual Target)
    if not allowManualPull and not UnitAffectingCombat(u) and u ~= "target" then
        return nil, nil, -1000
    end

    -- Range Check Use Context
    if not allowManualPull and ctx.range > 36 then
        return nil, nil, -1000
    end

    -- Channel Protection
    local c = UnitChannelInfo("player")
    if c then
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

    -- Debuff Helper
    local function HasDebuff(spell)
        -- Check Tracker via Context (Preferred)
        if ctx.trackedDebuffs and ctx.trackedDebuffs[spell] then return true end

        -- Fallback to Global Tracker (Safety)
        if ScriptExtender_IsDebuffTracked and ctx.pseudoID then
            if ScriptExtender_IsDebuffTracked(ctx.pseudoID, spell) then return true end
        end

        -- Fallback to visible texture scanning (if implemented via mapping)
        if spell == "Curse of Agony" and ScriptExtender_HasDebuff(u, "CurseOfSargeras") then return true end
        if spell == "Corruption" and ScriptExtender_HasDebuff(u, "Abomination") then return true end
        if spell == "Immolate" and ScriptExtender_HasDebuff(u, "Immolation") then return true end

        return false
    end

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

    -- 2. DRAIN SOUL (Execute / Heavy Damage Filler)
    table.insert(candidates, {
        name = "Drain Soul",
        type = "kill",
        base = 40, -- Filler Priority (Beats Shoot=20, Shadow Bolt=35)
        cond = function()
            -- Execute Range Boost
            if hpPct <= 20 then return 90 end -- Return specific score for execute

            -- As filler
            if myMana < 10 then return false end -- Save mana if critically low
            return HasSpell("Drain Soul")
        end,
        scoreMod = function(s)
            if s == 90 then return s end -- Preserve execute score
            return s
        end
    })

    -- 3. DARK HARVEST (Burst - Requires DoTs)
    table.insert(candidates, {
        name = "Dark Harvest",
        type = "damage",
        base = 80,
        cond = function()
            -- Use on healthy mobs (Time to tick)
            if isLowHP then return false end

            -- REQUIRE DOTS: Do not cast unless we have at least one DoT ticking.
            local dots = 0
            if HasDebuff("Curse of Agony") then dots = dots + 1 end
            if HasDebuff("Corruption") then dots = dots + 1 end
            if HasDebuff("Immolate") then dots = dots + 1 end

            if dots == 0 then return false end

            return HasSpell("Dark Harvest") and ScriptExtender_IsSpellReady("Dark Harvest")
        end
    })

    -- 4. CURSE OF AGONY (DoT)
    table.insert(candidates, {
        name = "Curse of Agony",
        type = "dot",
        base = 70,
        cond = function()
            if isLowHP then return false end
            -- Check for Agony (Sargeras) OR Elements (ChillTouch/Malediction)
            if HasDebuff("Curse of Agony") then return false end
            if ScriptExtender_HasDebuff(u, "ChillTouch") then return false end -- Detection for Elements??
            -- Also check Name if texture fails
            if ScriptExtender_HasDebuff(u, "Curse of the Elements") then return false end

            if HasSpell("Malediction") and isBoss then return false end
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
            if ScriptExtender_HasDebuff(u, "ChillTouch") or ScriptExtender_HasDebuff(u, "Curse of the Elements") then return false end
            return true
        end
    })

    -- 5. IMMOLATE (DoT/Cast)
    table.insert(candidates, {
        name = "Immolate",
        type = "dot",
        base = 65, -- Lower than Agony (70), Higher than Corruption (60)
        cond = function()
            if isLowHP then return false end
            if HasDebuff("Immolate") then return false end

            -- If we have Emberstorm or just good mana, use it
            return HasSpell("Immolate")
        end
    })

    -- 6. CORRUPTION (DoT)
    table.insert(candidates, {
        name = "Corruption",
        type = "dot",
        base = 60,
        cond = function()
            if isLowHP then return false end
            if HasDebuff("Corruption") then return false end
            return HasSpell("Corruption")
        end
    })

    -- 7. SHADOW BOLT (Nightfall / Filler)
    table.insert(candidates, {
        name = "Shadow Bolt",
        type = "fill",
        base = 35, -- Beats Shoot(20)
        cond = function()
            -- Nightfall Proc (Optimization)
            if ScriptExtender_HasBuff("player", "Spell_Shadow_Twilight") then return 100 end

            -- Standard Cast
            if myMana > 15 and HasSpell("Shadow Bolt") then return true end
            return false
        end,
        scoreMod = function(s)
            return s
        end
    })

    -- 8. SHOOT (Filler)
    table.insert(candidates, {
        name = "Shoot",
        type = "fill",
        base = 20,
        cond = function()
            return HasSpell("Shoot") -- Check if wand equipped/learned
        end
    })

    -- 9. LIFE TAP (Resource)
    table.insert(candidates, {
        name = "Life Tap",
        type = "self",
        base = 0, -- Calc dynamic
        cond = function()
            -- Only tap if missing significant mana (avoid topping off)
            if myHP < 50 or myMana > 60 then return false end
            return true
        end,
        scoreMod = function(s) return 100 - myMana end -- Score = Deficit
    })

    -- === SELECTION LOOP ===
    local bestName, bestType, bestScore = nil, nil, -1

    for _, c in ipairs(candidates) do
        local condRes = c.cond()
        if condRes then
            local s = (type(condRes) == "number") and condRes or c.base
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
