-- Combat/AutCombat/CombatContext.lua
-- Centralized gathering of combat context (Environment, Group, Player, Target)
-- Optimized with Frame Cache to allow frequent calls (e.g. scanning loops) without overhead.

ScriptExtender_Register("CombatContext", "Centralized combat context gathering.")

-- Frame Cache stores data that is constant for the current frame (Player, Group)
local frameCache = {
    tm = 0,
    data = nil
}

local function UpdateFrameCache(tm, skipScan)
    local ctx = {}

    -- 1. GROUP & ENVIRONMENT UTILITIES (Heavy Loops)
    -- If skipScan is TRUE, we skip the mob distribution loop which changes targets.
    if not skipScan and GetMobDistribution then
        local count, dist = GetMobDistribution()
        if not dist then dist = {} end

        ctx.mobCount = count or 0
        ctx.mobDistribution = dist
        ctx.attackersOnPlayer = dist["player"] or 0
        ctx.attackersOnPet = dist["pet"] or 0

        ctx.attackersOnParty = 0
        for k, v in pairs(dist) do
            if string.sub(k, 1, 5) == "party" then
                ctx.attackersOnParty = ctx.attackersOnParty + v
            end
        end
    else
        ctx.mobCount = 0
        ctx.mobDistribution = {}
        ctx.attackersOnPlayer = 0
        -- Do not cache skipped data as valid frame data if it's incomplete?
        -- Actually, we should probably mark cache as dirty or partial.
        -- Simpler: Just return dummy values for now.
    end

    -- Party Health Velocity
    if GetPartyHealthStats then
        ctx.partyHealth = GetPartyHealthStats() or {}
    else
        ctx.partyHealth = {}
    end

    -- Party Range
    if GetPartyRangeStats then
        ctx.partyRange = GetPartyRangeStats() or {}
        ctx.alliesInRange = 0
        for k, v in pairs(ctx.partyRange) do
            if v and k ~= "player" then ctx.alliesInRange = ctx.alliesInRange + 1 end
        end
    else
        ctx.partyRange = {}
        ctx.alliesInRange = 0
    end

    -- 2. PLAYER STATUS (Constant for Frame)
    ctx.player = "player"
    ctx.playerHP = UnitHealth("player")
    ctx.playerMaxHP = UnitHealthMax("player")
    ctx.playerHPPct = (ctx.playerHP / ctx.playerMaxHP) * 100
    ctx.playerMana = UnitMana("player")
    ctx.playerMaxMana = UnitManaMax("player")
    ctx.playerManaPct = 0
    if ctx.playerMaxMana > 0 then
        ctx.playerManaPct = (ctx.playerMana / ctx.playerMaxMana) * 100
    end
    ctx.inCombat = UnitAffectingCombat("player")
    ctx.inGroup = (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0)

    return ctx
end

-- NEW: Fetch Global Data Only (Optimized)
function ScriptExtender_GetGlobalContext(skipScan)
    local tm = GetTime()
    local globalData = nil

    if frameCache.tm == tm and frameCache.data then
        -- Cache hit
        globalData = frameCache.data
    else
        -- Cache miss. Generate data.
        if skipScan then
            -- Generate but DO NOT save to frameCache (partial data)
            globalData = UpdateFrameCache(tm, true)
        else
            -- Generate and SAVE full data
            frameCache.data = UpdateFrameCache(tm, false)
            frameCache.tm = tm
            globalData = frameCache.data
        end
    end
    return globalData
end

-- NEW: Enrich Context with Unit Data (Zero-Copy using Metatable)
function ScriptExtender_EnrichContext(globalCtx, unit, skipScan)
    local ctx = {}
    if globalCtx then
        setmetatable(ctx, { __index = globalCtx })
    end

    -- 3. TARGET STATUS (Always Fresh for the specific unit)
    ctx.target = unit
    if UnitExists(unit) then
        ctx.targetHP = UnitHealth(unit)
        ctx.targetMaxHP = UnitHealthMax(unit)
        ctx.targetHPPct = 100
        if ctx.targetMaxHP > 0 then
            ctx.targetHPPct = (ctx.targetHP / ctx.targetMaxHP) * 100
        end
        ctx.isDead = UnitIsDead(unit)
        ctx.isFriend = UnitIsFriend("player", unit)
        ctx.classification = UnitClassification(unit)
        ctx.isElite = (ctx.classification == "elite")
        ctx.isBoss = (ctx.classification == "worldboss")

        -- Range Buckets
        -- 3 = ~10y (Duel)
        -- 4 = ~28y (Trade/Follow)
        ctx.range = 100 -- Far
        if CheckInteractDistance(unit, 3) then
            ctx.range = 10
        elseif CheckInteractDistance(unit, 4) then
            ctx.range = 28
        end

        -- Refine Range using Action Bar checks (Only works for "target")
        -- OPTIMIZATION: Skip expensive checks check if requested
        if unit == "target" and not skipScan then
            -- 1. Check Wand/Gun (Generic)
            if ScriptExtender_IsSpellInRange("Shoot") then
                if ctx.range > 30 then ctx.range = 30 end
            end
            if ScriptExtender_IsSpellInRange("Auto Shot") then
                if ctx.range > 35 then ctx.range = 35 end
            end

            -- 2. Check Class Specific Long-Range Spells
            local _, class = UnitClass("player")
            local rangeSpell = nil
            if class == "WARLOCK" then
                rangeSpell = "Shadow Bolt"
            elseif class == "MAGE" then
                rangeSpell = "Fireball"
            elseif class == "PRIEST" then
                rangeSpell = "Smite"
            elseif class == "SHAMAN" then
                rangeSpell = "Lightning Bolt"
            elseif class == "DRUID" then
                rangeSpell = "Wrath"
            elseif class == "HUNTER" then
                rangeSpell = "Serpent Sting"
            end

            if rangeSpell and ScriptExtender_IsSpellInRange(rangeSpell) then
                if ctx.range > 36 then ctx.range = 36 end
            end
        end


        -- Pseudo ID for stable identification
        if ScriptExtender_GetPseudoID then
            ctx.pseudoID = ScriptExtender_GetPseudoID(unit)
        else
            ctx.pseudoID = UnitName(unit) -- Fallback
        end


        -- Debuff Tracking (From Tracker Module)
        ctx.trackedDebuffs = {}
        if ScriptExtender_IsDebuffTracked then
            -- Pre-fetch common Warlock debuffs or expose a checker?
            -- It's better to expose a helper on the context or just allow the analyzer to check.
            -- But the user asked for context to have it.
            -- Let's populate a table of active tracked debuffs for this unit.
            -- Using a known list for now to populate 'ctx.trackedDebuffs' map.
            local potentialDebuffs = {
                "Curse of Agony", "Corruption", "Immolate", "Siphon Life",
                "Curse of the Elements", "Curse of Shadow", "Curse of Recklessness",
                "Curse of Tongues", "Curse of Weakness", "Fear", "Howl of Terror",
                "Banish", "Dark Harvest"
            }
            -- Use PseudoID for stable tracking
            local pid = ctx.pseudoID
            for _, spell in ipairs(potentialDebuffs) do
                if pid and ScriptExtender_IsDebuffTracked(pid, spell) then
                    ctx.trackedDebuffs[spell] = true
                end
            end
        end
    end

    ctx.tm = GetTime()
    return ctx
end

-- Compatibility Wrapper
function ScriptExtender_GetCombatContext(unit, skipScan)
    local g = ScriptExtender_GetGlobalContext(skipScan)
    return ScriptExtender_EnrichContext(g, unit, skipScan)
end
