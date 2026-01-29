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

---@class MobData
---@field unit string The unitID (e.g. "target", "party1target")
---@field name string Name of the mob
---@field hp number Current HP
---@field maxHP number Maximum HP
---@field hpPct number Health Percentage (0-100)
---@field hpBucket number HP Bucket (0-10)
---@field energyBucket number Mana/Energy Bucket (0-10)
---@field level number Unit Level
---@field classification string "normal", "elite", "worldboss", etc.
---@field creatureType string "Humanoid", "Beast", etc.
---@field raidIcon number Raid Icon Index (0-8)
---@field rangeBucket number Estimated Distance Bucket (0-3)
---@field debuffs table Raw debuff data
---@field inCombat boolean Is the mob affecting combat?
---@field isCasting string|nil Name of spell being cast, or nil
---@field target string|nil Name of the unit the mob is targeting
---@field targetedByCount number How many friendly units are targeting this mob
---@field isFleeing boolean Heuristic for fleeing mobs
---@field toughness number Calculated threat/strength rating
---@field pseudoID string | nil  Unique identifier for tracking
---@field isTarget boolean Whether the mob is the player's current target
---@field myDebuffs table Map of debuffs applied by the player [SpellName]=true

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
        "%s_%d_%d_%s_%d_%s", -- Removed target (volatile)
        name or "Unknown",
        maxHP or 0,
        level or 0,
        classif or "normal",
        raidIcon or 0,
        cType or "Unknown"
    )
    return pseudoID
end

