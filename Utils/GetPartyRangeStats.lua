-- GetPartyRangeStats Utility
-- Helper to check party member range.

ScriptExtender_Register("GetPartyRangeStats", "Dev Tool: Returns table of party members in range (slot 30).")
function GetPartyRangeStats()
    -- CONFIG: Checking Range using Action Slot 30 (Must be set by user)
    local actionSlot = 30

    local units = { "player", "party1", "party2", "party3", "party4" }
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
                -- Note: CheckInteractDistance(u, 4) is ~28y.
                -- We avoid TargetUnit/ClearTarget here as it breaks combat loops (Race Conditions).
            elseif CheckInteractDistance(u, 4) then
                rangeTable[u] = true
            end
        end
    end

    return rangeTable
end
