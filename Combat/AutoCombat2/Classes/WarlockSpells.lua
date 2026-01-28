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
        sameRangeAs = "Shadow Bolt",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            if mob.myDebuffs["Corruption"] then return 0 end
            if mob.hpPct < 20 and mob.classification == "normal" then return 0 end

            local score = 60
            if mob.classification == "elite" or mob.classification == "worldboss" then
                score = score + 30
            end
            return score
        end
    },

    -- 2. IMMOLATE (DoT + Direct)
    ["Immolate"] = {
        sameRangeAs = "Shadow Bolt",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            if mob.myDebuffs["Immolate"] then return 0 end
            if mob.hpPct < 30 then return 10 end

            return 50
        end
    },

    -- 3. CURSE OF AGONY (DoT)
    ["Curse of Agony"] = {
        sameRangeAs = "Shadow Bolt",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            if mob.myDebuffs["Curse of Agony"] then return 0 end

            if mob.hpPct < 25 and mob.classification == "normal" then return 0 end

            local score = 65
            if mob.classification == "elite" then score = score + 20 end
            return score
        end
    },

    -- 4. SIPHON LIFE (DoT / Multi-Target Healing)
    ["Siphon Life"] = {
        sameRangeAs = "Shadow Bolt",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end
            if not ScriptExtender_TalentCache.HasTalent("Siphon Life") then return 0 end
            if mob.myDebuffs["Siphon Life"] then return 0 end

            -- Scoring: Great for long fights (Toughness > 2)
            local score = 55
            if mob.toughness > 3 or mob.classification == "elite" then
                score = score + 20
            end

            -- Lower priority if the mob is about to die
            if mob.hpPct < 25 and mob.classification == "normal" then return 0 end

            return score
        end
    },

    -- 5. CURSE OF RECKLESSNESS (Utility/Hybrid)
    ["Curse of Recklessness"] = {
        sameRangeAs = "Shadow Bolt",
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
        sameRangeAs = "Shadow Bolt",
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
            elseif mob.toughness < 1.5 then
                -- Low Toughness Strategy: Reap them fast!
                score = score + 45
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
        sameRangeAs = "Shadow Bolt",
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
        sameRangeAs = "Shadow Bolt",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end

            -- If we need shards, this is top priority
            if mob.hpPct < 20 and ws.context.playerShards < 5 then
                return 90
            end

            -- Bread and Butter: After DoTs are applied, we Drain.
            -- This beats Shadow Bolt (30) as a default filler.
            if mob.myDebuffs["Corruption"] then
                local fillerScore = 45
                if mob.myDebuffs["Curse of Agony"] or mob.myDebuffs["Siphon Life"] then
                    fillerScore = 55
                end
                return fillerScore
            end

            -- Default low priority
            return 10
        end
    },

    -- 8. SHADOW BOLT (Nightfall / Backup Filler)
    ["Shadow Bolt"] = {
        sameRangeAs = "Shadow Bolt",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end

            -- Nightfall Proc (Optimization) - Texture: Spell_Shadow_Twilight
            if ws.context.playerBuffs["Interface\\Icons\\Spell_Shadow_Twilight"] then
                return 200 -- INSTANT CAST!
            end

            -- Filler score
            local score = 30
            if mob.hpPct < 30 then
                score = score + 40
            end
            return score
        end
    },

    -- 9. LIFE TAP (Resource)
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