-- Helper: Compares two PseudoIDs for Physical Identity
-- Ignores volatile fields (like Current Target) if a physical match is found.
function ScriptExtender_Scanner.IsIDCompatible(id1, id2)
    if not id1 or not id2 then return false end
    if id1 == id2 then return true end

    -- Parsing logic (Stable across all Lua versions)
    local function GetParts(id)
        local p = {}
        -- string.gfind is the Lua 5.0 equivalent of gmatch
        for part in string.gfind(id, "([^_]+)") do
            table.insert(p, part)
        end
        return p
    end

    local p1 = GetParts(id1)
    local p2 = GetParts(id2)

    -- ID Format: Name(1)_MaxHP(2)_Level(3)_Classif(4)_Icon(5)_Type(6)
    if table.getn(p1) < 6 or table.getn(p2) < 6 then return false end

    -- MATCH: Name, MaxHP, Level, Classification, and RaidIcon must match.
    if p1[1] == p2[1] and p1[2] == p2[2] and p1[3] == p2[3] and
        p1[4] == p2[4] and p1[5] == p2[5] then
        return true
    end

    return false
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
        targetedByCount = 0,
        isTarget = false
    }

    if UnitCastingInfo then
        local sName = UnitCastingInfo(unit)
        if sName then mob.isCasting = sName end
    end

    -- Fleeing Heuristic (Humanoids run at low HP)
    mob.isFleeing = false
    if mob.inCombat and mob.hpPct < 20 and (mob.creatureType == "Humanoid") then
        mob.isFleeing = true
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

    -- Static Context Snapshot
    ws.context = {
        playerHP = UnitHealth("player"),
        playerMaxHP = UnitHealthMax("player"),
        playerHP_Pct = (UnitHealth("player") / (UnitHealthMax("player") or 1)) * 100,
        playerMana = UnitMana("player"),
        playerMana_Pct = (UnitMana("player") / (UnitManaMax("player") or 1)) * 100,
        playerLevel = UnitLevel("player"),
        playerClass = class,
        playerShards = shardCount,
        playerBuffs = buffs,
        pet = petData,
        groupSize = groupSize,
        inCombat = UnitAffectingCombat("player"),
        target = UnitName("target"),
        initialTargetPseudoID = ScriptExtender_Scanner.GeneratePseudoID({ unit = "target" })
    }

    ---@type table<string, MobData>
    local mobAccumulator = {}

    -- Identifies and adds a mob to the accumulator
    local function AddMobToAccumulator(unit)
        local mob = GetRawMobData(unit)
        if not mob then return nil end

        -- CAPTURE identity immediately while unit exists
        local pID = ScriptExtender_Scanner.GeneratePseudoID({ unit = unit })
        mob.pseudoID = pID
        mob.foundInRange = true -- If the scanner found it, it was in range!

        if not mobAccumulator[pID] then
            mobAccumulator[pID] = mob
            return true
        end
        return false
    end

    -- 2. Discovery Strategy
    -- ALWAYS add current target first
    if UnitExists("target") and UnitCanAttack("player", "target") then
        local targetID = ScriptExtender_Scanner.GeneratePseudoID({ unit = "target" })
        ws.context.initialTargetPseudoID = targetID
        AddMobToAccumulator("target")

        if not UnitAffectingCombat("target") then
            ws.context.pullMode = true
            ScriptExtender_Log("Scanner: Pull Mode active. Monitoring potential pull.")
        end
    end

    if not ws.context.pullMode then
        local firstSeenKey = nil
        local matchesCount = 0
        for i = 1, 26 do
            TargetNearestEnemy()
            local mob = GetRawMobData("target")
            if mob then
                -- Robust Circle Check: Stop only after 2 identical name matches
                -- or a perfect identity match to prevent premature exit in identical packs.
                local dKey = mob.name .. "_" .. mob.level .. "_" .. mob.maxHP
                if firstSeenKey and dKey == firstSeenKey then
                    matchesCount = matchesCount + 1
                    if matchesCount >= 2 then break end
                end
                if not firstSeenKey then firstSeenKey = dKey end

                AddMobToAccumulator("target")
            else
                break
            end
        end
    end

    -- 3. Party Targets
    ws.aggregations = { mobCount = 0, attackersOnPlayer = 0, aggregateToughness = 0, classCounts = {} }
    local friends = { "player", "party1", "party2", "party3", "party4" }
    for _, friend in ipairs(friends) do
        if UnitExists(friend) then
            local _, class = UnitClass(friend)
            local classKey = string.upper(class or "")
            ws.aggregations.classCounts[classKey] = (ws.aggregations.classCounts[classKey] or 0) + 1
        end
    end

    -- 4. Finalize & targetedByCount
    for _, friend in ipairs(friends) do
        if UnitExists(friend) then
            local t = friend .. "target"
            if UnitExists(t) then
                local name = UnitName(t)
                local level = UnitLevel(t)
                local hpMax = UnitHealthMax(t)
                local dKey = name .. "_" .. level .. "_" .. hpMax
                if mobAccumulator[dKey] then
                    mobAccumulator[dKey].targetedByCount = mobAccumulator[dKey].targetedByCount + 1
                end
            end
        end
    end

    -- 5. Finalize List
    local finalMobs = {}
    local pMaxHP = ws.context.playerMaxHP or 1
    local gSize = ws.context.groupSize or 1
    local pLevel = ws.context.playerLevel or 60

    for _, mob in pairs(mobAccumulator) do
        local gPower = 1 + (gSize - 1) * 0.25
        mob.toughness = mob.hp / (pMaxHP * gPower)
        local levelDiff = mob.level - pLevel
        if levelDiff > 0 then mob.toughness = mob.toughness * (1 + (levelDiff * 0.1)) end

        mob.myDebuffs = ReconcileDebuffs(mob, ws)
        mob.isTarget = (mob.pseudoID == ws.context.initialTargetPseudoID)

        if ws.context.pullMode or mob.inCombat then
            finalMobs[mob.pseudoID] = mob
            ws.aggregations.mobCount = ws.aggregations.mobCount + 1
            ws.aggregations.aggregateToughness = ws.aggregations.aggregateToughness + (mob.toughness or 0)
            if mob.target == UnitName("player") then
                ws.aggregations.attackersOnPlayer = ws.aggregations.attackersOnPlayer + 1
            end
        end
    end
    ws.mobs = finalMobs

    ScriptExtender_Log("Scanner: Discovered " .. tostring(ws.aggregations.mobCount) .. " targets.")
    return ws
end
