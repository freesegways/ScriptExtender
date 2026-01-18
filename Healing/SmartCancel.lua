-- General Healing Scripts & Smart Cancel Logic

-- Global State for Healing Tracking
HC_Target = nil
HC_StartHP = 0
HC_Amount = 0

-- Helper to start tracking a heal
-- Usage in macro: /run TrackHeal("target", 2300) /cast Greater Heal
ScriptExtender_Register("TrackHeal", "TrackHeal(unit, amount) - Records HP state before casting.")
function TrackHeal(unit, amount)
    if UnitExists(unit) then
        HC_Target = unit
        HC_StartHP = UnitHealth(unit)
        HC_Amount = amount or 0
        -- ScriptExtender_Log("Healing " .. UnitName(unit) .. " (HP: " .. HC_StartHP .. ") for " .. HC_Amount)
    else
        HC_Target = nil
    end
end

ScriptExtender_Register("SmartCancel", "Cancels the current spell if the target has been healed by someone else.")
function SmartCancel()
    -- 1. Do we have an active heal tracked?
    if not HC_Target or not UnitExists(HC_Target) then 
        HC_Target = nil
        return 
    end

    -- 2. Are we actually casting? (Safety check)
    -- If we aren't casting/channeling, clear the vars and exit
    -- (Requires a library in 1.12 usually, but we assume state implies cast)
    
    local currHP = UnitHealth(HC_Target)
    local maxHP = UnitHealthMax(HC_Target)
    local deficit = maxHP - currHP
    
    -- 3. THE DECISION MATRIX
    
    -- A. PANIC MODE: If they are dying faster than before, COMMIT.
    -- (We assume current velocity is roughly consistent, but if they dropped HP, we ignore cancel)
    if currHP < HC_StartHP then
        return -- They took damage. Do not cancel.
    end

    -- B. THE "PALADIN SNIPED ME" CHECK
    -- If HP went UP significantly since start, re-evaluate.
    local hpDelta = currHP - HC_StartHP
    
    if hpDelta > 0 then
        -- They were healed. Is my heal still useful?
        
        -- If my heal is HUGE (Greater Heal) and they only need a little (Flash Heal amount)
        -- AND they are safe (>80% hp), Cancel.
        if deficit < (HC_Amount * 0.8) and (currHP / maxHP) > 0.80 then
            SpellStopCasting()
            UIErrorsFrame:AddMessage("Cancelled: Snipe Detected!", 1, 0, 0)
            HC_Target = nil -- Reset State
            return
        end
        
        -- If they are topped off (Deficit < 200), Always Cancel
        if deficit < 200 then
            SpellStopCasting()
            UIErrorsFrame:AddMessage("Cancelled: Full HP", 1, 0, 0)
            HC_Target = nil
            return
        end
    end
end
