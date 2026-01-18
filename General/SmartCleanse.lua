-- Global Config
if not SC_AbolishTrack then SC_AbolishTrack={} end

ScriptExtender_Register("SmartCleanse", "Intelligently dispels/cleanses the party based on class and priority.")
function SmartCleanse()
    local pl = "player"
    local _, class = UnitClass(pl)
    
    -- 1. IDENTIFY ROLES (Using your helper scripts)
    -- We get the UnitIDs (e.g., "party1") directly
    local _, tankID = GetTankInfo()
    local _, healerID = GetHealerInfo()

    -- 2. SPELL MAPPING
    local Map = {
        ["PRIEST"]  = { ["Magic"]={"Dispel Magic"}, ["Disease"]={"Abolish Disease", true} },
        ["DRUID"]   = { ["Curse"]={"Remove Curse"}, ["Poison"]={"Abolish Poison", true} },
        ["MAGE"]    = { ["Curse"]={"Remove Lesser Curse"} },
        ["SHAMAN"]  = { ["Poison"]={"Cure Poison"}, ["Disease"]={"Cure Disease"} },
        ["PALADIN"] = { ["Magic"]={"Cleanse"}, ["Poison"]={"Cleanse"}, ["Disease"]={"Cleanse"} }
    }
    
    local MySpells = Map[class]
    if not MySpells then 
        ScriptExtender_Log("SmartCleanse: No cleanse spells defined for class " .. class)
        return 
    end
    
    -- 3. PRIORITY TEXTURES (Score 100)
    local HighPrio = {
        "Polymorph", "Fear", "Stun", "Sleep", "Silence", "HammerOfJustice", "Seduction"
    }
    
    -- 4. HELPER: ABOLISH CHECK
    local function HasAbolish(u)
        local i=1
        while UnitBuff(u,i) do
            local b = UnitBuff(u,i)
            if b and string.find(b, "Abolish") then return true end
            i=i+1
        end
        return false
    end

    -- 5. HELPER: CALCULATE ROLE BONUS
    -- Uses the global role identification functions
    local function GetRoleBonus(u)
        if u == pl then return 20 end -- Self Preservation
        
        -- Are they the identified Healer?
        if healerID and UnitIsUnit(u, healerID) then return 30 end
        
        -- Are they the identified Tank?
        if tankID and UnitIsUnit(u, tankID) then return 20 end
        
        return 0 -- Standard DPS
    end

    -- 6. ANALYZE UNIT
    local function Analyze(u)
        if not UnitExists(u) or UnitIsDeadOrGhost(u) or not UnitIsFriend(pl, u) then return -1 end
        if u~=pl and not CheckInteractDistance(u, 4) then return -1 end

        local bestScore = 0
        local bestSpell = nil
        
        -- Scan Debuffs
        local i=1
        while UnitDebuff(u,i) do
            local tex, apps, type = UnitDebuff(u,i)
            
            if type and MySpells[type] then
                local spellInfo = MySpells[type]
                local spellName = spellInfo[1]
                local isAbolish = spellInfo[2]
                
                if not (isAbolish and HasAbolish(u)) then
                    local score = 10 -- Base Score
                    
                    -- Check High Prio (CC)
                    for _, t in ipairs(HighPrio) do
                        if tex and string.find(tex, t) then score = 100 break end
                    end
                    
                    if score > bestScore then
                        bestScore = score
                        bestSpell = spellName
                    end
                end
            end
            i=i+1
        end
        
        if bestScore > 0 then
            return bestScore + GetRoleBonus(u), bestSpell
        end
        return 0
    end

    -- 7. MAIN LOOP
    local candidates = {"player", "party1", "party2", "party3", "party4", "target"}
    local winner = {score=0, unit=nil, spell=nil}
    
    for _, u in ipairs(candidates) do
        -- Dedup check for "target"
        local isDuplicate = false
        if u == "target" then
             if UnitIsUnit("target", "player") then isDuplicate=true end
             for j=1,4 do if UnitIsUnit("target", "party"..j) then isDuplicate=true break end end
        end

        if not isDuplicate then
            local score, spell = Analyze(u)
            if score and score > winner.score then
                winner = {score=score, unit=u, spell=spell}
            end
        end
    end

    -- 8. EXECUTE
    if winner.unit then
        local currentT = UnitName("target")
        local winnerName = UnitName(winner.unit)
        
        if currentT == winnerName then
            CastSpellByName(winner.spell)
        else
            TargetUnit(winner.unit)
            CastSpellByName(winner.spell)
            TargetLastTarget()
        end
        
        if winner.score >= 100 then
            DEFAULT_CHAT_FRAME:AddMessage("SmartCleanse: Removed CC from " .. winnerName)
        else
            ScriptExtender_Log("SmartCleanse: Cleansing " .. winnerName .. " with " .. winner.spell)
        end
    else
        ScriptExtender_Log("SmartCleanse: Nothing to cleanse.")
    end
end
