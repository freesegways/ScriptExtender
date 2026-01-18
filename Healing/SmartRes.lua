-- Healing/SmartRes.lua
-- Intelligent Resurrection script.
-- Supports: Priest, Paladin, Shaman, Druid.
-- Priority: Mouseover > Target > Dead Healer > Dead Party/Raid Member.
-- Checks for dead friendly units.

ScriptExtender_Register("SmartRes",
    "Automatically resurrects the mouseover unit, current target, or nearest dead party member with priority for healers.")

function SmartRes()
    -- 1. Determine Class Spell
    local _, cls = UnitClass("player")
    local spell = nil

    if cls == "PRIEST" then
        spell = "Resurrection"
    elseif cls == "PALADIN" then
        spell = "Redemption"
    elseif cls == "SHAMAN" then
        spell = "Ancestral Spirit"
    elseif cls == "DRUID" then
        spell = "Rebirth"
    end

    if not spell then
        ScriptExtender_Print("SmartRes: Your class cannot resurrect.")
        return
    end

    -- 2. Find Target (Mouseover > Target > Scan)
    local target = nil
    local autoTarget = false

    -- Check Mouseover
    if UnitExists("mouseover") and UnitIsDeadOrGhost("mouseover") and UnitIsFriend("player", "mouseover") then
        target = "mouseover"

        -- Check Current Target
    elseif UnitExists("target") and UnitIsDeadOrGhost("target") and UnitIsFriend("player", "target") then
        target = "target"

        -- Scan Group (Smart Auto-Target)
    else
        local bestUnit = nil
        local bestScore = 0

        local function EvaluateUnit(u)
            if UnitExists(u) and UnitIsDeadOrGhost(u) and UnitIsFriend("player", u) and not UnitIsUnit("player", u) then
                if CheckInteractDistance(u, 4) then -- Approx 28-30 yards
                    local score = 50
                    local _, c = UnitClass(u)
                    -- Prioritize Resurrectors
                    if c == "PRIEST" or c == "PALADIN" or c == "SHAMAN" or c == "DRUID" then
                        score = 100
                    end

                    if score > bestScore then
                        bestScore = score
                        bestUnit = u
                    end
                end
            end
        end

        -- Scan Party
        for i = 1, 4 do EvaluateUnit("party" .. i) end

        -- Scan Raid (if in raid)
        if GetNumRaidMembers() > 0 then
            for i = 1, 40 do EvaluateUnit("raid" .. i) end
        end

        if bestUnit then
            target = bestUnit
            autoTarget = true
        end
    end

    if not target then
        -- ScriptExtender_Print("SmartRes: No dead friendly target found.")
        return
    end

    -- 3. Execute
    local name = UnitName(target)

    if spell then
        if target == "mouseover" then
            TargetUnit("mouseover")
            CastSpellByName(spell)
            TargetLastTarget()
        elseif autoTarget then
            TargetUnit(target)
            CastSpellByName(spell)
            -- Do not switch back, user likely wants to res this person
        else
            -- Existing target
            CastSpellByName(spell)
        end

        ScriptExtender_Print("Resurrecting " .. (name or "Unknown") .. " with " .. spell .. "!")
    end
end
