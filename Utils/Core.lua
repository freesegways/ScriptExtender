-- Shared Utility Functions

-- Example: Check if a value exists in a simple list/table
function ScriptExtender_Utils_Contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Placeholder for role detection. 
-- In the future, this could inspect talents or gear.
ScriptExtender_Register("GetTankInfo", "Dev Tool: Returns the identified Tank name and UnitID.")
function GetTankInfo()
    local units = {"player", "party1", "party2", "party3", "party4"}
    
    -- "Instant Win" Buffs
    local tankBuffs = {"DefensiveStance", "BearForm", "SealOfFury"}

    -- Defaults (Fallback to player if everyone is naked/dead)
    local bestName = UnitName("player")
    local bestID = "player"
    local highestHP = 0

    for _, u in ipairs(units) do
        if UnitExists(u) and UnitIsConnected(u) then
            -- 1. Check for Definitive Tank Buffs
            local i = 1
            while UnitBuff(u, i) do
                local b = UnitBuff(u, i)
                for _, t in ipairs(tankBuffs) do
                    if string.find(b, t) then
                        -- FOUND IT! Return immediately.
                        return UnitName(u), u 
                    end
                end
                i = i + 1
            end

            -- 2. Track Max HP (Fallback for Shaman/Lazy Tanks)
            local hp = UnitHealthMax(u)
            if hp > highestHP then
                highestHP = hp
                bestName = UnitName(u)
                bestID = u
            end
        end
    end

    -- Returns Name ("Thex") and ID ("party2")
    return bestName, bestID
end

ScriptExtender_Register("GetHealerInfo", "Dev Tool: Returns the identified Healer name and UnitID.")
function GetHealerInfo()
    local units = {"player", "party1", "party2", "party3", "party4"}
    
    -- Classes capable of healing
    local validClasses = {
        ["PRIEST"] = true, 
        ["SHAMAN"] = true, 
        ["DRUID"] = true, 
        ["PALADIN"] = true
    }
    
    -- Buffs that PROVE they are NOT a healer
    local dpsBuffs = {
        "Shadowform",                -- Shadow Priest
        "Spell_Nature_ForceOfNature" -- Moonkin
    }

    local bestName = UnitName("player")
    local bestID = "player"
    local highestMana = 0

    for _, u in ipairs(units) do
        if UnitExists(u) and UnitIsConnected(u) then
            local _, class = UnitClass(u)
            
            -- 1. Must be a Healing Class AND use Mana (filters out Bear/Cat Druids)
            if validClasses[class] and UnitPowerType(u) == 0 then
                
                -- 2. Check for DPS Forms (Shadow/Moonkin)
                local isDPS = false
                local i = 1
                while UnitBuff(u, i) do
                    local b = UnitBuff(u, i)
                    for _, t in ipairs(dpsBuffs) do
                        if string.find(b, t) then isDPS = true break end
                    end
                    if isDPS then break end
                    i = i + 1
                end
                
                -- 3. Compare Mana Max (Healers stack Int, Ele/Enhance/Ret usually have less)
                if not isDPS then
                    local mana = UnitManaMax(u)
                    if mana > highestMana then
                        highestMana = mana
                        bestName = UnitName(u)
                        bestID = u
                    end
                end
            end
        end
    end

    return bestName, bestID
end

ScriptExtender_Register("GetPartyRangeStats", "Dev Tool: Returns table of party members in range (slot 30).")
function GetPartyRangeStats()
    -- CONFIG: Checking Range using Action Slot 30
    local actionSlot = 30
    
    local units = {"player", "party1", "party2", "party3", "party4"}
    local rangeTable = {}
    
    -- SCAN LOOP
    for _, u in ipairs(units) do
        -- Default to FALSE
        rangeTable[u] = false 
        
        if UnitExists(u) and UnitIsConnected(u) and not UnitIsDeadOrGhost(u) then
            -- A. SELF (Always safe)
            if u == "player" then
                rangeTable[u] = true
            
            -- B. FAST CHECK (0-28 yards)
            elseif CheckInteractDistance(u, 4) then
                rangeTable[u] = true
            
            -- C. PRECISION CHECK (29-40 yards)
            -- Targets unit to check Slot 30
            elseif UnitIsVisible(u) then
                TargetUnit(u)
                if IsActionInRange(actionSlot) == 1 then
                    rangeTable[u] = true
                end
            end
        end
    end

    -- FORCE CLEAR (No target at the end)
    ClearTarget()

    return rangeTable
end

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
    
    for i=1,4 do 
        local n = UnitName("party"..i)
        if n then nameToUnit[n] = "party"..i end
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
        for i=1, len do
            hash = hash + string.byte(n, i)
        end
        
        -- Add Debuff Textures (The critical differentiator)
        local i = 1
        while UnitDebuff(u, i) do
            local tex = UnitDebuff(u, i)
            -- Extract the last few chars of texture path to keep it fast but unique
            local lenTex = string.len(tex)
            local start = math.max(1, lenTex - 5)
            for j=start, lenTex do
                hash = hash + string.byte(tex, j)
            end
            i = i + 1
        end

        return hash
    end

    -- 4. SCAN LOOP
    for i=1, scanLimit do
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
