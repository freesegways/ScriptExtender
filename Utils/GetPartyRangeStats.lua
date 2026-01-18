-- GetPartyRangeStats Utility
-- Helper to check party member range.

ScriptExtender_Register("GetPartyRangeStats", "Dev Tool: Returns table of party members in range (slot 30).")
function GetPartyRangeStats()
    -- CONFIG: Checking Range using Action Slot 30 (Must be set by user)
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
