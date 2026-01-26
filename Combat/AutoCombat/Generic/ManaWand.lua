-- Combat/ManaWand.lua
-- Automatically uses wand on targets affected by Judgement of Wisdom
-- Uses the CombatLoop infrastructure for robust targeting.

-- Create Frame for tooltip scanning if not exists
if not ScriptExtender_ScanTooltip then
    CreateFrame("GameTooltip", "ScriptExtender_ScanTooltip", nil, "GameTooltipTemplate")
    ScriptExtender_ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
end

-- 1. ANALYZER
function ScriptExtender_ManaWand_Analyze(params)
    local u = params.unit
    local allowManualPull = params.allowManualPull
    local isScanning = not allowManualPull

    -- Prerequisites check
    if not UnitExists(u) or UnitIsDead(u) or not UnitCanAttack("player", u) then
        return nil, nil, -1000
    end

    -- LOGIC: If we are scanning (isScanning=true) but we already have a valid
    -- manual target, we should NOT provide scan results. We want to stick to the manual target.
    if isScanning then
        if UnitExists("target") and not UnitIsDead("target") and UnitCanAttack("player", "target") then
            return nil, nil, -1000
        end
    end

    -- === IMMUNITY & CC SAFETY CHECK ===
    if getglobal("ScriptExtender_IsImmune") and ScriptExtender_IsImmune(u) then return nil, nil, -1000 end
    if getglobal("ScriptExtender_IsCC") and ScriptExtender_IsCC(u) then return nil, nil, -1000 end

    -- Verification: Check for Judgement of Wisdom
    local hasWisdom = false
    local i = 1
    while UnitDebuff(u, i) do
        ScriptExtender_ScanTooltip:ClearLines()
        ScriptExtender_ScanTooltip:SetUnitDebuff(u, i)
        local debuffName = ScriptExtender_ScanTooltipTextLeft1:GetText()
        if debuffName and string.find(debuffName, "Judgement of Wisdom") then
            hasWisdom = true
            break
        end
        i = i + 1
    end

    -- Special Manual Override:
    if hasWisdom then
        return "Shoot", "wand", 100
    elseif not isScanning then
        -- Manual Target Check (isScanning == false)
        return "Shoot", "wand", 50
    end

    return nil, nil, -1000
end

-- 2. MAIN FUNCTION
function ManaWand()
    local actors = {
        {
            analyzer = ScriptExtender_ManaWand_Analyze,
            onExecute = function(action, targetName, tm)
                -- Check if already shooting to toggle/prevent toggle spam
                local isAutoRepeating = false
                for slot = 1, 120 do
                    if IsAutoRepeatAction(slot) then
                        isAutoRepeating = true
                        break
                    end
                end

                if not isAutoRepeating then
                    CastSpellByName("Shoot")
                end
            end
        }
    }

    -- DISABLE SCANNING IF WE ALREADY HAVE A TARGET
    if UnitExists("target") and not UnitIsDead("target") and UnitCanAttack("player", "target") then
        actors.disableScan = true
    else
        -- If we are scanning (because we have no target), we want to CLEAR target if we find nothing.
        actors.untargetIfNoActionExecuted = true
    end

    ScriptExtender_AutoCombat_Run(actors)
end

ScriptExtender_Register("ManaWand", "Uses CombatLoop to find a target with Judgement of Wisdom and Wand it.")
