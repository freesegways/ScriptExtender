if ScriptExtender_WarlockSpells then return end

-- [[ WARLOCK LOGIC ROADMAP ]]
-- 1. TALENT CACHE: We need a ScriptExtender_TalentCache to track:
--    - Dark Harvest (requires talent check to even attempt)
--    - Nightfall (Shadow Trance buff awareness)
--    - Shadowburn (requires talent check + soul shard)
--    - Malediction (Increases value of CoS/CoR/CoE as they apply Agony too)
-- 2. CURSE STRATEGY:
--    - Malediction allows Rank 1 utility curses (CoR) to apply Max Rank Agony.
--    - Scoring for these curses should be high on new targets.
-- 3. DRAIN SOUL: High priority when mob HP < 20% and Soul Shard count < 5.
-- 4. LIFE TAP: Keep mana high, score scales with missing mana (HP permitting).
-- 5. SAFETY: Skip offensive spells if mob.debuffs.hasCC is true.

ScriptExtender_WarlockSpells = {
    -- 1. CORRUPTION (DoT)
    ["Corruption"] = {
        sameRangeAs = "Drain Soul",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            if mob.myDebuffs["Corruption"] then return 0 end
            if mob.hpPct < 20 and mob.classification == "normal" then return 0 end

            local score = 60
            if mob.classification == "elite" or mob.classification == "worldboss" then
                score = score + 30
            end

            -- Health Scaling: Reduce score on dying mobs
            if mob.hpPct < 30 then
                score = score - (30 - mob.hpPct)
            end

            -- Multi-Target Bonus: Strongly prioritize spreading Corruption if 2+ mobs exist
            -- Scale with threat: Don't spread too aggressively on tiny trash
            if ws.aggregations.mobCount > 1 then
                local aggTough = ws.aggregations.aggregateToughness or 0
                local threatBonus = 25
                if aggTough < 2.5 then threatBonus = 10 end -- Reduce for weaklings

                score = score + threatBonus + (ws.aggregations.mobCount * 10)
            end

            return score
        end
    },

    -- 2. IMMOLATE (DoT + Direct)
    ["Immolate"] = {
        sameRangeAs = "Drain Soul",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            if mob.myDebuffs["Immolate"] then return 0 end

            -- Waste threshold: Don't cast on dying mobs
            if mob.hpPct < 25 and mob.classification == "normal" then return 0 end
            if mob.hpPct < 10 then return 0 end

            local score = 50
            if mob.hpPct < 40 then score = 25 end -- Reduce priority as it nears death

            return score
        end
    },

    -- 3. CURSE OF AGONY (DoT)
    ["Curse of Agony"] = {
        sameRangeAs = "Drain Soul",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            if mob.myDebuffs["Curse of Agony"] then return 0 end

            if mob.hpPct < 25 and mob.classification == "normal" then return 0 end

            local score = 65
            if mob.classification == "elite" then score = score + 20 end

            -- Multi-Target Bonus: Agony is essential for rot pressure on 2+ targets
            if ws.aggregations.mobCount > 1 then
                score = score + 25 + (ws.aggregations.mobCount * 10)
            end

            return score
        end
    },

    -- 4. SIPHON LIFE (DoT / Multi-Target Healing)
    ["Siphon Life"] = {
        sameRangeAs = "Drain Soul",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            if not ScriptExtender_TalentCache.HasTalent("Siphon Life") then return 0 end
            if mob.myDebuffs["Siphon Life"] then return 0 end

            -- Scoring: Great for long fights (Toughness > 3)
            -- Or if we are in a high-threat pack (Aggregate > 5)
            local score = 55
            local aggTough = ws.aggregations.aggregateToughness or 0

            if mob.toughness > 3 or mob.classification == "elite" or aggTough > 5 then
                score = score + 20
            end

            -- Lower priority if the mob is about to die
            if mob.hpPct < 25 and mob.classification == "normal" then return 0 end

            -- Multi-Target Bonus: More Siphons = More Healing
            if ws.aggregations.mobCount > 1 then
                score = score + 15 + (ws.aggregations.mobCount * 5)
            end

            return score
        end
    },

    -- 5. CURSE OF RECKLESSNESS (Utility/Hybrid)
    ["Curse of Recklessness"] = {
        sameRangeAs = "Drain Soul",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            -- If we have Malediction, we can apply max rank Agony via CoR rank 1
            local hasMalediction = ScriptExtender_TalentCache.HasTalent("Malediction")

            if mob.myDebuffs["Curse of Recklessness"] then return 0 end
            if mob.myDebuffs["Curse of Agony"] then return 0 end

            -- In group play, CoR is often required for bosses.
            -- If we have Malediction, it's also a high-value DoT.
            if hasMalediction then
                return 75 -- Beats Agony (65) if we have the talent
            end

            -- Emergency check for runners (usually for low HP humanoids)
            if mob.hpPct < 15 and (mob.creatureType == "Humanoid" or mob.creatureType == "Giant") then
                return 100 -- STOP RUNNING!
            end

            return 0
        end
    },

    -- 5. DARK HARVEST (Finisher & DoT Accelerator)
    ["Dark Harvest"] = {
        sameRangeAs = "Drain Soul",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            if not ScriptExtender_TalentCache.HasTalent("Dark Harvest") then return 0 end

            local score = 35 -- Base value for damage
            local affliDots = 0
            if mob.myDebuffs["Corruption"] then affliDots = affliDots + 1 end
            if mob.myDebuffs["Curse of Agony"] then affliDots = affliDots + 1 end
            if mob.myDebuffs["Unstable Affliction"] then affliDots = affliDots + 1 end
            if mob.myDebuffs["Siphon Life"] then affliDots = affliDots + 1 end

            -- Synergy: Each Affliction DoT makes this spell significantly better (30% faster ticks)
            score = score + (affliDots * 25)

            -- POWER HEURISTIC (Globalized in Scanner)
            if mob.toughness > 3 or mob.classification == "elite" or mob.classification == "worldboss" then
                -- High Value Target: Acceleration provides massive throughput boost
                score = score + 50
            elseif mob.toughness < 1.2 then
                -- Low Toughness Strategy: Only use if heavily dotted (not just Agony) or if finisher
                -- Reduced from +45 to avoid over-committing on weak trash
                if affliDots > 1 then
                    score = score + 10
                end
            end

            -- Finisher Logic: Cooldown resets if they die during channel
            -- Reset potential is extremely valuable regardless of toughness
            if mob.hpPct < 15 and ws.context.playerShards >= 5 then
                score = score + 120
            elseif mob.hpPct < 30 then
                -- Broaden the "Useful as finisher" window
                score = score + 30
            end

            -- Safety: If we lack DoTs, acceleration is wasted.
            if affliDots == 0 and not mob.myDebuffs["Immolate"] then
                return 0 -- Don't waste the cooldown
            end

            return score
        end
    },

    -- 6. SHADOWBURN (Execute)
    ["Shadowburn"] = {
        sameRangeAs = "Drain Soul",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            if not ScriptExtender_TalentCache.HasTalent("Shadowburn") then return 0 end
            if ws.context.playerShards < 1 then return 0 end

            if mob.hpPct < 20 then
                return 95 -- Finish them
            end
            return 0
        end
    },

    -- 7. DRAIN SOUL (Bread and Butter Filler)
    ["Drain Soul"] = {
        sameRangeAs = "Drain Soul",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end

            -- 1. Soul Shard Priority (High)
            if mob.hpPct < 25 and ws.context.playerShards < 5 then
                return 100 -- MUST HAVE SHARDS
            end

            -- 2. Execution / High Value Filler
            if mob.myDebuffs["Corruption"] then
                local score = 45
                if mob.myDebuffs["Curse of Agony"] or mob.myDebuffs["Siphon Life"] then
                    score = score + 10
                end

                -- Health Scaling: Prioritize dying mobs for execution efficiency
                -- Gives +1 to +30 points based on missing health
                score = score + ((100 - mob.hpPct) / 3)

                -- Penalty for Full HP mobs to avoid "Early Draining"
                if mob.hpPct > 90 then score = score - 30 end

                return score
            end

            -- 3. Last Resort Filler
            local p = 10
            if mob.hpPct < 40 then p = p + 10 end
            return p
        end
    },

    -- 8. SHADOW BOLT (Nightfall / Backup Filler)
    ["Shadow Bolt"] = {
        sameRangeAs = "Drain Soul",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end

            -- Nightfall Proc (Optimization) - Texture: Spell_Shadow_Twilight
            if ws.context.playerBuffs["Interface\\Icons\\Spell_Shadow_Twilight"] then
                return 200 -- INSTANT CAST!
            end

            -- Filler score (extremely low to prioritize Wand/Drain/DoTs)
            return 5
        end
    },

    -- 9. DEATH COIL (Panic / Peel)
    ["Death Coil"] = {
        target = "enemy",
        score = function(mob, ws, player)
            -- Formula: Score = (Pressure - Threshold) * Multiplier

            -- 1. Calculate Pressure
            local pressure = (100 - player.hpPct)

            -- Add Positional Threat (Melee + Aggro)
            if mob.target == player.name and mob.rangeBucket == 0 then
                pressure = pressure + 25
            end

            -- 2. Apply Threshold (45)
            if pressure <= 45 then return 0 end

            -- 3. Range Penalty
            local rangeFactor = 1.0
            if mob.rangeBucket == 1 then rangeFactor = 0.5 end -- ~10y (Middle ground)
            if mob.rangeBucket == 2 then rangeFactor = 0.1 end -- ~20y (Rare)
            if mob.rangeBucket == 3 then rangeFactor = 0.0 end -- >30y (Never)

            if rangeFactor == 0 then return 0 end

            -- 4. Apply Multiplier
            return (pressure - 45) * 6 * rangeFactor
        end
    },

    -- 10. LIFE TAP (Resource)
    ["Life Tap"] = {
        target = "player",
        score = function(mob, ws, player)
            if player.hpPct < 40 then return 0 end
            if player.manaPct < 60 then
                local missingManaScore = (100 - player.manaPct)
                -- If we are OOC and mana is low, tap is very high priority
                if not ws.context.inCombat then
                    missingManaScore = missingManaScore + 20
                end
                return missingManaScore
            end
            return 0
        end
    },
}
