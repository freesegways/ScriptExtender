ScriptExtender_Tests["WarlockAnalyze_MultiWarlock"] = function(t)
    -- Verify Multi-Warlock Reconciliation Logic using Count comparisons.

    local UNIT_NAME = "Mob"

    -- Mock Data
    local debuffs = {}      -- List of textures
    local numParty = 0
    local partyClasses = {} -- party1=Warlock, etc.

    -- Mocks
    t.Mock("UnitName", function(u) return UNIT_NAME end)
    t.Mock("UnitHealth", function() return 2000 end)
    t.Mock("UnitHealthMax", function() return 2000 end)
    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitIsDead", function() return false end)
    t.Mock("UnitIsFriend", function() return false end)
    t.Mock("UnitAffectingCombat", function() return true end)
    t.Mock("UnitPowerType", function() return 0 end)
    t.Mock("UnitMana", function() return 1000 end)
    t.Mock("UnitManaMax", function() return 1000 end)
    t.Mock("UnitClassification", function() return "normal" end) -- Usually solo grinding logic applies
    t.Mock("ScriptExtender_GetSpellDamage", function() return 100 end)
    t.Mock("UnitLevel", function() return 60 end)
    t.Mock("GetSpellCooldown", function() return 0, 0, 1 end)
    t.Mock("GetRaidTargetIndex", function() return 0 end)

    -- Mock Tracking
    local activeDebuffs = {} -- Tracked Debuffs

    t.Mock("ScriptExtender_GetCombatContext", function(u)
        return {
            targetHP = 2000,
            targetMaxHP = 2000,
            targetHPPct = 100,
            playerManaPct = 100,
            playerHPPct = 100,
            isBoss = false,
            range = 10,
            trackedDebuffs = activeDebuffs,
            pseudoID = u
        }
    end)

    t.Mock("ScriptExtender_IsDebuffTracked", function(u, s)
        return activeDebuffs[s] or false
    end)

    -- Mock Spells (Whitelist)
    t.Mock("ScriptExtender_IsSpellLearned", function(n)
        if n == "Corruption" then return true end
        if n == "Shadow Bolt" then return true end
        if n == "Life Tap" then return true end
        if n == "Shoot" then return true end
        if n == "Immolate" then return false end -- Disable Immolate to prioritize Corruption
        return false                             -- Block Everything Else (CoE, Agony, etc)
    end)

    t.Mock("ScriptExtender_IsSpellReady", function(n) return true end)

    t.Mock("ScriptExtender_HasTalent", function(n)
        return false -- No talents (Malediction etc)
    end)

    -- Mock ClassDebuffs (Needed by HasDebuffMatch)
    ScriptExtender_ClassDebuffs = {
        Warlock = {
            ["Corruption"] = { texture = "Abomination", stackable = true },
            ["Curse of Agony"] = { texture = "CurseOfSargeras", stackable = true }
        }
    }

    -- Mock GetClassCount
    ScriptExtender_GetClassCount = function(c)
        if c == "Warlock" then
            -- Logic based on mocked props
            local count = 0
            -- Player is Warlock? (Implicitly yes for this test)
            count = count + 1

            -- Party
            if numParty > 0 then
                for i = 1, numParty do
                    if partyClasses["party" .. i] == "Warlock" then count = count + 1 end
                end
            end
            return count
        end
        return 0
    end

    -- Mock Party/Class for Warlock Count
    t.Mock("GetNumPartyMembers", function() return numParty end)
    t.Mock("GetNumRaidMembers", function() return 0 end)
    t.Mock("UnitClass", function(u)
        return nil, nil, partyClasses[u] or "Warrior"
    end)

    -- Mock Visual Debuffs (For Reconciliation)
    t.Mock("UnitDebuff", function(u, i)
        return debuffs[i]
    end)

    -- Mock Global HasDebuff (Texture Check)
    t.Mock("ScriptExtender_HasDebuff", function(u, texture)
        for _, d in ipairs(debuffs) do
            if string.find(d, texture) then return true end
        end
        return false
    end)

    -- TEST 1: SOLO WARLOCK - DESYNC
    -- Tracker Empty. Visual Present.
    -- Should assume it's MINE. HasDebuff=TRUE.
    -- Analyzer should SKIP casting Corruption.

    numParty = 0                -- Solo
    partyClasses = {}
    activeDebuffs = {}          -- Tracker says NO
    debuffs = { "Abomination" } -- Visual says YES (Corruption)

    local act = ScriptExtender_Warlock_Analyze({ unit = "target", allowManualPull = false })
    -- Expect generic Filler (Shadow Bolt/Life Tap/Shoot), NOT Corruption.
    -- Corruption priority is usually high. But skipped if present.
    t.Assert(act ~= "Corruption", "Solo: Should recognize my Corruption via Visual even if Tracker empty.")


    -- TEST 2: TWO WARLOCKS - OTHER'S DOT
    -- Tracker Empty. Visual Present (1x).
    -- Should assume OTHER'S. HasDebuff=FALSE.
    -- Analyzer should CAST Corruption.

    numParty = 1 -- Me + 1 = 2 Members total (Me isn't part of GetNumPartyMembers usually? Wait.)
    -- GetNumPartyMembers returns 1 to 4.
    -- GetWarlockCount logic steps 592:
    -- count = 1 (Self).
    -- loop 1..numParty. If "party"..i is Warlock -> count++.

    numParty = 1
    partyClasses["party1"] = "Warlock" -- Another Warlock

    activeDebuffs = {}
    debuffs = { "Abomination" } -- 1 Instance

    act = ScriptExtender_Warlock_Analyze({ unit = "target", allowManualPull = false })
    t.AssertEqual({ actual = act, expected = "Corruption" })


    -- TEST 3: TWO WARLOCKS - BOTH DOTS
    -- Tracker Empty. Visual Present (2x).
    -- Should assume MINE + OTHER'S. HasDebuff=TRUE.
    -- Analyzer should SKIP Corruption.

    debuffs = { "Abomination", "Abomination" } -- 2 Instances

    act = ScriptExtender_Warlock_Analyze({ unit = "target", allowManualPull = false })
    t.Assert(act ~= "Corruption", "Multi: Should recognize my Corruption if Visual count matches Warlock count.")
end
