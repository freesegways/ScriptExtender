-- Classes/Warlock/WarlockAnalyze.lua
-- Analysis logic for Warlock combat automation.

if not WD_Track then WD_Track = {} end
if not WD_MarkSafe then WD_MarkSafe = {} end

local DoTs = { "Siphon Life", "Curse of Agony", "Corruption", "Immolate" }
local Tex = { "Requiem", "CurseOfSargeras", "Abomination", "Immolation" }
local Dur = { 30, 24, 18, 15 }

-- ANALYZER
function ScriptExtender_Warlock_Analyze(u, forceOOC, tm)
    local pl = "player"
    if not UnitExists(u) or UnitIsDead(u) or UnitIsFriend(pl, u) then return nil, nil, -1000 end
    if not forceOOC and not UnitAffectingCombat(u) and not UnitIsUnit(u, "target") then
        return nil, nil, -1000
    end

    local mark = GetRaidTargetIndex(u)
    local SafeTime = 5

    -- === IMMUNITY CHECK (BUFFS) ===
    for _, t in ipairs(ScriptExtender_ImmuneTextures) do
        if ScriptExtender_HasBuff(u, t) then return nil, nil, -1000 end
    end

    -- === CC SAFETY CHECK (MARK BASED) ===
    local ccFound = false
    for _, t in ipairs(ScriptExtender_CCTextures) do
        if ScriptExtender_HasDebuff(u, t) then
            ccFound = true
            break
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
    -- Higher priority than anything else if desperate
    if pMana < 35 and pHp > 75 then
        return "Life Tap", "self", 150
    end

    local hpVal = UnitHealth(u)
    local hp = hpVal -- Alias for compatibility with rest of file
    local hpMax = UnitHealthMax(u)
    local hpPercent = math.floor((hpVal / hpMax) * 100)
    local isPercentMode = (hpMax == 100)

    local prio = ScriptExtender_GetTargetPriority(u)
    local n = UnitName(u)

    -- SPELL DATA for Thresholds
    local sbDmg = ScriptExtender_GetSpellDamage("Shadowburn")
    if sbDmg == 0 then sbDmg = 200 end -- Fallback estimate
    local boltDmg = ScriptExtender_GetSpellDamage("Shadow Bolt")
    if boltDmg == 0 then boltDmg = 100 end

    -- 4. GCD CHECK
    -- Prevent spamming "Not Ready" during Global Cooldown.
    -- We check a common spell (Shadow Bolt) to see if we are on GCD.
    -- Loop a few book slots to find a valid spell to check.
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
    -- If we have the Shadow Trance buff, Shadow Bolt is instant. Fire immediately.
    -- Texture is usually Spell_Shadow_Twilight
    if ScriptExtender_HasBuff("player", "Spell_Shadow_Twilight") then
        return "Shadow Bolt", "kill", 160
    end

    local creatureType = UnitCreatureType(u)
    local isDrainImmune = (creatureType == "Mechanical" or creatureType == "Totem")

    -- 1. KILL / BURST / DRAIN
    -- Drain Life if Player is dying and enemy is not about to die immediately
    -- If using % mode, >10%. If Real HP, > 2x Shadowburn (basically not execute range)
    local safeToDrain = isPercentMode and (hpPercent > 10) or (hpVal > sbDmg)
    if pHp < 50 and safeToDrain and not isDrainImmune then
        return "Drain Life", "kill", (prio >= 2 and 95 or 35)
    end

    -- EXECUTE LOGIC
    -- Threshold for finishing: 25% or within Shadowburn kill range
    -- We want to PRIO finishing low mobs over dotting fresh ones.
    local execThreshold = isPercentMode and 25 or (sbDmg * 1.5)   -- 20% buffer
    local soulThreshold = isPercentMode and 20 or (boltDmg * 1.5) -- Drain Soul range is 20% or < 1.5 Bolts

    if (isPercentMode and hpPercent < 35) or (not isPercentMode and hpVal < (sbDmg * 3)) then
        -- Shadowburn: If in kill range, have shards, not on CD
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

            -- Strict Cooldown Check via Spellbook
            -- WD_Track is a fallback, but we prefer real API
            local sbReady = false
            if shards > 0 then
                sbReady = true -- Assume ready unless we find it on CD
                -- Find Shadowburn in spellbook to check true CD
                for i = 1, 120 do
                    local sName = GetSpellName(i, BOOKTYPE_SPELL)
                    if not sName then break end
                    if sName == "Shadowburn" then
                        local start, dur, _ = GetSpellCooldown(i, BOOKTYPE_SPELL)
                        if start > 0 and dur > 0 then sbReady = false end
                        break
                    end
                end
            end

            if sbReady and shards > 0 and (not WD_Track["SB"] or (tm - WD_Track["SB"]) > 15) then
                WD_Track["SB"] = tm
                return "Shadowburn", "kill", (prio >= 2 and 140 or 100)
            end
        end
        -- Drain Soul if very low (to get shard)
        local inSoulRange = (isPercentMode and hpPercent <= 20) or
            (hpVal <= soulThreshold)
        if inSoulRange then
            -- Very high priority to ensure we shard and don't dot
            return "Drain Soul", "kill", (prio >= 2 and 130 or 90)
        end
    end

    if pMana < 35 and UnitPowerType(u) == 0 and UnitMana(u) > 0 then
        return "Drain Mana", "kill", (prio >= 2 and 85 or 25)
    end

    -- 2. DOTS & CURSES
    -- Check Malediction (free Agony if using other curses)
    local hasMalediction = ScriptExtender_HasTalent("Malediction")
    local hasSiphonLife = ScriptExtender_HasTalent("Siphon Life")

    -- Estimate Damage Thresholds
    -- We use Shadow Bolt as a baseline "Nuke" Unit
    local boltDmg = ScriptExtender_GetSpellDamage("Shadow Bolt")
    if boltDmg == 0 then boltDmg = 50 end -- Fallback
    local siphonDmg = ScriptExtender_GetSpellDamage("Siphon Life")
    if siphonDmg == 0 then siphonDmg = 150 end

    -- GROUP LOGIC ADJUSTMENTS
    -- Count nearby teammates to estimate group DPS.
    local dpsMultiplier = 1.0
    local nearbyCount = 0

    local numRaid = GetNumRaidMembers()
    local numParty = GetNumPartyMembers()

    if numRaid > 0 then
        -- In raid, assume high DPS if anyone is targeting our mob, or just general high pace.
        -- For safety/simplicity, we just assume a high multiplier to avoid heavy dotting on trash.
        dpsMultiplier = 3.0
    elseif numParty > 0 then
        -- In party, check how many are actually roughly in range (28 yds - Interact Dist 4)
        for i = 1, numParty do
            local unit = "party" .. i
            if UnitExists(unit) and not UnitIsDeadOrGhost(unit) and CheckInteractDistance(unit, 4) then
                nearbyCount = nearbyCount + 1
            end
        end
        -- Scale: Base + 0.5 per nearby ally.
        -- 1 ally = 1.5x
        -- 4 allies = 3.0x
        dpsMultiplier = 1.0 + (nearbyCount * 0.5)
    end

    -- Increase effective damage based on group size to stop DoTs earlier
    local effectiveBoltDmg = boltDmg * dpsMultiplier

    -- Threshold for "Enemy is Low" (Anti-flee / Finish)
    local lowHpThreshold = isPercentMode and 25 or (effectiveBoltDmg * 2)

    -- Determine preferred curse
    local curseToUse = "Curse of Agony"
    local curseTex = "CurseOfSargeras"
    local curseDur = 24

    -- In Groups, we might prefer Recklessness for melee heavy comps, or Elements for casters.
    -- For simplicty, if mob is Elite/Boss in group, use Elements if talented.
    -- Logic: If Malediction, we have options.
    if hasMalediction then
        if hp < lowHpThreshold then
            -- Anti-flee / Low HP Execution phase
            curseToUse = "Curse of Recklessness(Rank 1)"
            curseTex = "CurseOfRecklessness"
            curseDur = 120
        elseif dpsMultiplier > 1.0 and (UnitClassification(u) == "worldboss" or UnitClassification(u) == "elite" or UnitClassification(u) == "rareelite") then
            -- Elite in Group: Use Elements to buff party caster dmg (and our own)
            curseToUse = "Curse of the Elements"
            curseTex = "CurseOfSargeras" -- Malediction shares texture
            curseDur = 300
        else
            -- Default to Recklessness Rank 1 for general utility (armor reduce + anti fear) or standard Agony
            curseToUse = "Curse of Recklessness(Rank 1)"
            curseTex = "CurseOfRecklessness"
            curseDur = 120
        end
    end

    -- Estimate DoT Damages for "One DoT Kill" logic
    local agonyDmg = ScriptExtender_GetSpellDamage("Curse of Agony")
    if agonyDmg == 0 then agonyDmg = 84 end -- Rank 1 fallback
    local corrDmg = ScriptExtender_GetSpellDamage("Corruption")
    if corrDmg == 0 then corrDmg = 40 end   -- Rank 1 fallback
    local siphonDmg = ScriptExtender_GetSpellDamage("Siphon Life")
    if siphonDmg == 0 then siphonDmg = 45 end

    -- One DoT Kill Optimization Level Check
    local pLvl = UnitLevel("player")
    local tLvl = UnitLevel(u)
    if tLvl == -1 then tLvl = pLvl + 3 end
    local maxTargetLevel = math.min((pLvl * 0.5), (pLvl - 10))
    local isLowLevel = (tLvl > 0) and (tLvl <= maxTargetLevel)

    -- Hard Stop DoTs if target is dying (Execute Phase)
    -- Relaxed significantly. Only stop if target is truly almost dead.
    -- 5% HP or < 150 HP (approx 1 Shadow Bolt rank 3).
    local isDying = (isPercentMode and hpPercent < 5) or (hpVal < 150)

    if not isDying then
        local killerDotActive = false

        -- Process DoTs
        for x, s in ipairs(DoTs) do
            -- If a DoT is already doing enough damage to kill, stop casting new ones.
            -- BUT if we are at a curse slot, we continue (to check if we need to apply curse for utility)
            local isCurseSlot = (s == "Curse of Agony")

            if killerDotActive and not isCurseSlot then break end

            local castName = s      -- The spell we intend to cast
            local trackTex = Tex[x] -- The texture we look for to verify it's up
            local duration = Dur[x] -- The duration we track
            local skipCast = false

            -- Filter: Siphon Life
            if s == "Siphon Life" then
                if not hasSiphonLife or isDrainImmune then
                    skipCast = true
                else
                    -- Avoid Siphon Life on trivial mobs not handled by LowLevel check (e.g. dying fast from bolts)
                    -- In groups, skip Siphon Life on non-elites almost always as they die too fast
                    local isShortFight = (hpVal < (boltDmg * 6))
                    if isPercentMode then isShortFight = (hpPercent < 50) end

                    if dpsMultiplier > 1.0 and UnitClassification(u) == "normal" then
                        isShortFight = true
                    end

                    local classif = UnitClassification(u)
                    if classif == "worldboss" or classif == "elite" or classif == "rareelite" then
                        isShortFight = false
                    end

                    if isShortFight then
                        skipCast = true
                    end
                end
            end

            -- Filter: Corruption cast time efficiency
            -- If in group and mob is dying, skip cast time spells (Immolate)
            if dpsMultiplier > 1.0 and s == "Immolate" and hpPercent < 40 then
                skipCast = true
            end

            if not skipCast then
                local maledictionActive = false

                if isCurseSlot then
                    if hasMalediction then
                        castName = curseToUse -- Swap Agony for CoR/CoE
                        maledictionActive = true
                        -- We KEEP 'trackTex' as Agony because Malediction applies Agony visual
                    end
                end

                local k = n .. trackTex
                local last = WD_Track[k] or 0
                local elapsed = tm - last
                local hasDot = ScriptExtender_HasDebuff(u, trackTex)

                -- SPECIAL CASING FOR MALEDICTION:
                -- If we use Malediction, we track Agony Texture (CurseOfSargeras).
                if maledictionActive and not hasDot then
                    -- Check latency protection via tracker (Index 2 is Agony)
                    local k2 = n .. Tex[2]
                    local last2 = WD_Track[k2] or 0
                    local el2 = tm - last2
                    if last2 > 0 and el2 < 1.5 then hasDot = true end
                elseif not hasDot then
                    -- Standard latency protection
                    if last > 0 and elapsed < 1.5 then hasDot = true end
                end

                if hasDot and last == 0 then elapsed = 0 end

                -- KILLER CHECK LOGIC (Restored & Gated by Level)
                -- If existing dot kills the mob, we shouldn't waste mana on more dots.
                -- STRICTLY ONLY FOR LOW LEVEL MOBS.
                if hasDot and isLowLevel then
                    local thisDotDmg = 0
                    if isCurseSlot then
                        thisDotDmg = agonyDmg
                    elseif s == "Corruption" then
                        thisDotDmg = corrDmg
                    elseif s == "Siphon Life" then
                        thisDotDmg = siphonDmg
                    end

                    -- Check remaining damage capability
                    local safeElapsed = elapsed
                    if safeElapsed < 0 then safeElapsed = 0 end
                    if safeElapsed < duration then
                        local remRatio = 1 - (safeElapsed / duration)
                        local remDmg = thisDotDmg * remRatio
                        if remDmg > hpVal then
                            killerDotActive = true
                        end
                    end
                end

                -- REFRESH LOGIC:
                local shouldCast = false

                if not hasDot then
                    shouldCast = true
                elseif last > 0 and elapsed > (duration - 3) and elapsed < (duration + 5) then
                    shouldCast = true
                end

                -- Do not cast Long DoTs if target is about to die
                local isLongDoT = (duration > 15)
                local timeToDieShort = (hpVal < boltDmg)
                -- In group, timeToDieShort is looser
                if dpsMultiplier > 1.0 then timeToDieShort = (hpVal < effectiveBoltDmg * 2) end

                if isLongDoT and timeToDieShort and not string.find(castName, "Recklessness") then
                    shouldCast = false
                end

                -- Single DoT Kill Logic Check
                if shouldCast then
                    -- if killerDotActive (from previous dots) we skip, UNLESS it's a curse
                    if killerDotActive and not isCurseSlot then
                        shouldCast = false
                    end

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

                        -- Scoring: Prioritize spreading DoTs (Multi-Dotting).
                        -- Tiered Base Scores based on Mark Priority to respect Focus Fire.
                        local baseScore = 30
                        if prio >= 4 then
                            baseScore = 105 -- Skull
                        elseif prio == 3 then
                            baseScore = 100 -- Cross
                        elseif prio == 2 then
                            baseScore = 90  -- Normal
                        end

                        -- Decay: Prefer early dots (Siphon/Agony) over late dots (Corruption/Immolate)
                        -- This forces us to switch to a fresh target (Score ~85) rather than stacking the 3rd dot on current (Score ~75)
                        local decay = x * 5
                        local score = baseScore - decay

                        if wouldKill and isLowLevel then
                            score = score + 50
                        end
                        -- Boost Siphon Life on Elite/Boss
                        if s == "Siphon Life" and prio >= 3 then score = score + 10 end

                        return castName, "dot", score
                    end
                end
            end
        end
    end

    -- 3. FILLER
    -- Final fallback to ensure we ALWAYS do something.
    local filler = "Drain Life"
    if pHp > 60 then filler = "Drain Soul" end
    if dpsMultiplier > 1.0 and pHp > 40 then filler = "Drain Soul" end

    -- Drain Immunity Override
    if filler == "Drain Life" and isDrainImmune then
        filler = "Shadow Bolt"
        if pMana < 20 then filler = "Shoot" end
    end

    -- If we are OOM, use Wand (Shoot)
    if pMana < 10 then
        filler = "Shoot"
    end

    return filler, "fill", (prio >= 2 and 60 or 10)
end

function ScriptExtender_Warlock_UpdateTracker(s, n, tm)
    -- Check for direct matches
    for x, dS in ipairs(DoTs) do
        if s == dS then
            WD_Track[n .. Tex[x]] = tm
            return
        end
    end
    -- Check for Malediction swaps (CoR/CoE update Agony timer)
    if string.find(s, "Curse of Recklessness") or string.find(s, "Curse of the Elements") then
        -- Update Curse of Agony slot (Index 2 for Agony/Sargeras)
        WD_Track[n .. Tex[2]] = tm
    end
end
