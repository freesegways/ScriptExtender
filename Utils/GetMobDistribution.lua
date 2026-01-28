-- GetMobDistribution Utility
-- Helper to count distinct mobs in combat with the party.

ScriptExtender_Register("GetMobDistribution", "Dev Tool: Returns count and distribution table of nearby combatants.")
function GetMobDistribution()
    local scanLimit = 20

    -- 1. MAPPING TABLES
    local nameToUnit = {}
    local distribution = {
        ["player"] = 0,
        ["party1"] = 0,
        ["party2"] = 0,
        ["party3"] = 0,
        ["party4"] = 0,
        ["pet"] = 0
    }

    local playerName = UnitName("player")
    if playerName then nameToUnit[playerName] = "player" end

    local petName = UnitName("pet")
    if petName then nameToUnit[petName] = "pet" end

    for i = 1, 4 do
        local n = UnitName("party" .. i)
        if n then nameToUnit[n] = "party" .. i end
    end

    -- 2. DATA
    local seenMobs = {}
    local totalCombatants = 0

    local savedT = nil
    if UnitExists("target") then savedT = UnitName("target") end

    -- 3. HASH FUNCTION (The "ID Generator")
    local function GenerateMobHash(u)
        -- Base Value: Health + MaxHealth (This separates wounded mobs instantly)
        local h = UnitHealth(u)
        local hm = UnitHealthMax(u)
        local hash = h + (hm * 10000)

        -- Add Name Bytes
        local n = UnitName(u) or "X"
        local len = string.len(n)
        for i = 1, len do
            hash = hash + string.byte(n, i)
        end

        -- Add Debuff Textures (The critical differentiator)
        local i = 1
        while UnitDebuff(u, i) do
            local tex = UnitDebuff(u, i)
            -- Extract the last few chars of texture path to keep it fast but unique
            local lenTex = string.len(tex)
            local start = math.max(1, lenTex - 5)
            for j = start, lenTex do
                hash = hash + string.byte(tex, j)
            end
            i = i + 1
        end

        return hash
    end

    -- 4. SCAN LOOP
    for i = 1, scanLimit do
        TargetNearestEnemy()

        -- Stop if we cycle back to the start (no new target found) or no target exists
        if not UnitExists("target") then
            break
        end

        if not UnitIsDead("target") and UnitCanAttack("player", "target") then
            if UnitAffectingCombat("target") then
                -- GENERATE NUMERICAL HASH
                local id = GenerateMobHash("target")

                if not seenMobs[id] then
                    seenMobs[id] = true
                    totalCombatants = totalCombatants + 1

                    local victimName = UnitName("targettarget")
                    if victimName and nameToUnit[victimName] then
                        local unitID = nameToUnit[victimName]
                        distribution[unitID] = distribution[unitID] + 1
                    end
                end
            end
        end

        -- Safety Break: If we accidentally target ourselves or a friend (rare bug), stop
        if UnitIsFriend("player", "target") then break end
    end

    -- 5. RESTORE
    if savedT then
        TargetByName(savedT)
        -- If TargetByName picks the wrong unit (duplicate names), we clear to be safe
        if UnitName("target") ~= savedT then ClearTarget() end
    else
        ClearTarget()
    end

    return totalCombatants, distribution
end
