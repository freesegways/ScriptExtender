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
    if not forceOOC and not UnitAffectingCombat(u) then return nil, nil, -1000 end

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
    if pMana < 35 and pHp > 75 then
        return "Life Tap", "self", 110
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

    -- 1. KILL / BURST / DRAIN
    -- Drain Life if Player is dying and enemy is not about to die immediately
    -- If using % mode, >10%. If Real HP, > 2x Shadowburn (basically not execute range)
    local safeToDrain = isPercentMode and (hpPercent > 10) or (hpVal > sbDmg)
    if pHp < 50 and safeToDrain then
        return "Drain Life", "kill", (prio >= 2 and 95 or 35)
    end

    -- EXECUTE LOGIC
    -- Threshold for finishing: 25% or within Shadowburn kill range
    local execThreshold = isPercentMode and 25 or (sbDmg * 1.2)   -- 20% buffer
    local soulThreshold = isPercentMode and 10 or (boltDmg * 0.5) -- Very low, finish with DS

    if (isPercentMode and hpPercent < 33) or (not isPercentMode and hpVal < (sbDmg * 2)) then
        -- Shadowburn: If in kill range, have shards, not on CD
        local inRange = (isPercentMode and hpPercent <= 25) or (hpVal <= execThreshold)
        if inRange then
            local shards = 0
            for b = 0, 4 do
                for s = 1, GetContainerNumSlots(b) do
                    local l = GetContainerItemLink(b, s)
                    if l and string.find(l, "item:6265") then shards = shards + 1 end
                end
            end
            if shards > 0 and (not WD_Track["SB"] or (tm - WD_Track["SB"]) > 15) then
                WD_Track["SB"] = tm
                return "Shadowburn", "kill", (prio >= 2 and 105 or 45)
            end
        end
        -- Drain Soul if very low (to get shard)
        local inSoulRange = (isPercentMode and hpPercent <= 15) or
            (hpVal <= soulThreshold * 3) -- e.g. < 1.5 Shadow Bolts
        if inSoulRange then
            return "Drain Soul", "kill", (prio >= 2 and 90 or 30)
        end
    end

    if pMana < 35 and UnitPowerType(u) == 0 and UnitMana(u) > 0 then
        return "Drain Mana", "kill", (prio >= 2 and 85 or 25)
    end

    -- 2. DOTS & CURSES
    -- Check Malediction (free Agony if using other curses)
    local hasMalediction = ScriptExtender_HasTalent("Malediction")
    local hasSiphonLife = ScriptExtender_HasTalent("Siphon Life")

    -- Data for HP thresholds
    -- Data for HP thresholds (already calculated above)
    -- local hpMax = UnitHealthMax(u)
    -- local isPercent = (hpMax == 100)

    -- Estimate Damage Thresholds
    -- We use Shadow Bolt as a baseline "Nuke" Unit
    local boltDmg = ScriptExtender_GetSpellDamage("Shadow Bolt")
    if boltDmg == 0 then boltDmg = 50 end -- Fallback
    local siphonDmg = ScriptExtender_GetSpellDamage("Siphon Life")
    if siphonDmg == 0 then siphonDmg = 150 end

    -- Threshold for "Enemy is Low" (Anti-flee / Finish)
    -- If using %. use 25%. If using Real HP, use ~2.5 Shadow Bolts worth of HP?
    -- Actually, CoR is valid when they *start* running which is usually ~20%.
    -- But putting it earlier ensures it covers the flee threshold (usually 10-15%).
    -- 2.5 bolts ~ 10-15 seconds of combat maybe? No, 2.5 bolts is fast.
    -- Let's say Threshold = 20% or 2.5 * BoltDmg.
    local lowHpThreshold = isPercentMode and 25 or (boltDmg * 2.5)

    -- Determine preferred curse
    local curseToUse = "Curse of Agony"
    local curseTex = "CurseOfSargeras"
    local curseDur = 24

    if hasMalediction then
        -- Decision Logic: Elements vs Recklessness
        -- CoE: High HP targets (Elites), or casting Fire spells (Immolate is in DoT list)
        -- CoR (Rank 1): Low HP (Anti-flee), or Physical boost (Pet/Group)

        -- If mob has very high HP (> 80%) OR we have a Mage/Destro lock, prefer Elements
        -- For now, default to Rank 1 Recklessness for efficiency + armor reduce

        if hp < lowHpThreshold then
            -- Anti-flee / Low HP Execution phase
            curseToUse = "Curse of Recklessness (Rank 1)"
            curseTex = "CurseOfRecklessness"
            curseDur = 120
        else
            -- Default to Elements if we use Fire, or Recklessness for physical.
            -- User requested Downranked Recklessness.
            curseToUse = "Curse of Recklessness (Rank 1)"
            curseTex = "CurseOfRecklessness"
            curseDur = 120
        end

        -- Texture override for checking if it's up
        -- We need to check if *our chosen curse* is up.
        -- If we use CoR, we check for CoR.
    end

    -- Estimate DoT Damages for "One DoT Kill" logic
    local agonyDmg = ScriptExtender_GetSpellDamage("Curse of Agony")
    if agonyDmg == 0 then agonyDmg = 84 end -- Rank 1 fallback
    local corrDmg = ScriptExtender_GetSpellDamage("Corruption")
    if corrDmg == 0 then corrDmg = 40 end   -- Rank 1 fallback

    local killerDotActive = false

    -- Process DoTs
    for x, s in ipairs(DoTs) do
        -- If a DoT is already doing enough damage to kill, stop casting new ones.
        if killerDotActive then break end

        local castName = s      -- The spell we intend to cast
        local trackTex = Tex[x] -- The texture we look for to verify it's up
        local duration = Dur[x] -- The duration we track
        local skipCast = false

        -- Filter: Siphon Life
        if s == "Siphon Life" then
            if not hasSiphonLife then
                -- Skip if we don't have the talent
                skipCast = true
            else
                -- Conditions: High HP (Not dying soon), and worth it?
                -- User: "enemies with a lot of health left" ... "prio on bosses"
                -- Avoid on mobs that are killed way faster.
                -- Threshold: HP > 4x Bolt? Or HP > 800?
                -- Let's use: Not a "Short" target.
                local isShortFight = (hpVal < (boltDmg * 6))              -- Arbitrary: > 6 bolts to kill is "Long"
                if isPercentMode then isShortFight = (hpPercent < 50) end -- Rough estimate for % mode

                local classif = UnitClassification(u)
                if classif == "worldboss" or classif == "elite" or classif == "rareelite" then
                    isShortFight = false
                end

                if isShortFight then
                    skipCast = true -- Skip Siphon Life on small mobs
                end
            end
        end

        if not skipCast then -- proceeding only if not skipped
            -- Logic Swap for Curse Slot
            local isCurseSlot = (s == "Curse of Agony")
            local maledictionActive = false

            if isCurseSlot then
                if hasMalediction then
                    castName = curseToUse -- Swap Agony for CoR/CoE
                    maledictionActive = true
                    -- We KEEP 'trackTex' as "CurseOfSargeras" (Agony) because Malediction applies Agony
                    -- We change duration to 24s effectively because we want to refresh Agony
                end
            end

            local k = n .. trackTex
            local last = WD_Track[k] or 0
            local elapsed = tm - last

            -- Timer Check:
            -- Standard: Refresh within 2s of falling off
            local tmr = (last > 0 and elapsed < (duration - 2))

            local hasDot = ScriptExtender_HasDebuff(u, trackTex)

            -- SPECIAL CASING FOR MALEDICTION:
            -- If we are using Malediction, we track Agony Texture (CurseOfSargeras).
            -- BUT, we also need to respect that our "castName" (Curse of Recklessness) might ALREADY be up.
            -- However, user requirement is: "if it doesnt find curse of agony it always uses curse of recklessness to refresh it"

            -- So, if Agony (trackTex) is MISSING, we must set hasDot = false, preventing any "skip because present" logic.
            -- AND we must ensure that we don't skip just because we cast it recently (unless very recently, e.g. < 3s GCD safety).
            -- The standard 'hasDot' check handles the texture presence.

            -- If Agony is missing (hasDot is false), we proceed to cast 'castName' (CoR/CoE).
            -- This effectively refreshes Agony.

            -- Is there a risk we recast CoR while CoR is up?
            -- Yes, but that is INTENDED to refresh Agony.
            -- "unless the other curse it wants to cast is out" -> No, user says "use that curse to refresh".

            if last > 0 and elapsed < 3 then hasDot = true end -- Anti-spam safety

            -- Calculate if this DoT is a "Killer"
            local thisDotDmg = 0
            if isCurseSlot then
                thisDotDmg = agonyDmg -- Even if casting CoR, source is Agony
            elseif s == "Corruption" then
                thisDotDmg = corrDmg
            elseif s == "Siphon Life" then
                thisDotDmg = siphonDmg
            end

            if hasDot then
                -- Check if remaining damage is enough to kill
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

            -- Do not cast Long DoTs if target is about to die
            local isLongDoT = (duration > 15)
            local timeToDieShort = (hpVal < boltDmg)

            if isLongDoT and timeToDieShort and not string.find(castName, "Recklessness") then
                -- Skip casting full Agony/Immolate if mob is 1-shot by a bolt
            elseif not hasDot then
                -- Single DoT Kill Logic Check
                local wouldKill = (thisDotDmg > hpVal)

                if not tmr then
                    local score = (prio >= 2 and 80 or 20)

                    -- Optimization: Only prioritize "One DoT Kill" on significantly lower-level mobs
                    -- Formula: TargetLevel <= Min(PlayerLevel / 2, PlayerLevel - 10)
                    -- Ensures we prio the "biggest level diff" requirement (either 10 levels or half, whichever is stricter).

                    local pLvl = UnitLevel("player")
                    local tLvl = UnitLevel(u)
                    if tLvl == -1 then tLvl = pLvl + 3 end -- Treat bosses as high level

                    local maxTargetLevel = math.min((pLvl * 0.5), (pLvl - 10))

                    local isLowLevel = (tLvl > 0) and (tLvl <= maxTargetLevel)

                    if wouldKill and isLowLevel then
                        score = score + 50
                    end
                    -- Boost Siphon Life on Elite/Boss
                    if s == "Siphon Life" and prio >= 3 then score = score + 20 end
                    return castName, "dot", score
                end
            end
        end
    end

    -- 3. FILLER
    local action = (pHp < 60 and "Drain Life" or "Drain Soul")
    local fillScore = (prio >= 2 and 60 or 10)
    return action, "fill", fillScore
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
        -- Update Curse of Agony slot (Index 1)
        WD_Track[n .. Tex[1]] = tm
    end
end
