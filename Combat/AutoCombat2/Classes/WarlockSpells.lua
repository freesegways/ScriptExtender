-- Combat/AutoCombat2/Classes/WarlockSpells.lua
-- Scoring logic for Warlock abilities.

if ScriptExtender_WarlockSpells then return end

ScriptExtender_WarlockSpells = {
    -- 1. CORRUPTION (DoT)
    -- Priority: High on high HP mobs, higher with more mobs (multi-dotting)
    ["Corruption"] = {
        sameRangeAs = "Shadow Bolt",
        target = "enemy",
        score = function(mob, ws, player)
            -- 1. Already applied?
            if mob.myDebuffs["Corruption"] then return 0 end

            -- 2. Range Check (handled by Analyzer usually, but good to have fallback/check if needed)
            -- For scoring, we assume Analyzer filters out-of-range, OR we check range buckets.
            -- Using rangeBucket 3 (Far) is usually fine for max range spells.

            -- 3. Logic
            -- Don't dot low HP trash (waste of mana)
            if mob.hpPct < 20 and mob.classification == "normal" then return 0 end

            -- Base Score
            local score = 60

            -- Bonus: High HP (Boss/Elite)
            if mob.classification == "elite" or mob.classification == "worldboss" then
                score = score + 30
            end

            -- Bonus: Multi-target (encourage spreading)
            -- If we are in "Multi-Target Mode", spreading Corruption is top priority
            -- (Scanner should probably calculate 'isMultiTarget')
            -- For now, purely based on Mob.

            return score
        end
    },

    -- 2. IMMOLATE (DoT + Direct)
    -- Priority: High on new targets, good for damage
    ["Immolate"] = {
        sameRangeAs = "Shadow Bolt",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.myDebuffs["Immolate"] then return 0 end
            if mob.hpPct < 30 then return 10 end -- Just nuke with SB instead usually

            return 50                            -- Standard priority below Corruption
        end
    },

    -- 3. SHADOW BOLT (Filler)
    -- Priority: Default filler. Increases as mob gets lower (Execute feel)
    ["Shadow Bolt"] = {
        sameRangeAs = "Shadow Bolt",
        target = "enemy",
        score = function(mob, ws, player)
            -- Filler score
            local score = 30

            -- Execute-ish preference (finish them off)
            if mob.hpPct < 30 then
                score = score + 40
            end

            -- Nightfall check could go here if we tracked buffs

            return score
        end
    },

    -- 4. FEAR (CC)
    -- Priority: Emergency self-defense or control
    ["Fear"] = {
        sameRangeAs = "Fear",
        target = "enemy",
        score = function(mob, ws, player)
            if mob.debuffs.hasCC then return 0 end

            -- Only fear if:
            -- 1. Attacking Me (Emergency)
            -- 2. Uncontrolled add (Context)

            if mob.target == player.name and player.hpPct < 50 then
                return 100 -- EMERGENCY
            end

            return 0
        end
    },

    -- 5. LIFE TAP (Mana Gen)
    -- Target: Player
    ["Life Tap"] = {
        sameRangeAs = nil, -- Self
        target = "player",
        score = function(mob, ws, player)
            -- Check HP safety
            if player.hpPct < 40 then return 0 end

            -- Only tap if mana is low
            if player.manaPct < 60 then
                -- Score scales with how desperate we are
                local missingManaScore = (100 - player.manaPct)
                return missingManaScore -- 40 to 100
            end

            return 0
        end
    }
}
