-- Combat/AutoCombat2/Core/Scanner.lua
-- Scans the world state by tab-cycling nearby enemies.

if ScriptExtender_Scanner then return end

ScriptExtender_Scanner = {
    WorldState = {
        context = {},
        mobs = {},           -- Key: PseudoID, Value: MobData
        aggregations = {
            classCounts = {} -- Map of [CLASS] = count
        },
        ledger = {}          -- Persistent: [PseudoID] = { [SpellName] = ExpiryTime }
    }
}

-- Private Helper: Calculate Buckets
local function CalculateBuckets(val, max)
    if not val or not max or max == 0 then return 0, 0 end
    local pct = (val / max) * 100
    local bucket = math.floor(pct / 10)
    return bucket, pct
end

-- Private Helper: Determine Range Bucket
local function GetRangeBucket(unit)
    if CheckInteractDistance(unit, 3) then return 0 end
    if CheckInteractDistance(unit, 2) then return 1 end
    if CheckInteractDistance(unit, 4) then return 2 end
    return 3
end

-- Private Helper: Scan Debuffs (Raw Gathering)
local function ScanDebuffs(unit)
    local data = {
        raw = {},
        hash = 0,
        hasCC = false,
        hasSheep = false,
        visualCounts = {} -- Key: SpellName, Value: Count
    }

    local _, myClass = UnitClass("player")
    local myClassKey = string.upper(myClass or "")
    local classSpells = ScriptExtender_ClassDebuffs and ScriptExtender_ClassDebuffs[myClassKey]

    local hashStr = ""
    for i = 1, 40 do
        local texture = UnitDebuff(unit, i)
        if not texture then break end

        table.insert(data.raw, texture)
        hashStr = hashStr .. string.sub(texture, -5)

        -- 1. CC Checks
        for _, ccTex in ipairs(ScriptExtender_CCTextures or {}) do
            if string.find(texture, ccTex) then
                data.hasCC = true
                if string.find(texture, "Polymorph") then data.hasSheep = true end
                break
            end
        end

        -- 2. Visual Counts for Reconciliation
        if classSpells then
            for spellName, meta in pairs(classSpells) do
                if string.find(texture, meta.texture) then
                    data.visualCounts[spellName] = (data.visualCounts[spellName] or 0) + 1
                end
            end
        end
    end

    local h = 0
    for i = 1, string.len(hashStr) do
        h = h + string.byte(hashStr, i)
    end
    data.hash = h
    return data
end

-- Private Helper: Reconcile Debuffs (Ledger + Visuals + Multi-Class)
local function ReconcileDebuffs(mob, ws)
    local myDebuffs = {}
    local ledger = ws.ledger[mob.pseudoID] or {}
    local visualCounts = mob.debuffs.visualCounts
    local now = GetTime()

    local _, myClass = UnitClass("player")
    local classKey = string.upper(myClass or "")
    local classSpells = ScriptExtender_ClassDebuffs and ScriptExtender_ClassDebuffs[classKey]
    if not classSpells then return myDebuffs end

    for spellName, meta in pairs(classSpells) do
        local visualCount = visualCounts[spellName] or 0
        local tracked = false
        if ledger[spellName] and ledger[spellName] > now then
            tracked = true
        end

        if visualCount > 0 then
            -- reconciliation Logic (Point 2.2 in plan)
            if tracked then
                -- Visual Match + Tracker Match = Definitely Mine
                myDebuffs[spellName] = true
            else
                -- Visual Present but Tracker says no.
                if not meta.stackable then
                    -- If not stackable (Fear, Banish), we respect the visual anyway as "Mine" (Safety)
                    myDebuffs[spellName] = true
                else
                    -- Stackable (Corruption): Is there enough for everyone?
                    local totalSameClass = ws.aggregations.classCounts[classKey] or 1
                    if visualCount >= totalSameClass then
                        -- E.g. 2 Warlocks, 2 Dots. Assume 1 is mine even if tracker lost it.
                        myDebuffs[spellName] = true
                    else
                        -- E.g. 2 Warlocks, 1 Dot. Tracker says no. Assume the 1 dot is "Other's".
                    end
                end
            end
        else
            -- Visual MISSING but Tracker says yes? -> Desync.
            if tracked then
                ledger[spellName] = nil
            end
        end
    end

    return myDebuffs
end

-- Global Helper: Calculate TargetedBy for a specific unit token right now
function ScriptExtender_Scanner.GetLiveTargetedByCount(unit)
    if not UnitExists(unit) then return 0 end
    local uName = UnitName(unit)
    local uLvl = UnitLevel(unit)
    local uMax = UnitHealthMax(unit)

    local count = 0
    local friends = { "player", "party1", "party2", "party3", "party4" }
    for _, friend in ipairs(friends) do
        if UnitExists(friend) then
            local t = friend .. "target"
            if UnitExists(t) then
                if UnitName(t) == uName and UnitLevel(t) == uLvl and UnitHealthMax(t) == uMax then
                    count = count + 1
                end
            end
        end
    end
    return count
