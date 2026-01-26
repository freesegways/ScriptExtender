-- Combat/AutCombat/CombatContext.lua
-- Centralized gathering of combat context (Environment, Group, Player, Target)
-- Used by Universal Analyzers to make decisions without recalculating data.

ScriptExtender_Register("CombatContext", "Centralized combat context gathering.")

local lastMobDistTime = 0
local lastMobDistCount = 0
local lastMobDistData = {}
local contextCache = { tm = 0, unit = nil, unitName = nil, data = nil }

function ScriptExtender_GetCombatContext(unit, forceRefresh)
    local tm = GetTime()
    local unitName = UnitName(unit)

    -- Return cached frame data if available for same unit
    if not forceRefresh and contextCache.tm == tm and contextCache.unit == unit and contextCache.unitName == unitName and contextCache.data then
        return contextCache.data
    end

    local ctx = {}
    ctx.tm = tm
    ctx.player = "player"
    ctx.target = unit
    ctx.targetName = unitName

    -- 1. GROUP & ENVIRONMENT UTILITIES
    -- Mob Distribution (Threat/Density) - Frame Caching logic
    if GetMobDistribution then
        if lastMobDistTime ~= tm then
            lastMobDistCount, lastMobDistData = GetMobDistribution()
            lastMobDistTime = tm
        end
        ctx.mobCount = lastMobDistCount
        ctx.mobDistribution = lastMobDistData
        ctx.attackersOnPlayer = lastMobDistData["player"] or 0
        ctx.attackersOnPet = lastMobDistData["pet"] or 0
        -- Simple Healer Aggro heuristic (assuming party numbers match roster roles, vaguely)
        -- TODO: Real role detection
        ctx.attackersOnParty = 0
        for k, v in pairs(lastMobDistData) do
            if string.sub(k, 1, 5) == "party" then
                ctx.attackersOnParty = ctx.attackersOnParty + v
            end
        end
    else
        ctx.mobCount = 0
        ctx.mobDistribution = {}
        ctx.attackersOnPlayer = 0
    end

    -- 2. TARGET STATS (critical for analyzers)
    ctx.targetHP = UnitHealth(unit) or 0
    ctx.targetMaxHP = UnitHealthMax(unit) or 1
    ctx.targetHPPct = (ctx.targetHP / ctx.targetMaxHP) * 100
    ctx.targetMana = UnitMana(unit) or 0
    local targetManaMax = UnitManaMax(unit) or 1
    ctx.targetManaPct = (ctx.targetMana / targetManaMax) * 100
    ctx.inCombat = UnitAffectingCombat("player")
    ctx.isDead = UnitIsDead and UnitIsDead(unit) or false
    ctx.isFriend = UnitIsFriend("player", unit)
    ctx.isBoss = UnitClassification(unit) == "worldboss" or UnitClassification(unit) == "rareelite" or
        UnitClassification(unit) == "elite"
    ctx.range = CheckInteractDistance(unit, 4) and 10 or (CheckInteractDistance(unit, 3) and 28 or 100)

    -- Player stats
    ctx.playerHP = UnitHealth("player") or 0
    ctx.playerMaxHP = UnitHealthMax("player") or 1
    ctx.playerHPPct = (ctx.playerHP / ctx.playerMaxHP) * 100
    ctx.playerMana = UnitMana("player") or 0
    local playerManaMax = UnitManaMax("player") or 1
    ctx.playerManaPct = (ctx.playerMana / playerManaMax) * 100

    -- Party Health Velocity
    if GetPartyHealthStats then
        ctx.partyHealth = GetPartyHealthStats()
    else
        ctx.partyHealth = {}
    end

    -- Party Range
    if GetPartyRangeStats then
        ctx.partyRange = GetPartyRangeStats()
        ctx.alliesInRange = 0
        for k, v in pairs(ctx.partyRange) do
            if v and k ~= "player" then ctx.alliesInRange = ctx.alliesInRange + 1 end
        end
    else
        ctx.partyRange = {}
        ctx.alliesInRange = 0
    end

    -- 2. PLAYER STATUS
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

    -- 3. TARGET STATUS
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
        -- 4 = ~28y (Trade/Follow) - Note: Trade is 11y, Follow is 28y? CheckInteractDistance 4 is usually ~28y.
        ctx.range = 100 -- Far
        if CheckInteractDistance(unit, 3) then
            ctx.range = 10
        elseif CheckInteractDistance(unit, 4) then
            ctx.range = 28
        end
    end

    ctx.targetName = unitName

    -- Update Cache
    contextCache.tm = tm
    contextCache.unit = unit
    contextCache.unitName = unitName
    contextCache.data = ctx

    return ctx
end
