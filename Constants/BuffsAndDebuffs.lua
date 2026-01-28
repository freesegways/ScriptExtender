-- Constants/BuffsAndDebuffs.lua
-- Global tables of common buff and debuff textures for CC, immunities, and utility.

-- 1. HARD CC: Debuffs that shouldn't be broken (Partial texture name matches)
ScriptExtender_CCTextures = {
    "Polymorph",                  -- Sheep, Turtle, Pig
    "Sap",                        -- Rogue Sap
    "Banish",                     -- Warlock Banish
    "Sleep",                      -- Druid Hibernation, Sleep
    "Ice",                        -- Freezing Trap, Ice Tomb
    "Manacles",                   -- Golem stuns
    "Ability_Gouge",              -- Rogue Gouge
    "Ability_Blind",              -- Rogue Blind
    "Ability_GolemThunderClap",   -- Scatter Shot
    "Ability_Hunter_CriticalShot" -- Wyvern Sting
}

-- 2. IMMUNITIES: Buffs that make the target immune/invulnerable
ScriptExtender_ImmuneTextures = {
    "Spell_Holy_DivineIntervention", -- Divine Shield (Paladin)
    "Spell_Holy_Restoration",        -- Divine Protection (Paladin)
    "Spell_Shadow_PhaseShift",       -- Phase Shift (Imp)
    "Spell_Frost_Frost",             -- Ice Block (Mage)
    "Spell_Shadow_Teleport",         -- Banish (Self/Other)
    "Spell_Holy_SealOfProtection",   -- Blessing of Protection (Phys Immune)
    "Ability_FistOfJustice"          -- Sometimes used for invuln frames
}

-- 3. STUNS: Hard control that isn't broken by damage (usually)
ScriptExtender_StunTextures = {
    "Spell_Holy_HammerOfJustice",
    "Ability_CheapShot",
    "Ability_Rogue_KidneyShot",
    "Ability_Warrior_Charge",
    "Ability_Warrior_Intercept",
    "Ability_Druid_Bash",
    "Ability_WarStomp",
    "Spell_Shadow_GatherShadows", -- Blackout
    "Spell_Fire_SelfDestruct",    -- Impact
    "Ability_Druid_SupriseAttack" -- Pounce
}

-- 4. ROOTS: Prevents movement but allows casting/attacking
ScriptExtender_RootTextures = {
    "Spell_Nature_StrangleVines", -- Entangling Roots
    "Spell_Frost_FrostNova",      -- Mage Frost Nova
    "Spell_Frost_FrostArmor",     -- Frostbite
    "Ability_BullRush",           -- Improved Hamstring
    "Spell_Nature_Web"            -- Spider Web/Generic net
}

-- 5. FEARS: Target runs randomly
ScriptExtender_FearTextures = {
    "Spell_Shadow_Possession",    -- Fear
    "Spell_Shadow_PsychicScream", -- Priest Psychic Scream
    "Spell_Shadow_DeathScream",   -- Howl of Terror
    "Ability_Druid_Cower",        -- Scare Beast
    "Spell_Shadow_DeathCoil"      -- Warlock Death Coil (mobs also use it)
}

-- 6. DEFENSIVES: Buffs that reduce damage but don't grant immunity
ScriptExtender_DefensiveTextures = {
    "Spell_Shadow_AbominationExplosion", -- Shield Wall
    "Spell_Holy_AshesToAshes",           -- Weakened Soul (Dispels check)
    "Spell_Holy_PowerWordShield",        -- Priest Shield
    "Ability_Warrior_LastStand",
    "Spell_Shadow_SacrificialShield",    -- Voidwalker Sacrifice
    "Ability_Rogue_Evasion",
    "Spell_Nature_StoneClawTotem",       -- Barkskin icon is often nature
    "Spell_Nature_EnchantArmor"          -- Barkskin
}

-- 7. SNARES: Movement speed reductions
ScriptExtender_SnareTextures = {
    "Ability_ShockWave",           -- Hamstring
    "Spell_Frost_Wisp",            -- Frostbolt / Chilled
    "Ability_Hunter_WingClip",
    "Ability_Hunter_Pathfinding",  -- Concussive Shot
    "Spell_Fire_SelfDestruct",     -- Blast Wave
    "Spell_Shadow_ShadowWordPain", -- Mind Flay icon is often similar
    "Ability_Hunter_ViperSting"
}

-- 8. CLASS DEBUFFS: Mapping Spell Names to Texture Partials for Debuff Tracking
ScriptExtender_ClassDebuffs = {
    WARLOCK = {
        -- DoTs (Stackable per caster)
        ["Curse of the Elements"] = { texture = "ChillTouch", stackable = false, duration = 300 },     -- 5 min
        ["Curse of Agony"] = { texture = "CurseOfSargeras", stackable = true, duration = 24 },         -- 24s
        ["Corruption"] = { texture = "Abomination", stackable = true, duration = 18 },                 -- 18s
        ["Immolate"] = { texture = "Immolation", stackable = true, duration = 15 },                    -- 15s
        ["Siphon Life"] = { texture = "Requiem", stackable = true, duration = 30 },                    -- 30s
        ["Curse of Recklessness"] = { texture = "UnholyStrength", stackable = false, duration = 120 }, -- 2 min
        ["Curse of Shadow"] = { texture = "CurseOfAchimonde", stackable = false, duration = 300 },     -- 5 min
        ["Fear"] = { texture = "Possession", stackable = false, duration = 20 },                       -- 20s
        ["Banish"] = { texture = "Binder", stackable = false, duration = 30 },                         -- 30s
        ["Drain Life"] = { texture = "LifeDrain", stackable = true, duration = 5 },                    -- Channel 5s
        ["Drain Soul"] = { texture = "Haunt", stackable = true, duration = 15 },                       -- Channel 15s
        ["Shadowburn"] = { texture = "ScourgeBuild", stackable = true, duration = 5 }                  -- Debuff 5s
    },
    PRIEST = {
        ["Shadow Word: Pain"] = { texture = "ShadowWordPain", stackable = true },
        ["Devouring Plague"] = { texture = "BlackPlague", stackable = true } -- Depends on race/CD but typically per caster
    }
    -- Add other classes as needed
}