end

-- Global Helper: Generate PseudoID (Named Parameters)
-- Formula: name + maxHP + level + creatureType + classification + target + targetedByCount + raidIcon + isCasting + debuffHash + inCombat
function ScriptExtender_Scanner.GeneratePseudoID(params)
    local unit = params.unit
    if not UnitExists(unit) then return nil end

    local name = UnitName(unit)
    local maxHP = UnitHealthMax(unit)
    local level = UnitLevel(unit)
    local cType = UnitCreatureType(unit)
    local classif = UnitClassification(unit)
    local target = UnitName(unit .. "target") or "None"
    local raidIcon = GetRaidTargetIndex(unit) or 0
    local inCombat = UnitAffectingCombat(unit)

    local isCasting = false
    if UnitCastingInfo then
        if UnitCastingInfo(unit) then isCasting = true end
    end

    -- TargetedByCount: Use provided or calculate live
    local targetedBy = params.targetedByCount
    if not targetedBy then
        targetedBy = ScriptExtender_Scanner.GetLiveTargetedByCount(unit)
    end

    -- DebuffHash: Use provided or scan live
    local debuffHash = params.debuffHash
    if not debuffHash then
        local d = ScanDebuffs(unit)
        debuffHash = d.hash
    end

    local pseudoID = string.format(
        "%s_%d_%d_%s_%s_%s_%d_%d_%s_%d_%s",
        name or "Unknown",
        maxHP or 0,
        level or 0,
        cType or "Unknown",
        classif or "normal",
        target,
        targetedBy,
        raidIcon,
        tostring(isCasting),
        debuffHash,
        tostring(inCombat or false)
    )
    return pseudoID
end

-- Private Helper: Extract raw mob data from a unit token
local function GetRawMobData(unit)
    if not UnitExists(unit) or UnitIsDead(unit) or not UnitCanAttack("player", unit) then
        return nil
    end

    local hp = UnitHealth(unit)
    local maxHP = UnitHealthMax(unit)
    local hB, hP = CalculateBuckets(hp, maxHP)
    local energy = UnitMana(unit)
    local eB, _ = CalculateBuckets(energy, UnitManaMax(unit))

    local mob = {
        unit = unit,
        name = UnitName(unit),
        hp = hp,
        maxHP = maxHP,
        hpPct = hP,
        hpBucket = hB,
        energyBucket = eB,
        level = UnitLevel(unit),
        classification = UnitClassification(unit),
        creatureType = UnitCreatureType(unit),
        raidIcon = GetRaidTargetIndex(unit) or 0,
        rangeBucket = GetRangeBucket(unit),
        debuffs = ScanDebuffs(unit),
        inCombat = UnitAffectingCombat(unit),
        isCasting = nil,
        target = UnitName(unit .. "target"),
        targetedByCount = 0
    }

    if UnitCastingInfo then
        local sName = UnitCastingInfo(unit)
        if sName then mob.isCasting = sName end
    end

    return mob
end

