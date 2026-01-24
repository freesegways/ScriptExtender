-- Classes/Warlock/WarlockAnalyze.lua
-- Analysis logic for Warlock combat automation.

if not WD_Track then WD_Track = {} end
if not WD_MarkSafe then WD_MarkSafe = {} end

local DoTs = { "Siphon Life", "Curse of Agony", "Corruption", "Immolate" }
local Tex = { "Requiem", "CurseOfSargeras", "Abomination", "Immolation" }
local Dur = { 30, 24, 18, 15 }

-- ANALYZER
function ScriptExtender_Warlock_CountWarlocks()
    local c = 0
    if GetNumRaidMembers() > 0 then
        for i = 1, 40 do
            local _, cls = UnitClass("raid" .. i)
            if cls == "WARLOCK" then c = c + 1 end
        end
    else
        local _, pCls = UnitClass("player")
        if pCls == "WARLOCK" then c = c + 1 end
        for i = 1, 4 do
            local _, cls = UnitClass("party" .. i)
            if cls == "WARLOCK" then c = c + 1 end
        end
    end
    return c
end

function ScriptExtender_Warlock_Analyze(u, forceOOC, tm)
    local pl = "player"
    if not UnitExists(u) or UnitIsDead(u) or UnitIsFriend(pl, u) then return nil, nil, -1000 end

    -- OOC Safety: Only process if target is in combat OR we are forcing OOC (Manual Start)
    if not forceOOC and not UnitAffectingCombat(u) then
        return nil, nil, -1000
    end

    local mark = GetRaidTargetIndex(u)
    local SafeTime = 5

    -- === IMMUNITY CHECK (BUFFS) ===
    if ScriptExtender_ImmuneTextures then
        for _, t in ipairs(ScriptExtender_ImmuneTextures) do
            if ScriptExtender_HasBuff(u, t) then return nil, nil, -1000 end
        end
    end

    -- === CC SAFETY CHECK (MARK BASED) ===
    local ccFound = false
    if ScriptExtender_CCTextures then
        for _, t in ipairs(ScriptExtender_CCTextures) do
            if ScriptExtender_HasDebuff(u, t) then
                ccFound = true
                break
            end
        end
    end

    if ccFound then
        if mark then WD_MarkSafe[mark] = tm end
        return nil, nil, -1000
    end

    if mark and WD_MarkSafe[mark] and (tm - WD_MarkSafe[mark]) < SafeTime then
        return nil, nil, -1000
    end

    -- === LOGIC START ===
    local pHp = math.floor((UnitHealth(pl) / UnitHealthMax(pl)) * 100)
    local pMana = math.floor((UnitMana(pl) / UnitManaMax(pl)) * 100)

    -- 0. SELF MAINTENANCE (Life Tap)
    if pMana < 35 and pHp > 75 then
        return "Life Tap", "self", 150
    end

    local hpVal = UnitHealth(u)
    local hpMax = UnitHealthMax(u)
    local hpPercent = math.floor((hpVal / hpMax) * 100)
    local isPercentMode = (hpMax == 100)

    local prio = ScriptExtender_GetTargetPriority(u)
    local n = UnitName(u)

    -- SPELL DATA for Thresholds
    local sbDmg = ScriptExtender_GetSpellDamage("Shadowburn")
    if sbDmg == 0 then sbDmg = 200 end
    local boltDmg = ScriptExtender_GetSpellDamage("Shadow Bolt")
    if boltDmg == 0 then boltDmg = 100 end

    -- 4. GCD CHECK
    local onGCD = false
    for i = 1, 20 do
        local sName, _ = GetSpellName(i, BOOKTYPE_SPELL)
        if sName then
            local start, dur, _ = GetSpellCooldown(i, BOOKTYPE_SPELL)
            if start > 0 and dur > 0 and dur <= 1.5 then
                onGCD = true
                break
            end
        end
    end
    if onGCD then return nil, nil, -1000 end

    -- 5. PROC CHECK (Nightfall / Shadow Trance)
    -- User Request: "Shadow Bolt... only be done on talent proc"
    if ScriptExtender_HasBuff("player", "Spell_Shadow_Twilight") then
        return "Shadow Bolt", "kill", 160
    end

    local creatureType = UnitCreatureType(u)
    local isDrainImmune = (creatureType == "Mechanical" or creatureType == "Totem")

    -- 1. KILL / BURST / DRAIN
    local safeToDrain = isPercentMode and (hpPercent > 10) or (hpVal > sbDmg)

    -- Heuristic: If we are in a group, stop draining earlier to contribute dps
    if GetNumPartyMembers() > 0 and pHp > 40 then safeToDrain = false end

    if pHp < 50 and safeToDrain and not isDrainImmune then
        return "Drain Life", "kill", (prio >= 2 and 95 or 35)
    end

    -- EXECUTE LOGIC
    local execThreshold = isPercentMode and 25 or (sbDmg * 1.5)
    local soulThreshold = isPercentMode and 20 or (boltDmg * 1.5)

    if (isPercentMode and hpPercent < 35) or (not isPercentMode and hpVal < (sbDmg * 3)) then
        -- Shadowburn
        local hasShadowburn = ScriptExtender_HasTalent("Shadowburn")
        local inRange = (isPercentMode and hpPercent <= 25) or (hpVal <= execThreshold)

        if hasShadowburn and inRange then
            local shards = 0
            for b = 0, 4 do
                for s = 1, GetContainerNumSlots(b) do
                    local l = GetContainerItemLink(b, s)
                    if l and string.find(l, "item:6265") then shards = shards + 1 end
                end
            end

            local sbReady = ScriptExtender_IsSpellReady("Shadowburn")

            if sbReady and shards > 0 and (not WD_Track["SB"] or (tm - WD_Track["SB"]) > 15) then
                WD_Track["SB"] = tm
                return "Shadowburn", "kill", (prio >= 2 and 140 or 100)
            end
        end
        -- Drain Soul
        local inSoulRange = (isPercentMode and hpPercent <= 20) or (hpVal <= soulThreshold)
        if inSoulRange then
            return "Drain Soul", "kill", (prio >= 2 and 130 or 90)
        end
    end

    if pMana < 35 and UnitPowerType(u) == 0 and UnitMana(u) > 0 then
        return "Drain Mana", "kill", (prio >= 2 and 85 or 25)
    end

    -- 2. DOTS & CURSES
    local hasMalediction = ScriptExtender_HasTalent("Malediction")
    local hasSiphonLife = ScriptExtender_HasTalent("Siphon Life")

    -- GROUP LOGIC ADJUSTMENTS
    -- Removed GetMobDistribution to prevent "Another Action" errors
    local dpsMultiplier = 1.0
    local numRaid = GetNumRaidMembers()
    local numParty = GetNumPartyMembers()

    if numRaid > 0 then
        dpsMultiplier = 3.0
    elseif numParty > 0 then
        -- Simple check: if in party, assume slightly higher dps / aggressive play
        dpsMultiplier = 1.5
    end

    local effectiveBoltDmg = boltDmg * dpsMultiplier
    local lowHpThreshold = isPercentMode and 25 or (effectiveBoltDmg * 2)

    -- === CURSE SELECTION LOOPS ===
    local curseToUse = nil
    local curseTex = nil
    local curseDur = 0

    local warlockCount = ScriptExtender_Warlock_CountWarlocks()
    local classif = UnitClassification(u)
    local isBoss = (classif == "worldboss" or classif == "elite" or classif == "rareelite")

    local candidates = {}
    -- Priority: Shadows -> Elements -> Recklessness -> Agony
    table.insert(candidates, { name = "Curse of Shadow", tex = "CurseOfAchimonde", dur = 300, isUtility = true })
    table.insert(candidates, { name = "Curse of the Elements", tex = "ChillTouch", dur = 300, isUtility = true })
    table.insert(candidates,
        { name = "Curse of Recklessness(Rank 1)", tex = "UnholyStrength", dur = 120, isUtility = true })
    table.insert(candidates, { name = "Curse of Agony", tex = "CurseOfSargeras", dur = 24, isUtility = false })

    -- Check Global Utility State (Mutually Exclusive Curses)
    local anyUtilityActive = false
    local myUtilityActive = false

    -- Check for presence of ANY utility curse on the target
    local utilityTextures = { "CurseOfAchimonde", "ChillTouch", "UnholyStrength" }
    for _, t in ipairs(utilityTextures) do
        if ScriptExtender_HasDebuff(u, t) then
            anyUtilityActive = true
            -- Check if it's ours
            local trackKey = n .. t
            local lastCast = WD_Track[trackKey] or 0
            -- If we cast it recently and it matches the duration (fuzzy check), it's ours.
            -- Or simpler: If we tracked it, assume it is ours until it expires?
            -- Better: If WD_Track says we have it active, we claim it.
            if (tm - lastCast) < 300 then myUtilityActive = true end
            break
        end
    end

    for _, c in ipairs(candidates) do
        -- Extract Base Name for Learning Check (remove Rank suffix)
        local baseName = string.gsub(c.name, "%(Rank %d+%)", "")

        if ScriptExtender_IsSpellLearned(baseName) or string.find(c.name, "Agony") then
            -- Check Tracker for THIS specific curse
            -- Logic note: We count CoR(Rank 1) as "UnholyStrength" texture.
            local trackKey = n .. c.tex
            local lastCast = WD_Track[trackKey] or 0
            local isMine = (tm - lastCast) < c.dur

            if c.isUtility then
                if myUtilityActive then
                    -- I own the utility slot. Ensure I stick to the SAME one (don't flip-flop priorities).
                    if isMine then
                        curseToUse = c.name; curseTex = c.tex; curseDur = c.dur
                        break
                    end
                    -- If I own the slot but this candidate is NOT it, skip (priority lower or different).
                elseif anyUtilityActive then
                    -- Someone ELSE owns the utility slot.
                    -- I CANNOT cast a utility curse (would overwrite theirs).
                    -- Skip.
                else
                    -- Slot is Open. Take it!
                    curseToUse = c.name; curseTex = c.tex; curseDur = c.dur
                    break
                end
            else
                -- Non-Utility (Agony)
                -- Always valid to cast if I don't have it up.
                -- (In priority order, if we skipped Utility, we land here)
                if isMine then
                    -- Maintain
                    curseToUse = c.name; curseTex = c.tex; curseDur = c.dur
                    break
                else
                    -- Cast new
                    -- Note: If I already selected a Utility curse above, loop breaks there.
                    -- So we only get here if Utility was skipped or My Utility logic failed.
                    -- Wait, if "My Utility Active", I might have broken loop on maintaining it.
                    -- If I am maintaining Utility, I do NOT cast Agony (Malediction handles it).

                    -- CORRECT.
                    curseToUse = c.name; curseTex = c.tex; curseDur = c.dur
                    break
                end
            end
        end
    end

    -- Fallback / Flee Logic
    if hpVal < lowHpThreshold and hpPercent < 20 and UnitCreatureType(u) == "Humanoid" and not isBoss then
        -- Flee Override
        curseToUse = "Curse of Recklessness(Rank 1)"
        curseTex = "UnholyStrength"
        curseDur = 120
    elseif not curseToUse and warlockCount == 1 and not isBoss then
        curseToUse = "Curse of Agony"
        curseTex = "CurseOfSargeras"
        curseDur = 24
    end

    -- Estimate DoT Damages
    local agonyDmg = ScriptExtender_GetSpellDamage("Curse of Agony")
    if agonyDmg == 0 then agonyDmg = 84 end
    local corrDmg = ScriptExtender_GetSpellDamage("Corruption")
    if corrDmg == 0 then corrDmg = 40 end
    local siphonDmg = ScriptExtender_GetSpellDamage("Siphon Life")
    if siphonDmg == 0 then siphonDmg = 150 end

    local pLvl = UnitLevel("player")
    local tLvl = UnitLevel(u)
    if tLvl == -1 then tLvl = pLvl + 3 end
    local maxTargetLevel = math.min((pLvl * 0.5), (pLvl - 10))
    local isLowLevel = (tLvl > 0) and (tLvl <= maxTargetLevel)

    -- DYING CHECK
    local killThreshold = (boltDmg * 3 * dpsMultiplier)
    -- If Group, killThreshold is higher (don't dot stuff that's gonna melt)
    if dpsMultiplier > 1.5 then killThreshold = killThreshold * 1.5 end

    local isDying = (isPercentMode and hpPercent < 20) or (hpVal < killThreshold)

    if not isDying then
        local killerDotActive = false

        -- Process DoTs
        for x, s in ipairs(DoTs) do
            local isCurseSlot = (s == "Curse of Agony")

            -- If we explicitly cancelled cursing (conflict), we skip curse slot
            local skipCast = false
            if isCurseSlot and not curseToUse then
                skipCast = true
            end

            if not skipCast then
                if killerDotActive and not isCurseSlot then break end

                local castName = s
                local trackTex = Tex[x]
                local duration = Dur[x]

                -- Dynamic updates for Curse Slot
                if isCurseSlot then
                    castName = curseToUse
                    trackTex = curseTex
                    duration = curseDur
                end

                -- Filter: Siphon Life
                if s == "Siphon Life" then
                    -- Strict: Only if Player Low (<50%) AND (Target High (>50%) or Boss)
                    -- Also respect Drain Immunity
                    local slCondition = (pHp < 50) and (isBoss or hpPercent > 50)
                    if not hasSiphonLife or isDrainImmune or not slCondition then
                        skipCast = true
                    end
                end

                -- Filter: Immolate
                if dpsMultiplier > 1.0 and s == "Immolate" and hpPercent < 40 then
                    skipCast = true
                end

                if not skipCast then
                    local k = n .. trackTex
                    local last = WD_Track[k] or 0
                    local elapsed = tm - last
                    local myDotActive = false

                    if last > 0 and elapsed < duration then myDotActive = true end

                    -- Determine if we should cast
                    local shouldCast = false

                    if not myDotActive then
                        shouldCast = true
                    end

                    -- Refresh Logic (Clip prevention / Early refresh)
                    if myDotActive and elapsed > (duration - 3) and elapsed < (duration + 5) then
                        shouldCast = true
                    end

                    -- Do not cast Long DoTs if target is about to die
                    local isLongDoT = (duration > 15)
                    local timeToDieShort = (hpVal < killThreshold)

                    if isLongDoT and timeToDieShort and not string.find(castName, "Recklessness") then
                        shouldCast = false
                    end

                    if shouldCast then
                        -- Killer Check Logic (Low Level Only)
                        if killerDotActive and not isCurseSlot then shouldCast = false end

                        if shouldCast then
                            local wouldKill = false
                            local thisDotDmg = 0
                            if isCurseSlot then
                                thisDotDmg = agonyDmg
                            elseif s == "Corruption" then
                                thisDotDmg = corrDmg
                            elseif s == "Siphon Life" then
                                thisDotDmg = siphonDmg
                            end

                            if thisDotDmg > hpVal then wouldKill = true end

                            local baseScore = 30
                            if prio >= 4 then
                                baseScore = 105
                            elseif prio == 3 then
                                baseScore = 100
                            elseif prio == 2 then
                                baseScore = 90
                            end

                            local decay = x * 5
                            local score = baseScore - decay

                            if wouldKill and isLowLevel then score = score + 50 end
                            if s == "Siphon Life" and prio >= 3 then score = score + 10 end

                            -- Priority Boost for DoTs in Groups (Spread Dmg)
                            if dpsMultiplier > 1.5 then score = score + 5 end

                            return castName, "dot", score
                        end
                    end
                end
            end
        end
    end

    -- 3. FILLER
    local filler = "Drain Life"
    if pHp > 60 then filler = "Drain Soul" end
    if dpsMultiplier > 1.0 and pHp > 40 then filler = "Drain Soul" end

    -- Removed "Force Shadow Bolt" logic to respect "Only on Proc" user request.
    -- However, if target is Immune to Drains (Mechanical), we MUST use Bolt or Shoot.
    if filler == "Drain Life" and isDrainImmune then
        if pMana > 40 then
            filler = "Shadow Bolt"
        else
            filler = "Shoot"
        end
    end

    -- If we are OOM, use Wand (Shoot)
    if pMana < 10 then
        filler = "Shoot"
    end

    return filler, "fill", (prio >= 2 and 60 or 10)
end

function ScriptExtender_Warlock_UpdateTracker(s, n, tm)
    for x, dS in ipairs(DoTs) do
        if s == dS then
            WD_Track[n .. Tex[x]] = tm
            return
        end
    end

    local isUtility = false
    if string.find(s, "Curse of Recklessness") then
        WD_Track[n .. "UnholyStrength"] = tm
        isUtility = true
    elseif string.find(s, "Curse of the Elements") then
        WD_Track[n .. "ChillTouch"] = tm
        isUtility = true
    elseif string.find(s, "Curse of Shadow") then
        WD_Track[n .. "CurseOfAchimonde"] = tm
    end

    if isUtility then
        -- Malediction Co-op: Assume Agony slot is now filled.
        WD_Track[n .. Tex[2]] = tm
    end
end
