-- Classes/Druid/AutoDruidBuffs.lua
-- Automatically handles Druid buffs (Mark of the Wild, Thorns, Omen of Clarity).

if not AB_Track then AB_Track = {} end
if not AB_LastPrint then AB_LastPrint = 0 end

-- Create scanning tooltip for name-based buff detection
local SE_ScanTooltip = CreateFrame("GameTooltip", "SE_ScanTooltip_Druid", nil, "GameTooltipTemplate")
SE_ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

function AutoDruidBuffs(m)
    local tm, th = GetTime(), (tonumber(m) or 5) * 60
    local _, pClass = UnitClass("player")

    -- Configuration
    -- Spells to check. Order indicates generic priority if multiple are missing (though scoring handles target priority).
    local BUFFS = {
        {
            -- Mark of the Wild
            spell = "Mark of the Wild",
            buffName = "Mark of the Wild",
            targetType = "party", -- Cast on self and party
            classFilter = nil     -- All classes
        },
        {
            -- Thorns
            spell = "Thorns",
            buffName = "Thorns",
            targetType = "party",
            classFilter = { ["WARRIOR"] = true, ["PALADIN"] = true, ["ROGUE"] = true, ["DRUID"] = true, ["SHAMAN"] = true } -- Melee-ish classes + Tanks
        },
        {
            -- Omen of Clarity
            spell = "Omen of Clarity",
            buffName = "Omen of Clarity",
            targetType = "self", -- Self only
            classFilter = nil
        }
    }

    local U = { "player", "party1", "party2", "party3", "party4" }

    -- Helper: HasBuff (Tooltip Scan)
    local function HasBuff(unit, buffName)
        local i = 0
        while UnitBuff(unit, i + 1) do -- UnitBuff in 1.12 is 1-indexed? No somewhat inconsistent. Standard loop:
            -- Using GetPlayerBuff for player is reliable, UnitBuff for others.
            -- Actually, UnitBuff returns name/texture in later expansions. In 1.12 it returns texture.
            -- We need to use valid indices.

            -- Universal Scanner for Name:
            SE_ScanTooltip:ClearLines()
            if unit == "player" then
                -- Player specific scan for accuracy
                local index = GetPlayerBuff(i, "HELPFUL")
                if index < 0 then break end
                SE_ScanTooltip:SetPlayerBuff(index)
            else
                -- Party unit scan
                SE_ScanTooltip:SetUnitBuff(unit, i + 1)
            end

            local name = SE_ScanTooltipTextLeft1:GetText()
            -- Check validity (UnitBuff returns nil if no buff at index)
            if unit ~= "player" and not UnitBuff(unit, i + 1) then break end

            if name and string.find(name, buffName) then
                -- Duration check
                local rem = 0
                if unit == "player" then
                    local index = GetPlayerBuff(i, "HELPFUL")
                    rem = GetPlayerBuffTimeLeft(index)
                else
                    -- Estimating for party members is hard without addons.
                    -- We rely on tracking: AB_Track[UnitName..BuffName]
                    local k = UnitName(unit) .. buffName
                    if AB_Track[k] then
                        local elapsed = tm - AB_Track[k]
                        -- We assume strict duration match is complex, so we check if we tracked it recently.
                        -- If we cast it < 25 mins ago (for 30m buff) we assume it's good?
                        -- Mark is 30m. Thorns is 10m.
                        -- Let's define duration in BUFFS config? For now use generalized logic:
                        -- If we see the buff, we assume it's good unless we strictly know otherwise.
                        -- Vanilla API doesn't give timeleft for others easily.
                        rem = 3600 -- Dummy high value to say "Present"
                    else
                        rem = 3600 -- Present but untracked
                    end
                end
                return true, rem
            end
            i = i + 1
        end
        return false, 0
    end

    -- Logic
    local best = { priority = -1 }

    for _, buffDef in ipairs(BUFFS) do
        -- 1. Do we know the spell?
        if ScriptExtender_IsSpellLearned(buffDef.spell, pClass) then
            -- 2. Targets
            for _, unit in ipairs(U) do
                local process = false

                -- Valid Unit?
                if UnitExists(unit) and UnitIsFriend("player", unit) and not UnitIsDeadOrGhost(unit) and UnitIsConnected(unit) then
                    local isSelf = (unit == "player")

                    -- Check Scope
                    if buffDef.targetType == "self" and isSelf then
                        process = true
                    elseif buffDef.targetType == "party" then
                        -- Check Class Filter
                        if buffDef.classFilter then
                            local _, uClass = UnitClass(unit)
                            if buffDef.classFilter[uClass] then
                                process = true
                            end
                        else
                            process = true -- Everyone
                        end
                    end

                    -- Range Check
                    if process and not isSelf then
                        if not CheckInteractDistance(unit, 4) then process = false end
                    end
                end

                if process then
                    local hasIt, rem = HasBuff(unit, buffDef.buffName)
                    -- Re-buff if missing or < 5 mins (300s) on self
                    -- For party, we just check existence because timeleft is hard
                    local threshold = (unit == "player") and 300 or 0

                    if not hasIt or (unit == "player" and rem < threshold) then
                        -- Score this need
                        -- Use fixed weighting:
                        -- Mark: 5
                        -- Thorns: 3
                        -- Omen: 2
                        local score = 0
                        if buffDef.spell == "Mark of the Wild" then score = 5 end
                        if buffDef.spell == "Thorns" then score = 3 end
                        if buffDef.spell == "Omen of Clarity" then score = 2 end

                        if score > best.priority then
                            best = { priority = score, unit = unit, spell = buffDef.spell, name = buffDef.buffName }
                        end
                    end
                end
            end
        end
    end

    -- Execution
    if best.unit then
        local uName = UnitName(best.unit)
        ScriptExtender_Print("AutoBuff: Casting " .. best.spell .. " on " .. uName)

        -- Tracking update (Optimistic)
        AB_Track[uName .. best.name] = tm

        TargetUnit(best.unit)
        CastSpellByName(best.spell)
        if best.unit ~= "target" then TargetLastTarget() end
    end
end

ScriptExtender_Register("AutoDruidBuffs", "Automatically casts Druid buffs (Mark of the Wild, Thorns, Omen).")