function ScriptExtender_Scanner.Scan(targetIsWorld)
    local ws = ScriptExtender_Scanner.WorldState
    ws.mobs = {}

    -- 1. Scan Context
    local _, class = UnitClass("player")
    local shardCount = 0
    if class == "WARLOCK" then
        local found = 0
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local link = GetContainerItemLink(bag, slot)
                if link and string.find(link, "Soul Shard") then
                    local _, count = GetContainerItemInfo(bag, slot)
                    found = found + (count or 1)
                end
            end
        end
        shardCount = found
    end

    local buffs = {}
    for i = 1, 32 do
        local b = UnitBuff("player", i)
        if not b then break end
        buffs[b] = true
    end

    local groupSize = 1
    if GetNumRaidMembers() > 0 then
        groupSize = GetNumRaidMembers()
    elseif GetNumPartyMembers() > 0 then
        groupSize = GetNumPartyMembers() + 1
    end

    local petData = nil
    if UnitExists("pet") then
        petData = {
            family = UnitCreatureFamily("pet"),
            hpPct = (UnitHealth("pet") / UnitHealthMax("pet")) * 100,
            manaPct = (UnitMana("pet") / (UnitManaMax("pet") or 1)) * 100,
            target = nil, -- UnitTarget("pet") doesn't exist in 1.12
            inCombat = UnitAffectingCombat("pet")
        }
    end

    ws.context = {
        playerHP = UnitHealth("player"),
        playerMaxHP = UnitHealthMax("player"),
        playerLevel = UnitLevel("player"),
        playerMana = UnitMana("player"),
        playerClass = class,
        playerShards = shardCount,
        playerBuffs = buffs,
        pet = petData,
        groupSize = groupSize,
        inCombat = UnitAffectingCombat("player"),
        target = UnitName("target"),
        targetPseudoID = ScriptExtender_Scanner.GeneratePseudoID({ unit = "target" })
    }

    local mobAccumulator = {}

    -- 2. Discovery Strategy
    if UnitExists("target") and not UnitAffectingCombat("target") and UnitCanAttack("player", "target") then
        ws.context.pullMode = true
        local mob = GetRawMobData("target")
        if mob then
            local discoveryKey = mob.name .. "_" .. mob.level .. "_" .. mob.maxHP
            mobAccumulator[discoveryKey] = mob
            ScriptExtender_Log("Scanner: Pull Mode active. Focusing on " .. (mob.name or "Target"))
        end
    else
        local firstSeenKey = nil
        for i = 1, 26 do
            TargetNearestEnemy()
            local mob = GetRawMobData("target")
            if mob then
                local discoveryKey = mob.name .. "_" .. mob.level .. "_" .. mob.maxHP
                if firstSeenKey and discoveryKey == firstSeenKey then break end
                if not firstSeenKey then firstSeenKey = discoveryKey end

                -- Point 2.2: Global discovery (OOC is fine to scan)
                if not mobAccumulator[discoveryKey] then
                    mobAccumulator[discoveryKey] = mob
                end
            else
                break
            end
        end
    end

    -- 3. Party Targets & Group Awareness
    ws.aggregations = { mobCount = 0, attackersOnPlayer = 0, classCounts = {} }

    local friends = { "player", "party1", "party2", "party3", "party4" }
    for _, friend in ipairs(friends) do
        if UnitExists(friend) then
            -- Count Classes for Debuff reconciliation
            local _, class = UnitClass(friend)
            local classKey = string.upper(class or "")
            ws.aggregations.classCounts[classKey] = (ws.aggregations.classCounts[classKey] or 0) + 1

            -- Scan Party Targets
            if friend ~= "player" then
                local unit = friend .. "target"
                local mob = GetRawMobData(unit)
                if mob then
                    local dKey = mob.name .. "_" .. mob.level .. "_" .. mob.maxHP
                    if not mobAccumulator[dKey] then
                        mobAccumulator[dKey] = mob
                    end
                end
            end
        end
    end

    -- 4. Aggregate TargetedBy
    for _, friend in ipairs(friends) do
        if UnitExists(friend) then
            local t = friend .. "target"
            if UnitExists(t) then
                local dKey = UnitName(t) .. "_" .. UnitLevel(t) .. "_" .. UnitHealthMax(t)
                if mobAccumulator[dKey] then
                    mobAccumulator[dKey].targetedByCount = mobAccumulator[dKey].targetedByCount + 1
                end
            end
        end
    end

    -- 5. Finalize PseudoIDs, Toughness & Reconcile Debuffs
    local finalMobs = {}
    local pMaxHP = ws.context.playerMaxHP or 1
    local gSize = ws.context.groupSize or 1
    local pLevel = ws.context.playerLevel or 60

    for _, mob in pairs(mobAccumulator) do
        -- TOUGHNESS HEURISTIC:
        -- 1.0 = About as tough as the player.
        -- 5.0 = Dungeon Elite.
        -- 20.0+ = Raid Boss.
        local gPower = 1 + (gSize - 1) * 0.25 -- Group power scaling
        mob.toughness = mob.maxHP / (pMaxHP * gPower)

        -- Level Adjustment (Higher level mobs are tougher)
        local levelDiff = mob.level - pLevel
        if levelDiff > 0 then
            mob.toughness = mob.toughness * (1 + (levelDiff * 0.1))
        end

        mob.pseudoID = ScriptExtender_Scanner.GeneratePseudoID({
            unit = mob.unit,
            targetedByCount = mob.targetedByCount,
            debuffHash = mob.debuffs.hash
        })

        -- Reconciliation Logic
        mob.myDebuffs = ReconcileDebuffs(mob, ws)

        finalMobs[mob.pseudoID] = mob
        ws.aggregations.mobCount = ws.aggregations.mobCount + 1
        if mob.target == UnitName("player") then
            ws.aggregations.attackersOnPlayer = ws.aggregations.attackersOnPlayer + 1
        end
    end
    ws.mobs = finalMobs

    ScriptExtender_Log("Scanner: Discovered " .. tostring(ws.aggregations.mobCount) .. " targets.")
    return ws
end
