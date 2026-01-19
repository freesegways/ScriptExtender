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

    -- Helper: Is 'u' a valid UNRELEASED corpse?
    -- In Vanilla, you cannot target Ghosts. You must click their skeleton manually.
    local function IsUnreleasedCorpse(u)
        return UnitExists(u) and UnitIsDead(u) and not UnitIsGhost(u) and UnitIsFriend("player", u)
    end

    -- 2. PRIORITY 1: MOUSEOVER (Unreleased)
    -- Emulate [target=mouseover] behavior
    if IsUnreleasedCorpse("mouseover") then
        ScriptExtender_Print("Priority Res: Mouseover")
        TargetUnit("mouseover")
        CastSpellByName(spell)
        TargetLastTarget()
        return
    end

    -- 3. PRIORITY 2: CURRENT TARGET (Unreleased)
    if IsUnreleasedCorpse("target") then
        ScriptExtender_Print("Resurrecting Target...")
        CastSpellByName(spell)
        return
    end

    -- 4. PRIORITY 3: AUTO-TARGET (Scan Group for Unreleased)
    local bestUnit = nil
    local bestScore = 0

    local function EvaluateUnit(u)
        if IsUnreleasedCorpse(u) and not UnitIsUnit("player", u) then
            if CheckInteractDistance(u, 4) then -- Approx 28 yards
                local score = 50
                local _, c = UnitClass(u)
                -- Prioritize Healers
                if c == "PRIEST" or c == "PALADIN" or c == "SHAMAN" or c == "DRUID" then
                    score = 100
                end

                -- Allow simple 'Next' cycling
                if u == "party1" then score = score + 1 end

                if score > bestScore then
                    bestScore = score
                    bestUnit = u
                end
            end
        end
    end

    -- Scan Party
    for i = 1, 4 do EvaluateUnit("party" .. i) end
    -- Scan Raid
    if GetNumRaidMembers() > 0 then
        for i = 1, 40 do EvaluateUnit("raid" .. i) end
    end

    if bestUnit then
        local n = UnitName(bestUnit)
        ScriptExtender_Print("Auto-Resurrecting: " .. (n or "Unknown"))
        TargetUnit(bestUnit)
        CastSpellByName(spell)
        return
    end

    -- 5. FALLBACK: RELEASED SPIRITS (Skeletons)
    -- If we found nobody to target, give the user the functionality to click a skeleton.
    ScriptExtender_Print("No unreleased bodies found. Click a skeleton!")
    CastSpellByName(spell)
end
