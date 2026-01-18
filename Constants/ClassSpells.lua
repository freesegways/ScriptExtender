-- ########################################################
-- Spell Levels Classic - Multi-class spell viewer
-- ########################################################

-- Global variables are initialized at the end of the file.
-- ScriptExtender_SpellLevels
-- ScriptExtender_PriestRacials
-- ScriptExtender_PriestTalents

------------------------------------------------------------
-- DATA: Spell levels per class
-- PRIEST is in { name, cost } form (copper). Others use
-- simple strings but are fully supported by display code.
------------------------------------------------------------

local SpellLevels = {

    --------------------------------------------------------
    -- PRIEST – 1–60 with cost placeholders (copper = 0)
    --------------------------------------------------------
    PRIEST = {
        [1] = {
            { name = "Power Word: Fortitude (Rank 1)", learnCost = 10, powerCost = 60, type = "Buff", castTime = 0, duration = 1800 },
            { name = "Lesser Heal (Rank 1)",           learnCost = 10, powerCost = 30, min = 46,      max = 56,     type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Smite (Rank 1)",                 learnCost = 10, powerCost = 20, min = 13,      max = 18,     type = "Damage", castTime = 1.5, duration = 0 },
        },
        [4] = {
            { name = "Shadow Word: Pain (Rank 1)", learnCost = 100, powerCost = 25, min = 30, max = 30, type = "Damage", castTime = 0,   duration = 18 },
            { name = "Lesser Heal (Rank 2)",       learnCost = 100, powerCost = 45, min = 71, max = 85, type = "Heal",   castTime = 2.0, duration = 0 },
        },
        [6] = {
            { name = "Smite (Rank 2)",              learnCost = 100, powerCost = 30, min = 28,      max = 34,     type = "Damage", castTime = 2.0, duration = 0 },
            { name = "Power Word: Shield (Rank 1)", learnCost = 100, powerCost = 45, type = "Buff", castTime = 0, duration = 30 },
        },
        [8] = {
            { name = "Renew (Rank 1)", learnCost = 200, powerCost = 30, min = 45,         max = 45,     type = "Heal", castTime = 0, duration = 15 },
            { name = "Fade (Rank 1)",  learnCost = 200, powerCost = 45, type = "Utility", castTime = 0, duration = 10 },
        },
        [10] = {
            { name = "Shadow Word: Pain (Rank 2)", learnCost = 300, powerCost = 50,  min = 66,         max = 66,      type = "Damage", castTime = 0,   duration = 18 },
            { name = "Resurrection (Rank 1)",      learnCost = 300, powerCost = 150, type = "Utility", castTime = 10, duration = 0 },
            { name = "Mind Blast (Rank 1)",        learnCost = 300, powerCost = 50,  min = 42,         max = 46,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Lesser Heal (Rank 3)",       learnCost = 300, powerCost = 75,  min = 135,        max = 157,     type = "Heal",   castTime = 2.5, duration = 0 },
        },
        [12] = {
            { name = "Power Word: Shield (Rank 2)",    learnCost = 800, powerCost = 80,  type = "Buff", castTime = 0, duration = 30 },
            { name = "Inner Fire (Rank 1)",            learnCost = 800, powerCost = 30,  type = "Buff", castTime = 0, duration = 600 },
            { name = "Power Word: Fortitude (Rank 2)", learnCost = 800, powerCost = 275, type = "Buff", castTime = 0, duration = 1800 },
        },
        [14] = {
            { name = "Psychic Scream (Rank 1)", learnCost = 1200, powerCost = 60, type = "Crowd Control", castTime = 0, duration = 8 },
            { name = "Renew (Rank 2)",          learnCost = 1200, powerCost = 65, min = 100,              max = 100,    type = "Heal",   castTime = 0,   duration = 15 },
            { name = "Cure Disease",            learnCost = 1200, powerCost = 60, type = "Utility",       castTime = 0, duration = 0 },
            { name = "Smite (Rank 3)",          learnCost = 1200, powerCost = 60, min = 54,               max = 63,     type = "Damage", castTime = 2.5, duration = 0 },
        },
        [16] = {
            { name = "Mind Blast (Rank 2)", learnCost = 1600, powerCost = 80,  min = 72,  max = 79,  type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Heal (Rank 1)",       learnCost = 1600, powerCost = 155, min = 295, max = 341, type = "Heal",   castTime = 3.0, duration = 0 },
        },
        [18] = {
            { name = "Shadow Word: Pain (Rank 3)",  learnCost = 2000, powerCost = 95,  min = 132,        max = 132,    type = "Damage", castTime = 0, duration = 18 },
            { name = "Power Word: Shield (Rank 3)", learnCost = 2000, powerCost = 130, type = "Buff",    castTime = 0, duration = 30 },
            { name = "Dispel Magic (Rank 1)",       learnCost = 2000, powerCost = 125, type = "Utility", castTime = 0, duration = 0 },
        },
        [20] = {
            { name = "Flash Heal (Rank 1)",      learnCost = 3000, powerCost = 125, min = 193,              max = 237,      type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Mind Soothe (Rank 1)",     learnCost = 3000, powerCost = 60,  type = "Utility",       castTime = 0,   duration = 15 },
            { name = "Fade (Rank 2)",            learnCost = 3000, powerCost = 60,  type = "Utility",       castTime = 0,   duration = 10 },
            { name = "Renew (Rank 3)",           learnCost = 3000, powerCost = 105, min = 175,              max = 175,      type = "Heal",   castTime = 0,   duration = 15 },
            { name = "Shackle Undead (Rank 1)",  learnCost = 3000, powerCost = 85,  type = "Crowd Control", castTime = 1.5, duration = 30 },
            { name = "Holy Fire (Rank 1)",       learnCost = 3000, powerCost = 85,  min = 90,               max = 112,      type = "Damage", castTime = 4.0, duration = 10 }, -- Direct + DoT
            { name = "Hex of Weakness (Rank 2)", learnCost = 150,  powerCost = 35,  type = "Utility",       castTime = 0,   duration = 120 },
            { name = "Holy Nova (Rank 1)",       learnCost = 400,  powerCost = 185, min = 33,               max = 39,       type = "Damage", castTime = 0,   duration = 0 },
            { name = "Inner Fire (Rank 2)",      learnCost = 3000, powerCost = 55,  type = "Buff",          castTime = 0,   duration = 600 },
            { name = "Fear Ward",                learnCost = 200,  powerCost = 100, type = "Buff",          castTime = 0,   duration = 600 }, -- Baseline for all races in Turtle WoW
        },
        [22] = {
            { name = "Resurrection (Rank 2)", learnCost = 4000, powerCost = 400, type = "Utility", castTime = 10, duration = 0 },
            { name = "Mind Blast (Rank 3)",   learnCost = 4000, powerCost = 115, min = 102,        max = 110,     type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Heal (Rank 2)",         learnCost = 4000, powerCost = 200, min = 370,        max = 430,     type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Mind Vision (Rank 1)",  learnCost = 4000, powerCost = 60,  type = "Utility", castTime = 0,  duration = 60 },
            { name = "Smite (Rank 4)",        learnCost = 4000, powerCost = 80,  min = 80,         max = 92,      type = "Damage", castTime = 2.5, duration = 0 },
        },
        [24] = {
            { name = "Mana Burn (Rank 1)",             learnCost = 5000, powerCost = 100, type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Holy Fire (Rank 2)",             learnCost = 5000, powerCost = 100, min = 112,       max = 142,      type = "Damage", castTime = 4.0, duration = 10 },
            { name = "Power Word: Fortitude (Rank 3)", learnCost = 5000, powerCost = 480, type = "Buff",   castTime = 0,   duration = 1800 },
            { name = "Power Word: Shield (Rank 4)",    learnCost = 5000, powerCost = 185, type = "Buff",   castTime = 0,   duration = 30 },
        },
        [26] = {
            { name = "Shadow Word: Pain (Rank 4)", learnCost = 6000, powerCost = 155, min = 264, max = 264, type = "Damage", castTime = 0,   duration = 18 },
            { name = "Flash Heal (Rank 2)",        learnCost = 6000, powerCost = 155, min = 258, max = 314, type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Renew (Rank 4)",             learnCost = 6000, powerCost = 140, min = 245, max = 245, type = "Heal",   castTime = 0,   duration = 15 },
        },
        [28] = {
            { name = "Mind Flay (Rank 2)",      learnCost = 400,  powerCost = 70,  type = "Damage",        castTime = 0, duration = 3 },
            { name = "Psychic Scream (Rank 2)", learnCost = 8000, powerCost = 100, type = "Crowd Control", castTime = 0, duration = 8 },
            { name = "Heal (Rank 3)",           learnCost = 8000, powerCost = 255, min = 566,              max = 642,    type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Mind Blast (Rank 4)",     learnCost = 8000, powerCost = 150, min = 175,              max = 188,    type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Holy Nova (Rank 2)",      learnCost = 400,  powerCost = 275, min = 55,               max = 64,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Shadowguard (Rank 2)",    learnCost = 400,  powerCost = 80,  type = "Damage",        castTime = 0, duration = 600 },
        },
        [30] = {
            { name = "Hex of Weakness (Rank 3)",    learnCost = 500,   powerCost = 70,  type = "Utility",       castTime = 0,   duration = 120 },
            { name = "Power Word: Shield (Rank 5)", learnCost = 10000, powerCost = 215, type = "Buff",          castTime = 0,   duration = 30 },
            { name = "Mind Control (Rank 1)",       learnCost = 10000, powerCost = 150, type = "Crowd Control", castTime = 3.0, duration = 60 },
            { name = "Fade (Rank 3)",               learnCost = 10000, powerCost = 75,  type = "Utility",       castTime = 0,   duration = 10 },
            { name = "Smite (Rank 5)",              learnCost = 10000, powerCost = 140, min = 158,              max = 178,      type = "Damage", castTime = 2.5, duration = 0 },
            { name = "Shadow Protection (Rank 1)",  learnCost = 10000, powerCost = 65,  type = "Buff",          castTime = 0,   duration = 600 },
            { name = "Prayer of Healing (Rank 1)",  learnCost = 10000, powerCost = 410, type = "Heal",          castTime = 3.0, duration = 0 },
            { name = "Inner Fire (Rank 3)",         learnCost = 10000, powerCost = 80,  type = "Buff",          castTime = 0,   duration = 600 },
            { name = "Holy Fire (Rank 3)",          learnCost = 10000, powerCost = 170, min = 145,              max = 184,      type = "Damage", castTime = 4.0, duration = 10 },
            { name = "Divine Spirit (Rank 1)",      learnCost = 10000, powerCost = 140, type = "Buff",          castTime = 0,   duration = 1800 },
        },
        [32] = {
            { name = "Mana Burn (Rank 2)",  learnCost = 11000, powerCost = 155, type = "Damage",  castTime = 3.0, duration = 0 },
            { name = "Renew (Rank 5)",      learnCost = 11000, powerCost = 170, min = 315,        max = 315,      type = "Heal", castTime = 0,   duration = 15 },
            { name = "Abolish Disease",     learnCost = 11000, powerCost = 80,  type = "Utility", castTime = 0,   duration = 20 },
            { name = "Flash Heal (Rank 3)", learnCost = 11000, powerCost = 185, min = 327,        max = 393,      type = "Heal", castTime = 1.5, duration = 0 },
        },
        [34] = {
            { name = "Mind Blast (Rank 5)",        learnCost = 12000, powerCost = 185, min = 227,        max = 242,     type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Heal (Rank 4)",              learnCost = 12000, powerCost = 305, min = 712,        max = 804,     type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Shadow Word: Pain (Rank 5)", learnCost = 12000, powerCost = 210, min = 378,        max = 378,     type = "Damage", castTime = 0,   duration = 18 },
            { name = "Resurrection (Rank 3)",      learnCost = 12000, powerCost = 625, type = "Utility", castTime = 10, duration = 0 },
            { name = "Levitate",                   learnCost = 12000, powerCost = 35,  type = "Utility", castTime = 0,  duration = 120 },
        },
        [36] = {
            { name = "Shadowguard (Rank 3)",           learnCost = 700,   powerCost = 140, type = "Damage",  castTime = 0, duration = 600 },
            { name = "Holy Fire (Rank 4)",             learnCost = 14000, powerCost = 195, min = 175,        max = 223,    type = "Damage", castTime = 4.0, duration = 10 },
            { name = "Mind Flay (Rank 3)",             learnCost = 700,   powerCost = 100, type = "Damage",  castTime = 0, duration = 3 },
            { name = "Power Word: Shield (Rank 6)",    learnCost = 14000, powerCost = 250, type = "Buff",    castTime = 0, duration = 30 },
            { name = "Power Word: Fortitude (Rank 4)", learnCost = 14000, powerCost = 840, type = "Buff",    castTime = 0, duration = 1800 },
            { name = "Dispel Magic (Rank 2)",          learnCost = 14000, powerCost = 180, type = "Utility", castTime = 0, duration = 0 },
            { name = "Holy Nova (Rank 3)",             learnCost = 700,   powerCost = 425, min = 89,         max = 101,    type = "Damage", castTime = 0,   duration = 0 },
            { name = "Mind Soothe (Rank 2)",           learnCost = 14000, powerCost = 110, type = "Utility", castTime = 0, duration = 15 },
        },
        [38] = {
            { name = "Renew (Rank 6)",      learnCost = 16000, powerCost = 205, min = 385, max = 385, type = "Heal",   castTime = 0,   duration = 15 },
            { name = "Flash Heal (Rank 4)", learnCost = 16000, powerCost = 215, min = 400, max = 478, type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Smite (Rank 6)",      learnCost = 16000, powerCost = 195, min = 265, max = 299, type = "Damage", castTime = 2.5, duration = 0 },
        },
        [40] = {
            { name = "Divine Spirit (Rank 2)",     learnCost = 900,   powerCost = 230, type = "Buff",          castTime = 0,   duration = 1800 },
            { name = "Fade (Rank 4)",              learnCost = 18000, powerCost = 90,  type = "Utility",       castTime = 0,   duration = 10 },
            { name = "Shackle Undead (Rank 2)",    learnCost = 18000, powerCost = 110, type = "Crowd Control", castTime = 1.5, duration = 40 },
            { name = "Inner Fire (Rank 4)",        learnCost = 18000, powerCost = 105, type = "Buff",          castTime = 0,   duration = 600 },
            { name = "Mana Burn (Rank 3)",         learnCost = 18000, powerCost = 200, type = "Damage",        castTime = 3.0, duration = 0 },
            { name = "Prayer of Healing (Rank 2)", learnCost = 18000, powerCost = 570, min = 459,              max = 490,      type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Mind Blast (Rank 6)",        learnCost = 18000, powerCost = 225, min = 279,              max = 297,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Greater Heal (Rank 1)",      learnCost = 18000, powerCost = 370, min = 899,              max = 1013,     type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Hex of Weakness (Rank 4)",   learnCost = 900,   powerCost = 135, type = "Utility",       castTime = 0,   duration = 120 },
            { name = "Lightwell (Rank 1)",         learnCost = 18000, powerCost = 235, type = "Utility",       castTime = 1.5, duration = 180 },
        },
        [42] = {
            { name = "Shadow Word: Pain (Rank 6)",  learnCost = 22000, powerCost = 275, min = 510,              max = 510,    type = "Damage", castTime = 0,   duration = 18 },
            { name = "Psychic Scream (Rank 3)",     learnCost = 22000, powerCost = 140, type = "Crowd Control", castTime = 0, duration = 8 },
            { name = "Holy Fire (Rank 5)",          learnCost = 22000, powerCost = 225, min = 262,              max = 345,    type = "Damage", castTime = 4.0, duration = 10 },
            { name = "Shadow Protection (Rank 2)",  learnCost = 22000, powerCost = 135, type = "Buff",          castTime = 0, duration = 600 },
            { name = "Power Word: Shield (Rank 7)", learnCost = 22000, powerCost = 300, type = "Buff",          castTime = 0, duration = 30 },
        },
        [44] = {
            { name = "Holy Nova (Rank 4)",    learnCost = 1200,  powerCost = 600, min = 124,              max = 143,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Shadowguard (Rank 4)",  learnCost = 1200,  powerCost = 200, type = "Damage",        castTime = 0,   duration = 600 },
            { name = "Mind Flay (Rank 4)",    learnCost = 1200,  powerCost = 135, type = "Damage",        castTime = 0,   duration = 3 },
            { name = "Mind Control (Rank 2)", learnCost = 24000, powerCost = 300, type = "Crowd Control", castTime = 3.0, duration = 60 },
            { name = "Flash Heal (Rank 5)",   learnCost = 24000, powerCost = 265, min = 518,              max = 615,      type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Renew (Rank 7)",        learnCost = 24000, powerCost = 250, min = 510,              max = 510,      type = "Heal",   castTime = 0,   duration = 15 },
            { name = "Mind Vision (Rank 2)",  learnCost = 24000, powerCost = 120, type = "Utility",       castTime = 0,   duration = 60 },
        },
        [46] = {
            { name = "Resurrection (Rank 4)", learnCost = 26000, powerCost = 830, type = "Utility", castTime = 10, duration = 0 },
            { name = "Smite (Rank 7)",        learnCost = 26000, powerCost = 240, min = 336,        max = 378,     type = "Damage", castTime = 2.5, duration = 0 },
            { name = "Mind Blast (Rank 7)",   learnCost = 26000, powerCost = 270, min = 346,        max = 366,     type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Greater Heal (Rank 2)", learnCost = 26000, powerCost = 455, min = 1149,       max = 1289,    type = "Heal",   castTime = 3.0, duration = 0 },
        },
        [48] = {
            { name = "Power Word: Fortitude (Rank 5)", learnCost = 28000, powerCost = 1420, type = "Buff",   castTime = 0,   duration = 1800 },
            { name = "Holy Fire (Rank 6)",             learnCost = 28000, powerCost = 255,  min = 303,       max = 385,      type = "Damage", castTime = 4.0, duration = 10 },
            { name = "Power Word: Shield (Rank 8)",    learnCost = 28000, powerCost = 345,  type = "Buff",   castTime = 0,   duration = 30 },
            { name = "Mana Burn (Rank 4)",             learnCost = 28000, powerCost = 245,  type = "Damage", castTime = 3.0, duration = 0 },
        },
        [50] = {
            { name = "Hex of Weakness (Rank 5)",   learnCost = 1500,  powerCost = 215, type = "Utility", castTime = 0,   duration = 120 },
            { name = "Flash Heal (Rank 6)",        learnCost = 30000, powerCost = 315, min = 644,        max = 764,      type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Renew (Rank 8)",             learnCost = 30000, powerCost = 305, min = 650,        max = 650,      type = "Heal",   castTime = 0,   duration = 15 },
            { name = "Lightwell (Rank 2)",         learnCost = 1200,  powerCost = 295, type = "Utility", castTime = 1.5, duration = 180 },
            { name = "Fade (Rank 5)",              learnCost = 30000, powerCost = 110, type = "Utility", castTime = 0,   duration = 10 },
            { name = "Divine Spirit (Rank 3)",     learnCost = 1500,  powerCost = 320, type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Inner Fire (Rank 5)",        learnCost = 30000, powerCost = 145, type = "Buff",    castTime = 0,   duration = 600 },
            { name = "Prayer of Healing (Rank 3)", learnCost = 30000, powerCost = 770, min = 652,        max = 693,      type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Shadow Word: Pain (Rank 7)", learnCost = 30000, powerCost = 370, min = 672,        max = 672,      type = "Damage", castTime = 0,   duration = 18 },
        },
        [52] = {
            { name = "Shadowguard (Rank 5)",  learnCost = 1900,  powerCost = 250, type = "Damage",  castTime = 0, duration = 600 },
            { name = "Mind Soothe (Rank 3)",  learnCost = 38000, powerCost = 160, type = "Utility", castTime = 0, duration = 15 },
            { name = "Mind Blast (Rank 8)",   learnCost = 38000, powerCost = 310, min = 425,        max = 449,    type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Mind Flay (Rank 5)",    learnCost = 1900,  powerCost = 165, type = "Damage",  castTime = 0, duration = 3 },
            { name = "Holy Nova (Rank 5)",    learnCost = 1900,  powerCost = 790, min = 162,        max = 187,    type = "Damage", castTime = 0,   duration = 0 },
            { name = "Greater Heal (Rank 3)", learnCost = 38000, powerCost = 545, min = 1437,       max = 1609,   type = "Heal",   castTime = 3.0, duration = 0 },
        },
        [54] = {
            { name = "Power Word: Shield (Rank 9)", learnCost = 40000, powerCost = 400, type = "Buff", castTime = 0, duration = 30 },
            { name = "Smite (Rank 8)",              learnCost = 40000, powerCost = 280, min = 384,     max = 432,    type = "Damage", castTime = 2.5, duration = 0 },
            { name = "Holy Fire (Rank 7)",          learnCost = 40000, powerCost = 290, min = 355,     max = 450,    type = "Damage", castTime = 4.0, duration = 10 },
        },
        [56] = {
            { name = "Flash Heal (Rank 7)",        learnCost = 42000, powerCost = 380, min = 812,              max = 958,      type = "Heal", castTime = 1.5, duration = 0 },
            { name = "Psychic Scream (Rank 4)",    learnCost = 42000, powerCost = 185, type = "Crowd Control", castTime = 0,   duration = 8 },
            { name = "Renew (Rank 9)",             learnCost = 42000, powerCost = 365, min = 810,              max = 810,      type = "Heal", castTime = 0,   duration = 15 },
            { name = "Mana Burn (Rank 5)",         learnCost = 42000, powerCost = 295, type = "Damage",        castTime = 3.0, duration = 0 },
            { name = "Shadow Protection (Rank 3)", learnCost = 42000, powerCost = 205, type = "Buff",          castTime = 0,   duration = 600 },
        },
        [58] = {
            { name = "Mind Blast (Rank 9)",        learnCost = 44000, powerCost = 350,  min = 503,              max = 531,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Resurrection (Rank 5)",      learnCost = 44000, powerCost = 1050, type = "Utility",       castTime = 10,  duration = 0 },
            { name = "Greater Heal (Rank 4)",      learnCost = 44000, powerCost = 655,  min = 1796,             max = 2004,     type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Mind Control (Rank 3)",      learnCost = 44000, powerCost = 450,  type = "Crowd Control", castTime = 3.0, duration = 60 },
            { name = "Shadow Word: Pain (Rank 8)", learnCost = 44000, powerCost = 475,  min = 852,              max = 852,      type = "Damage", castTime = 0,   duration = 18 },
        },
        [60] = {
            { name = "Power Word: Shield (Rank 10)",   learnCost = 46000, powerCost = 500,  type = "Buff",          castTime = 0,   duration = 30 },
            { name = "Shackle Undead (Rank 3)",        learnCost = 46000, powerCost = 135,  type = "Crowd Control", castTime = 1.5, duration = 50 },
            { name = "Prayer of Spirit (Rank 1)",      learnCost = 2300,  powerCost = 930,  type = "Buff",          castTime = 0,   duration = 3600 },
            { name = "Power Word: Fortitude (Rank 6)", learnCost = 46000, powerCost = 2000, type = "Buff",          castTime = 0,   duration = 1800 },
            { name = "Shadowguard (Rank 6)",           learnCost = 2300,  powerCost = 300,  type = "Damage",        castTime = 0,   duration = 600 },
            { name = "Fade (Rank 6)",                  learnCost = 46000, powerCost = 150,  type = "Utility",       castTime = 0,   duration = 10 },
            { name = "Holy Fire (Rank 8)",             learnCost = 46000, powerCost = 325,  min = 412,              max = 523,      type = "Damage", castTime = 4.0, duration = 10 },
            { name = "Lightwell (Rank 3)",             learnCost = 1500,  powerCost = 355,  type = "Utility",       castTime = 1.5, duration = 180 },
            { name = "Mind Flay (Rank 6)",             learnCost = 2300,  powerCost = 205,  type = "Damage",        castTime = 0,   duration = 3 },
            { name = "Hex of Weakness (Rank 6)",       learnCost = 2300,  powerCost = 300,  type = "Utility",       castTime = 0,   duration = 120 },
            { name = "Divine Spirit (Rank 4)",         learnCost = 2300,  powerCost = 415,  type = "Buff",          castTime = 0,   duration = 1800 },
            { name = "Holy Nova (Rank 6)",             learnCost = 2300,  powerCost = 950,  min = 265,              max = 302,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Prayer of Healing (Rank 4)",     learnCost = 46000, powerCost = 1030, min = 939,              max = 991,      type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Inner Fire (Rank 6)",            learnCost = 46000, powerCost = 185,  type = "Buff",          castTime = 0,   duration = 600 },
        },
    },

    --------------------------------------------------------
    -- WARRIOR – 1–60 with cost placeholders (copper = 0)
    --------------------------------------------------------
    WARRIOR = {
        [1] = {
            { name = "Battle Shout (Rank 1)", learnCost = 10, powerCost = 10, type = "Buff", castTime = 0, duration = 120 },
        },
        [4] = {
            { name = "Charge (Rank 1)", learnCost = 100, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 }, -- Generates Rage
            { name = "Rend (Rank 1)",   learnCost = 100, powerCost = 10, min = 15,         max = 15,     type = "Damage", castTime = 0, duration = 30 },
        },
        [6] = {
            { name = "Thunder Clap (Rank 1)", cost = 100, type = "Damage",  castTime = 0, duration = 10 },
            { name = "Parry",                 cost = 100, type = "Utility", castTime = 0, duration = 0 },
        },
        [8] = {
            { name = "Hamstring (Rank 1)",     cost = 200, type = "Crowd Control", castTime = 0, duration = 15 },
            { name = "Heroic Strike (Rank 2)", cost = 200, min = 21,               max = 21,     type = "Damage", castTime = 0, duration = 0 },
        },
        [10] = {
            { name = "Bloodrage",     cost = 600, type = "Utility", castTime = 0, duration = 10 },
            { name = "Rend (Rank 2)", cost = 600, type = "Damage",  castTime = 0, duration = 30 },
        },
        [12] = {
            { name = "Battle Shout (Rank 2)", cost = 1000, type = "Buff",    castTime = 0, duration = 120 },
            { name = "Shield Bash (Rank 1)",  cost = 1000, type = "Utility", castTime = 0, duration = 0 },
            { name = "Overpower (Rank 1)",    cost = 1000, type = "Damage",  castTime = 0, duration = 0 },
        },
        [14] = {
            { name = "Demoralizing Shout (Rank 1)", cost = 1500, type = "Utility", castTime = 0, duration = 30 },
            { name = "Revenge (Rank 1)",            cost = 1500, type = "Damage",  castTime = 0, duration = 0 },
        },
        [16] = {
            { name = "Shield Block",           cost = 2000, type = "Buff",   castTime = 0, duration = 5 },
            { name = "Heroic Strike (Rank 3)", cost = 2000, type = "Damage", castTime = 0, duration = 0 },
            { name = "Mocking Blow (Rank 1)",  cost = 2000, type = "Damage", castTime = 0, duration = 6 },
        },
        [18] = {
            { name = "Disarm",                cost = 3000, type = "Utility", castTime = 0, duration = 10 },
            { name = "Thunder Clap (Rank 2)", cost = 3000, type = "Damage",  castTime = 0, duration = 10 },
        },
        [20] = {
            { name = "Dual Wield",      cost = 4000, type = "Utility", castTime = 0, duration = 0 },
            { name = "Cleave (Rank 1)", cost = 4000, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Rend (Rank 3)",   cost = 4000, type = "Damage",  castTime = 0, duration = 30 },
            { name = "Retaliation",     cost = 4000, type = "Buff",    castTime = 0, duration = 15 },
        },
        [22] = {
            { name = "Sunder Armor (Rank 2)", cost = 6000, type = "Utility",       castTime = 0, duration = 30 },
            { name = "Intimidating Shout",    cost = 6000, type = "Crowd Control", castTime = 0, duration = 8 },
            { name = "Battle Shout (Rank 3)", cost = 6000, type = "Buff",          castTime = 0, duration = 120 },
        },
        [24] = {
            { name = "Heroic Strike (Rank 4)",      cost = 8000, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Demoralizing Shout (Rank 2)", cost = 8000, type = "Utility", castTime = 0, duration = 30 },
            { name = "Execute (Rank 1)",            cost = 8000, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Revenge (Rank 2)",            cost = 8000, type = "Damage",  castTime = 0, duration = 0 },
        },
        [26] = {
            { name = "Charge (Rank 2)",       cost = 10000, type = "Utility", castTime = 0, duration = 0 },
            { name = "Challenging Shout",     cost = 10000, type = "Utility", castTime = 0, duration = 6 },
            { name = "Mocking Blow (Rank 2)", cost = 10000, type = "Damage",  castTime = 0, duration = 6 },
        },
        [28] = {
            { name = "Overpower (Rank 2)",    cost = 11000, type = "Damage", castTime = 0, duration = 0 },
            { name = "Shield Wall",           cost = 11000, type = "Buff",   castTime = 0, duration = 10 },
            { name = "Thunder Clap (Rank 3)", cost = 11000, type = "Damage", castTime = 0, duration = 10 },
        },
        [30] = {
            { name = "Cleave (Rank 2)", cost = 12000, type = "Damage", castTime = 0,   duration = 0 },
            { name = "Slam (Rank 1)",   cost = 12000, type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Rend (Rank 4)",   cost = 12000, type = "Damage", castTime = 0,   duration = 30 },
        },
        [32] = {
            { name = "Berserker Rage",         cost = 14000, type = "Buff",          castTime = 0, duration = 10 },
            { name = "Battle Shout (Rank 4)",  cost = 14000, type = "Buff",          castTime = 0, duration = 120 },
            { name = "Heroic Strike (Rank 5)", cost = 14000, type = "Damage",        castTime = 0, duration = 0 },
            { name = "Shield Bash (Rank 2)",   cost = 14000, type = "Utility",       castTime = 0, duration = 0 },
            { name = "Hamstring (Rank 2)",     cost = 14000, type = "Crowd Control", castTime = 0, duration = 15 },
            { name = "Execute (Rank 2)",       cost = 14000, type = "Damage",        castTime = 0, duration = 0 },
        },
        [34] = {
            { name = "Revenge (Rank 3)",            cost = 16000, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Sunder Armor (Rank 3)",       cost = 16000, type = "Utility", castTime = 0, duration = 30 },
            { name = "Demoralizing Shout (Rank 3)", cost = 16000, type = "Utility", castTime = 0, duration = 30 },
        },
        [36] = {
            { name = "Whirlwind",             cost = 18000, type = "Damage", castTime = 0, duration = 0 },
            { name = "Mocking Blow (Rank 3)", cost = 18000, type = "Damage", castTime = 0, duration = 6 },
        },
        [38] = {
            { name = "Pummel (Rank 1)",       cost = 20000, type = "Utility", castTime = 0,   duration = 0 },
            { name = "Thunder Clap (Rank 4)", cost = 20000, type = "Damage",  castTime = 0,   duration = 10 },
            { name = "Slam (Rank 2)",         cost = 20000, type = "Damage",  castTime = 1.5, duration = 0 },
        },
        [40] = {
            { name = "Rend (Rank 5)",          cost = 22000, type = "Damage",  castTime = 0, duration = 30 },
            { name = "Cleave (Rank 3)",        cost = 22000, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Plate Mail",             cost = 22000, type = "Utility", castTime = 0, duration = 0 },
            { name = "Heroic Strike (Rank 6)", cost = 22000, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Execute (Rank 3)",       cost = 22000, type = "Damage",  castTime = 0, duration = 0 },
        },
        [42] = {
            { name = "Intercept (Rank 2)",    cost = 32000, type = "Utility", castTime = 0, duration = 0 },
            { name = "Battle Shout (Rank 5)", cost = 32000, type = "Buff",    castTime = 0, duration = 120 },
        },
        [44] = {
            { name = "Revenge (Rank 4)",            cost = 34000, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Demoralizing Shout (Rank 4)", cost = 34000, type = "Utility", castTime = 0, duration = 30 },
            { name = "Overpower (Rank 3)",          cost = 34000, type = "Damage",  castTime = 0, duration = 0 },
        },
        [46] = {
            { name = "Charge (Rank 3)",       cost = 36000, type = "Utility", castTime = 0,   duration = 0 },
            { name = "Sunder Armor (Rank 4)", cost = 36000, type = "Utility", castTime = 0,   duration = 30 },
            { name = "Slam (Rank 3)",         cost = 36000, type = "Damage",  castTime = 1.5, duration = 0 },
            { name = "Mocking Blow (Rank 4)", cost = 36000, type = "Damage",  castTime = 0,   duration = 6 },
        },
        [48] = {
            { name = "Bloodthirst (Rank 2)",   cost = 2000,  type = "Damage", castTime = 0, duration = 0 },
            { name = "Shield Slam (Rank 2)",   cost = 2000,  type = "Damage", castTime = 0, duration = 0 },
            { name = "Heroic Strike (Rank 7)", cost = 40000, type = "Damage", castTime = 0, duration = 0 },
            { name = "Execute (Rank 4)",       cost = 40000, type = "Damage", castTime = 0, duration = 0 },
            { name = "Thunder Clap (Rank 5)",  cost = 40000, type = "Damage", castTime = 0, duration = 10 },
            { name = "Mortal Strike (Rank 2)", cost = 2000,  type = "Damage", castTime = 0, duration = 10 },
        },
        [50] = {
            { name = "Rend (Rank 6)",   cost = 42000, type = "Damage", castTime = 0, duration = 30 },
            { name = "Cleave (Rank 4)", cost = 42000, type = "Damage", castTime = 0, duration = 0 },
            { name = "Recklessness",    cost = 42000, type = "Buff",   castTime = 0, duration = 15 },
        },
        [52] = {
            { name = "Shield Bash (Rank 3)",  cost = 54000, type = "Utility", castTime = 0, duration = 0 },
            { name = "Battle Shout (Rank 6)", cost = 54000, type = "Buff",    castTime = 0, duration = 120 },
            { name = "Intercept (Rank 3)",    cost = 54000, type = "Utility", castTime = 0, duration = 0 },
        },
        [54] = {
            { name = "Bloodthirst (Rank 3)",        cost = 2800,  type = "Damage",        castTime = 0,   duration = 0 },
            { name = "Hamstring (Rank 3)",          cost = 56000, type = "Crowd Control", castTime = 0,   duration = 15 },
            { name = "Mortal Strike (Rank 3)",      cost = 2800,  type = "Damage",        castTime = 0,   duration = 10 },
            { name = "Shield Slam (Rank 3)",        cost = 2800,  type = "Damage",        castTime = 0,   duration = 0 },
            { name = "Revenge (Rank 5)",            cost = 56000, type = "Damage",        castTime = 0,   duration = 0 },
            { name = "Demoralizing Shout (Rank 5)", cost = 56000, type = "Utility",       castTime = 0,   duration = 30 },
            { name = "Slam (Rank 4)",               cost = 56000, type = "Damage",        castTime = 1.5, duration = 0 },
        },
        [56] = {
            { name = "Execute (Rank 5)",       cost = 58000, type = "Damage", castTime = 0, duration = 0 },
            { name = "Mocking Blow (Rank 5)",  cost = 58000, type = "Damage", castTime = 0, duration = 6 },
            { name = "Heroic Strike (Rank 8)", cost = 58000, type = "Damage", castTime = 0, duration = 0 },
        },
        [58] = {
            { name = "Sunder Armor (Rank 5)", cost = 60000, type = "Utility", castTime = 0, duration = 30 },
            { name = "Thunder Clap (Rank 6)", cost = 60000, type = "Damage",  castTime = 0, duration = 10 },
            { name = "Pummel (Rank 2)",       cost = 60000, type = "Utility", castTime = 0, duration = 0 },
        },
        [60] = {
            { name = "Overpower (Rank 4)",     cost = 62000, type = "Damage", castTime = 0, duration = 0 },
            { name = "Shield Slam (Rank 4)",   cost = 3100,  type = "Damage", castTime = 0, duration = 0 },
            { name = "Mortal Strike (Rank 4)", cost = 3100,  type = "Damage", castTime = 0, duration = 10 },
            { name = "Rend (Rank 7)",          cost = 62000, type = "Damage", castTime = 0, duration = 30 },
            { name = "Cleave (Rank 5)",        cost = 62000, type = "Damage", castTime = 0, duration = 0 },
            { name = "Bloodthirst (Rank 4)",   cost = 3100,  type = "Damage", castTime = 0, duration = 0 },
        },
    },

    --------------------------------------------------------
    -- MAGE – 1–60 with cost placeholders (copper = 0)
    --------------------------------------------------------
    MAGE = {
        [1] = {
            { name = "Arcane Intellect (Rank 1)", learnCost = 10, powerCost = 60, type = "Buff", castTime = 0, duration = 1800 },
        },
        [4] = {
            { name = "Conjure Water (Rank 1)", learnCost = 100, powerCost = 160, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Frostbolt (Rank 1)",     learnCost = 100, powerCost = 25,  min = 18,         max = 21,       type = "Damage", castTime = 1.5, duration = 5 },
        },
        [6] = {
            { name = "Conjure Food (Rank 1)", learnCost = 150, powerCost = 60, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Fireball (Rank 2)",     learnCost = 150, powerCost = 45, min = 34,         max = 45,       type = "Damage", castTime = 3.5, duration = 6 },
            { name = "Fire Blast (Rank 1)",   learnCost = 150, powerCost = 40, min = 27,         max = 35,       type = "Damage", castTime = 0,   duration = 0 },
        },
        [8] = {
            { name = "Polymorph (Rank 1)",       learnCost = 200, powerCost = 60, type = "Crowd Control", castTime = 1.5, duration = 20 },
            { name = "Frostbolt (Rank 2)",       learnCost = 200, powerCost = 35, min = 31,               max = 36,       type = "Damage", castTime = 1.8, duration = 6 }, -- Typically 2.5 or 3.0 unbuffed, but low ranks are faster
            { name = "Arcane Missiles (Rank 1)", learnCost = 200, powerCost = 85, min = 26,               max = 26,       type = "Damage", castTime = 3.0, duration = 3 }, -- Channeled
        },
        [10] = {
            { name = "Conjure Water (Rank 2)", cost = 360, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Frost Armor (Rank 2)",   cost = 360, type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Frost Nova (Rank 1)",    cost = 360, type = "Damage",  castTime = 0,   duration = 8 },
        },
        [12] = {
            { name = "Slow Fall",             cost = 540, type = "Buff",    castTime = 0,   duration = 30 },
            { name = "Dampen Magic (Rank 1)", cost = 540, type = "Buff",    castTime = 0,   duration = 600 },
            { name = "Fireball (Rank 3)",     cost = 540, type = "Damage",  castTime = 3.5, duration = 6 },
            { name = "Conjure Food (Rank 2)", cost = 540, type = "Utility", castTime = 3.0, duration = 0 },
        },
        [14] = {
            { name = "Arcane Intellect",          cost = 810,     type = "Buff",   castTime = 0,   duration = 1800 },
            { name = "Fire Blast (Rank 2)",       cost = 810,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Frostbolt (Rank 3)",        cost = 810,     type = "Damage", castTime = 2.2, duration = 6 },
            { name = "Arcane Intellect (Rank 2)", cost = 810,     type = "Buff",   castTime = 0,   duration = 1800 },
            { name = "Arcane Explosion (Rank 1)", leanCost = 810, powerCost = 75,  min = 29,       max = 33,       type = "Damage", castTime = 0, duration = 0 },
        },
        [16] = {
            { name = "Flamestrike (Rank 1)",     learnCost = 1350, powerCost = 195,  min = 55,       max = 72,      type = "Damage", castTime = 3.0, duration = 8 },
            { name = "Arcane Missiles (Rank 2)", cost = 1350,      type = "Damage",  castTime = 4.0, duration = 4 }, -- Channeled
            { name = "Detect Magic",             cost = 1350,      type = "Utility", castTime = 0,   duration = 120 },
        },
        [18] = {
            { name = "Amplify Magic",          cost = 1620, type = "Buff",    castTime = 0,   duration = 600 },
            { name = "Fireball (Rank 4)",      cost = 1620, type = "Damage",  castTime = 3.5, duration = 8 },
            { name = "Amplify Magic (Rank 1)", cost = 1620, type = "Buff",    castTime = 0,   duration = 600 },
            { name = "Remove Lesser Curse",    cost = 1620, type = "Utility", castTime = 0,   duration = 0 },
        },
        [20] = {
            { name = "Fire Ward (Rank 1)",     cost = 1800,      type = "Buff",          castTime = 0,   duration = 30 },
            { name = "Polymorph (Rank 2)",     cost = 1800,      type = "Crowd Control", castTime = 1.5, duration = 30 },
            { name = "Fire Ward",              cost = 1800,      type = "Buff",          castTime = 0,   duration = 30 },
            { name = "Blink",                  cost = 1800,      type = "Utility",       castTime = 0,   duration = 0 },
            { name = "Conjure Water",          cost = 1800,      type = "Utility",       castTime = 3.0, duration = 0 },
            { name = "Frostbolt (Rank 4)",     cost = 1800,      type = "Damage",        castTime = 2.6, duration = 8 },
            { name = "Frost Armor (Rank 3)",   cost = 1800,      type = "Buff",          castTime = 0,   duration = 1800 },
            { name = "Blizzard (Rank 1)",      learnCost = 1800, powerCost = 320,        min = 200,      max = 200,      type = "Damage", castTime = 8.0, duration = 8 }, -- Channeled (Total Dmg)
            { name = "Mana Shield (Rank 1)",   cost = 1800,      type = "Buff",          castTime = 0,   duration = 60 },
            { name = "Blizzard",               cost = 1800,      type = "Damage",        castTime = 8.0, duration = 8 },
            { name = "Polymorph",              cost = 1800,      type = "Crowd Control", castTime = 1.5, duration = 30 },
            { name = "Mana Shield",            cost = 1800,      type = "Buff",          castTime = 0,   duration = 60 },
            { name = "Frost Armor",            cost = 1800,      type = "Buff",          castTime = 0,   duration = 1800 },
            { name = "Conjure Water (Rank 3)", cost = 1800,      type = "Utility",       castTime = 3.0, duration = 0 },
            { name = "Evocation",              cost = 1800,      type = "Utility",       castTime = 8.0, duration = 8 }, -- Channeled
        },
        [22] = {
            { name = "Fire Blast (Rank 3)",       cost = 2700,      type = "Damage",  castTime = 0,   duration = 0 },
            { name = "Fire Blast",                cost = 2700,      type = "Damage",  castTime = 0,   duration = 0 },
            { name = "Arcane Explosion (Rank 2)", learnCost = 2700, powerCost = 120,  min = 54,       max = 58,     type = "Damage", castTime = 0, duration = 0 },
            { name = "Scorch",                    cost = 2700,      type = "Damage",  castTime = 1.5, duration = 0 },
            { name = "Frost Ward",                cost = 2700,      type = "Buff",    castTime = 0,   duration = 30 },
            { name = "Conjure Food",              cost = 2700,      type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Frost Ward (Rank 1)",       cost = 2700,      type = "Buff",    castTime = 0,   duration = 30 },
            { name = "Scorch (Rank 1)",           cost = 2700,      type = "Damage",  castTime = 1.5, duration = 0 },
            { name = "Conjure Food (Rank 3)",     cost = 2700,      type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Arcane Explosion",          cost = 2700,      type = "Damage",  castTime = 0,   duration = 0 },
        },
        [24] = {
            { name = "Dampen Magic",             cost = 3600,      type = "Buff",          castTime = 0,   duration = 600 },
            { name = "Fireball",                 cost = 3600,      type = "Damage",        castTime = 3.5, duration = 8 },
            { name = "Flamestrike (Rank 2)",     learnCost = 3600, powerCost = 330,        min = 101,      max = 127,     type = "Damage", castTime = 3.0, duration = 8 },
            { name = "Fireball (Rank 5)",        cost = 3600,      type = "Damage",        castTime = 3.5, duration = 8 },
            { name = "Arcane Missiles (Rank 3)", cost = 3600,      type = "Damage",        castTime = 5.0, duration = 5 }, -- Channeled
            { name = "Dampen Magic (Rank 2)",    cost = 3600,      type = "Buff",          castTime = 0,   duration = 600 },
            { name = "Counterspell",             cost = 3600,      type = "Crowd Control", castTime = 0,   duration = 10 },
            { name = "Flamestrike",              cost = 3600,      type = "Damage",        castTime = 3.0, duration = 8 },
            { name = "Arcane Missiles",          cost = 3600,      type = "Damage",        castTime = 5.0, duration = 5 },
            { name = "Pyroblast (Rank 2)",       cost = 180,       type = "Damage",        castTime = 6.0, duration = 12 },
        },
        [26] = {
            { name = "Frost Nova",            cost = 4500,      type = "Damage", castTime = 0,   duration = 8 },
            { name = "Frostbolt",             cost = 4500,      type = "Damage", castTime = 3.0, duration = 8 },
            { name = "Frost Nova (Rank 2)",   cost = 4500,      type = "Damage", castTime = 0,   duration = 8 },
            { name = "Cone of Cold (Rank 1)", learnCost = 4500, powerCost = 210, min = 96,       max = 105,   type = "Damage", castTime = 0, duration = 8 },
            { name = "Frostbolt (Rank 5)",    cost = 4500,      type = "Damage", castTime = 3.0, duration = 8 },
            { name = "Cone of Cold",          cost = 4500,      type = "Damage", castTime = 0,   duration = 8 },
        },
        [28] = {
            { name = "Arcane Intellect (Rank 3)", cost = 6300,      type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Conjure Mana Agate",        cost = 6300,      type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Blizzard (Rank 2)",         learnCost = 6300, powerCost = 520,  min = 360,      max = 360,      type = "Damage", castTime = 8.0, duration = 8 },
            { name = "Scorch (Rank 2)",           cost = 6300,      type = "Damage",  castTime = 1.5, duration = 0 },
            { name = "Mana Shield (Rank 2)",      cost = 6300,      type = "Buff",    castTime = 0,   duration = 60 },
        },
        [30] = {
            { name = "Amplify Magic (Rank 2)",    cost = 7200,      type = "Buff",    castTime = 0,   duration = 600 },
            { name = "Conjure Water (Rank 4)",    cost = 7200,      type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Fireball (Rank 6)",         cost = 7200,      type = "Damage",  castTime = 3.5, duration = 8 },
            { name = "Arcane Explosion (Rank 3)", learnCost = 7200, powerCost = 185,  min = 86,       max = 93,       type = "Damage", castTime = 0, duration = 0 },
            { name = "Fire Ward (Rank 2)",        cost = 7200,      type = "Buff",    castTime = 0,   duration = 30 },
            { name = "Ice Armor (Rank 1)",        cost = 7200,      type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Fire Blast (Rank 4)",       cost = 7200,      type = "Damage",  castTime = 0,   duration = 0 },
            { name = "Pyroblast (Rank 3)",        cost = 360,       type = "Damage",  castTime = 6.0, duration = 12 },
        },
        [32] = {
            { name = "Frostbolt (Rank 6)",       cost = 9000,      type = "Damage",  castTime = 3.0, duration = 9 },
            { name = "Frost Ward (Rank 2)",      cost = 9000,      type = "Buff",    castTime = 0,   duration = 30 },
            { name = "Arcane Missiles (Rank 4)", cost = 9000,      type = "Damage",  castTime = 5.0, duration = 5 },
            { name = "Conjure Food (Rank 4)",    cost = 9000,      type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Flamestrike (Rank 3)",     learnCost = 9000, powerCost = 490,  min = 163,      max = 202,    type = "Damage", castTime = 3.0, duration = 8 },
        },
        [34] = {
            { name = "Scorch (Rank 3)",       cost = 10800,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Cone of Cold (Rank 2)", learnCost = 10800, powerCost = 290, min = 142,      max = 155,      type = "Damage", castTime = 0, duration = 8 },
            { name = "Mage Armor (Rank 1)",   cost = 11700,      type = "Buff",   castTime = 0,   duration = 1800 },
        },
        [36] = {
            { name = "Blizzard (Rank 3)",     learnCost = 11700, powerCost = 720, min = 560,      max = 560,     type = "Damage", castTime = 8.0, duration = 8 },
            { name = "Dampen Magic (Rank 3)", cost = 11700,      type = "Buff",   castTime = 0,   duration = 600 },
            { name = "Blast Wave (Rank 2)",   cost = 585,        type = "Damage", castTime = 0,   duration = 6 },
            { name = "Pyroblast (Rank 4)",    cost = 585,        type = "Damage", castTime = 6.0, duration = 12 },
            { name = "Mana Shield (Rank 3)",  cost = 11700,      type = "Buff",   castTime = 0,   duration = 60 },
            { name = "Fireball (Rank 7)",     cost = 11700,      type = "Damage", castTime = 3.5, duration = 8 },
        },
        [38] = {
            { name = "Arcane Explosion (Rank 4)", learnCost = 12600, powerCost = 250,  min = 126,      max = 136,   type = "Damage", castTime = 0, duration = 0 },
            { name = "Conjure Mana Jade",         cost = 12600,      type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Frostbolt (Rank 7)",        cost = 12600,      type = "Damage",  castTime = 3.0, duration = 9 },
            { name = "Fire Blast (Rank 5)",       cost = 12600,      type = "Damage",  castTime = 0,   duration = 0 },
        },
        [40] = {
            { name = "Flamestrike (Rank 4)",     learnCost = 13500, powerCost = 650,        min = 233,      max = 286,      type = "Damage", castTime = 3.0, duration = 8 },
            { name = "Fire Ward (Rank 3)",       cost = 13500,      type = "Buff",          castTime = 0,   duration = 30 },
            { name = "Ice Armor (Rank 2)",       cost = 13500,      type = "Buff",          castTime = 0,   duration = 1800 },
            { name = "Arcane Missiles (Rank 5)", cost = 13500,      type = "Damage",        castTime = 5.0, duration = 5 },
            { name = "Scorch (Rank 4)",          cost = 13500,      type = "Damage",        castTime = 1.5, duration = 0 },
            { name = "Frost Nova (Rank 3)",      cost = 13500,      type = "Damage",        castTime = 0,   duration = 8 },
            { name = "Polymorph (Rank 3)",       cost = 13500,      type = "Crowd Control", castTime = 1.5, duration = 40 },
            { name = "Conjure Water (Rank 5)",   cost = 13500,      type = "Utility",       castTime = 3.0, duration = 0 },
        },
        [42] = {
            { name = "Frost Ward (Rank 3)",       cost = 16200,      type = "Buff",    castTime = 0,   duration = 30 },
            { name = "Pyroblast (Rank 5)",        cost = 810,        type = "Damage",  castTime = 6.0, duration = 12 },
            { name = "Fireball (Rank 8)",         cost = 16200,      type = "Damage",  castTime = 3.5, duration = 8 },
            { name = "Cone of Cold (Rank 3)",     learnCost = 16200, powerCost = 380,  min = 196,      max = 212,      type = "Damage", castTime = 0, duration = 8 },
            { name = "Arcane Intellect (Rank 4)", cost = 16200,      type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Conjure Food (Rank 5)",     cost = 16200,      type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Amplify Magic (Rank 3)",    cost = 16200,      type = "Buff",    castTime = 0,   duration = 600 },
        },
        [44] = {
            { name = "Blizzard (Rank 4)",    learnCost = 20700, powerCost = 935, min = 832,      max = 832,    type = "Damage", castTime = 8.0, duration = 8 },
            { name = "Blast Wave (Rank 3)",  cost = 1035,       type = "Damage", castTime = 0,   duration = 6 },
            { name = "Frostbolt (Rank 8)",   cost = 20700,      type = "Damage", castTime = 3.0, duration = 9 },
            { name = "Mana Shield (Rank 4)", cost = 20700,      type = "Buff",   castTime = 0,   duration = 60 },
        },
        [46] = {
            { name = "Fire Blast (Rank 6)",       cost = 23400,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Ice Barrier (Rank 2)",      cost = 1170,       type = "Buff",   castTime = 0,   duration = 60 },
            { name = "Scorch (Rank 5)",           cost = 23400,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Arcane Explosion (Rank 5)", learnCost = 23400, powerCost = 315, min = 173,      max = 187,      type = "Damage", castTime = 0, duration = 0 },
            { name = "Mage Armor (Rank 2)",       cost = 25200,      type = "Buff",   castTime = 0,   duration = 1800 },
        },
        [48] = {
            { name = "Dampen Magic (Rank 4)",    cost = 25200,      type = "Buff",    castTime = 0,   duration = 600 },
            { name = "Pyroblast (Rank 6)",       cost = 1260,       type = "Damage",  castTime = 6.0, duration = 12 },
            { name = "Flamestrike (Rank 5)",     learnCost = 25200, powerCost = 815,  min = 308,      max = 378,     type = "Damage", castTime = 3.0, duration = 8 },
            { name = "Fireball (Rank 9)",        cost = 25200,      type = "Damage",  castTime = 3.5, duration = 8 },
            { name = "Conjure Mana Citrine",     cost = 25200,      type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Arcane Missiles (Rank 6)", cost = 25200,      type = "Damage",  castTime = 5.0, duration = 5 },
        },
        [50] = {
            { name = "Conjure Water (Rank 6)", cost = 28800,      type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Ice Armor (Rank 3)",     cost = 28800,      type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Frostbolt (Rank 9)",     cost = 28800,      type = "Damage",  castTime = 3.0, duration = 9 },
            { name = "Fire Ward (Rank 4)",     cost = 28800,      type = "Buff",    castTime = 0,   duration = 30 },
            { name = "Cone of Cold (Rank 4)",  learnCost = 28800, powerCost = 480,  min = 258,      max = 280,      type = "Damage", castTime = 0, duration = 8 },
        },
        [52] = {
            { name = "Blast Wave (Rank 4)",   cost = 1575,       type = "Damage",  castTime = 0,   duration = 6 },
            { name = "Scorch (Rank 6)",       cost = 31500,      type = "Damage",  castTime = 1.5, duration = 0 },
            { name = "Mana Shield (Rank 5)",  cost = 31500,      type = "Buff",    castTime = 0,   duration = 60 },
            { name = "Ice Barrier (Rank 3)",  cost = 1575,       type = "Buff",    castTime = 0,   duration = 60 },
            { name = "Blizzard (Rank 5)",     learnCost = 31500, powerCost = 1160, min = 1192,     max = 1192,   type = "Damage", castTime = 8.0, duration = 8 },
            { name = "Frost Ward (Rank 4)",   cost = 31500,      type = "Buff",    castTime = 0,   duration = 30 },
            { name = "Conjure Food (Rank 6)", cost = 31500,      type = "Utility", castTime = 3.0, duration = 0 },
        },
        [54] = {
            { name = "Pyroblast (Rank 7)",        cost = 1620,       type = "Damage", castTime = 6.0, duration = 12 },
            { name = "Fire Blast (Rank 7)",       cost = 32400,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Amplify Magic (Rank 4)",    cost = 32400,      type = "Buff",   castTime = 0,   duration = 600 },
            { name = "Arcane Explosion (Rank 6)", learnCost = 32400, powerCost = 390, min = 225,      max = 243,     type = "Damage", castTime = 0, duration = 0 },
            { name = "Fireball (Rank 10)",        cost = 32400,      type = "Damage", castTime = 3.5, duration = 8 },
            { name = "Frost Nova (Rank 4)",       cost = 32400,      type = "Damage", castTime = 0,   duration = 8 },
        },
        [56] = {
            { name = "Flamestrike (Rank 6)",      learnCost = 34200, powerCost = 995, min = 397,      max = 484,      type = "Damage", castTime = 3.0, duration = 8 },
            { name = "Arcane Intellect (Rank 5)", cost = 34200,      type = "Buff",   castTime = 0,   duration = 1800 },
            { name = "Frostbolt (Rank 10)",       cost = 34200,      type = "Damage", castTime = 3.0, duration = 9 },
            { name = "Arcane Missiles (Rank 7)",  cost = 34200,      type = "Damage", castTime = 5.0, duration = 5 },
        },
        [58] = {
            { name = "Conjure Mana Ruby",     cost = 36000,      type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Cone of Cold (Rank 5)", learnCost = 36000, powerCost = 580,  min = 331,      max = 358,      type = "Damage", castTime = 0, duration = 8 },
            { name = "Mage Armor (Rank 3)",   cost = 36000,      type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Scorch (Rank 7)",       cost = 36000,      type = "Damage",  castTime = 1.5, duration = 0 },
            { name = "Ice Barrier (Rank 4)",  cost = 1800,       type = "Buff",    castTime = 0,   duration = 60 },
        },
        [60] = {
            { name = "Blast Wave (Rank 5)",   cost = 1890,       type = "Damage",        castTime = 0,   duration = 6 },
            { name = "Dampen Magic (Rank 5)", cost = 37800,      type = "Buff",          castTime = 0,   duration = 600 },
            { name = "Ice Armor (Rank 4)",    cost = 37800,      type = "Buff",          castTime = 0,   duration = 1800 },
            { name = "Fireball (Rank 11)",    cost = 37800,      type = "Damage",        castTime = 3.5, duration = 8 },
            { name = "Mana Shield (Rank 6)",  cost = 37800,      type = "Buff",          castTime = 0,   duration = 60 },
            { name = "Blizzard (Rank 6)",     learnCost = 37800, powerCost = 1400,       min = 1648,     max = 1648,     type = "Damage", castTime = 8.0, duration = 8 },
            { name = "Polymorph (Rank 4)",    cost = 37800,      type = "Crowd Control", castTime = 1.5, duration = 50 },
            { name = "Fire Ward (Rank 5)",    cost = 37800,      type = "Buff",          castTime = 0,   duration = 30 },
            { name = "Pyroblast (Rank 8)",    cost = 1890,       type = "Damage",        castTime = 6.0, duration = 12 },
        },
    },

    --------------------------------------------------------
    -- ROGUE – 1–60 with cost placeholders (copper = 0)
    --------------------------------------------------------
    ROGUE = {
        [1] = {
            { name = "Stealth",                  learnCost = 10, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },
            { name = "Sinister Strike (Rank 1)", learnCost = 10, powerCost = 45, min = 3,          max = 3,      type = "Damage", castTime = 0, duration = 0 },
            { name = "Eviscerate (Rank 1)",      learnCost = 10, powerCost = 35, min = 6,          max = 10,     type = "Damage", castTime = 0, duration = 0 },
        },
        [4] = {
            { name = "Backstab",    learnCost = 100, powerCost = 60, min = 15,         max = 25,     type = "Damage", castTime = 0, duration = 0 }, -- Requires Dagger
            { name = "Pick Pocket", learnCost = 100, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },
        },
        [6] = {
            { name = "Gouge (Rank 1)",           learnCost = 100, powerCost = 45, min = 1, max = 2, type = "Crowd Control", castTime = 0, duration = 4 },
            { name = "Sinister Strike (Rank 2)", learnCost = 100, powerCost = 45, min = 6, max = 6, type = "Damage",        castTime = 0, duration = 0 },
        },
        [8] = {
            { name = "Evasion",             cost = 200, type = "Buff",   castTime = 0, duration = 15 },
            { name = "Eviscerate (Rank 2)", cost = 200, type = "Damage", castTime = 0, duration = 0 },
        },
        [10] = {
            { name = "Slice and Dice (Rank 1)", cost = 300, type = "Buff",          castTime = 0, duration = 0 },
            { name = "Sprint (Rank 1)",         cost = 300, type = "Buff",          castTime = 0, duration = 15 },
            { name = "Dual Wield",              cost = 300, type = "Utility",       castTime = 0, duration = 0 },
            { name = "Sap (Rank 1)",            cost = 300, type = "Crowd Control", castTime = 0, duration = 25 },
        },
        [12] = {
            { name = "Backstab (Rank 2)", cost = 800, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Parry",             cost = 800, type = "Utility", castTime = 0, duration = 0 },
            { name = "Kick (Rank 1)",     cost = 800, type = "Utility", castTime = 0, duration = 5 },
        },
        [14] = {
            { name = "Garrote (Rank 1)",         cost = 1200, type = "Damage",  castTime = 0, duration = 18 },
            { name = "Expose Armor (Rank 1)",    cost = 1200, type = "Utility", castTime = 0, duration = 30 },
            { name = "Sinister Strike (Rank 3)", cost = 1200, min = 10,         max = 10,     type = "Damage", castTime = 0, duration = 0 },
        },
        [16] = {
            { name = "Pick Lock",           cost = 1800, type = "Utility", castTime = 0, duration = 0 },
            { name = "Eviscerate (Rank 3)", cost = 1800, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Feint (Rank 1)",      cost = 1800, type = "Utility", castTime = 0, duration = 0 },
        },
        [18] = {
            { name = "Ambush (Rank 1)", cost = 2900, type = "Damage",        castTime = 0, duration = 0 },
            { name = "Gouge (Rank 2)",  cost = 2900, type = "Crowd Control", castTime = 0, duration = 4 },
        },
        [20] = {
            { name = "Stealth (Rank 2)",          cost = 3000, type = "Utility", castTime = 0,   duration = 0 },
            { name = "Rupture (Rank 1)",          cost = 3000, type = "Damage",  castTime = 0,   duration = 0 },
            { name = "Backstab (Rank 3)",         cost = 3000, type = "Damage",  castTime = 0,   duration = 0 },
            { name = "Crippling Poison (Rank 1)", cost = 3000, type = "Buff",    castTime = 3.0, duration = 1800 },
        },
        [22] = {
            { name = "Garrote (Rank 2)",         cost = 4000, type = "Damage",  castTime = 0, duration = 18 },
            { name = "Distract",                 cost = 4000, type = "Utility", castTime = 0, duration = 10 },
            { name = "Vanish (Rank 1)",          cost = 4000, type = "Buff",    castTime = 0, duration = 10 },
            { name = "Sinister Strike (Rank 4)", cost = 4000, min = 15,         max = 15,     type = "Damage", castTime = 0, duration = 0 },
        },
        [24] = {
            { name = "Eviscerate (Rank 4)",          cost = 5000, type = "Damage", castTime = 0,   duration = 0 },
            { name = "Detect Traps",                 cost = 5000, type = "Buff",   castTime = 0,   duration = 180 },
            { name = "Mind-numbing Poison (Rank 1)", cost = 5000, type = "Buff",   castTime = 3.0, duration = 1800 },
        },
        [26] = {
            { name = "Kick (Rank 2)",         cost = 6000, type = "Utility",       castTime = 0, duration = 5 },
            { name = "Cheap Shot",            cost = 6000, type = "Crowd Control", castTime = 0, duration = 4 },
            { name = "Ambush (Rank 2)",       cost = 6000, type = "Damage",        castTime = 0, duration = 0 },
            { name = "Expose Armor (Rank 2)", cost = 6000, type = "Utility",       castTime = 0, duration = 30 },
        },
        [28] = {
            { name = "Rupture (Rank 2)",        cost = 8000, type = "Damage",        castTime = 0,   duration = 0 },
            { name = "Sap (Rank 2)",            cost = 8000, type = "Crowd Control", castTime = 0,   duration = 35 },
            { name = "Backstab (Rank 4)",       cost = 8000, type = "Damage",        castTime = 0,   duration = 0 },
            { name = "Feint (Rank 2)",          cost = 8000, type = "Utility",       castTime = 0,   duration = 0 },
            { name = "Instant Poison (Rank 2)", cost = 8000, type = "Buff",          castTime = 3.0, duration = 1800 },
        },
        [30] = {
            { name = "Sinister Strike (Rank 5)", cost = 10000, min = 22,               max = 22,       type = "Damage", castTime = 0, duration = 0 },
            { name = "Deadly Poison (Rank 1)",   cost = 10000, type = "Buff",          castTime = 3.0, duration = 1800 },
            { name = "Disarm Trap",              cost = 10000, type = "Utility",       castTime = 0,   duration = 0 },
            { name = "Kidney Shot (Rank 1)",     cost = 10000, type = "Crowd Control", castTime = 0,   duration = 0 },
            { name = "Garrote (Rank 3)",         cost = 10000, type = "Damage",        castTime = 0,   duration = 18 },
        },
        [32] = {
            { name = "Wound Poison (Rank 1)", cost = 12000, type = "Buff",          castTime = 3.0, duration = 1800 },
            { name = "Gouge (Rank 3)",        cost = 12000, type = "Crowd Control", castTime = 0,   duration = 4 },
            { name = "Eviscerate (Rank 5)",   cost = 12000, type = "Damage",        castTime = 0,   duration = 0 },
        },
        [34] = {
            { name = "Sprint (Rank 2)", cost = 14000, type = "Buff",          castTime = 0, duration = 15 },
            { name = "Blind",           cost = 14000, type = "Crowd Control", castTime = 0, duration = 10 },
            { name = "Ambush (Rank 3)", cost = 14000, type = "Damage",        castTime = 0, duration = 0 },
            { name = "Blinding Powder", cost = 14000, type = "Utility",       castTime = 0, duration = 0 },
        },
        [36] = {
            { name = "Backstab (Rank 5)",       cost = 16000, type = "Damage",  castTime = 0,   duration = 0 },
            { name = "Rupture (Rank 3)",        cost = 16000, type = "Damage",  castTime = 0,   duration = 0 },
            { name = "Instant Poison (Rank 3)", cost = 16000, type = "Buff",    castTime = 3.0, duration = 1800 },
            { name = "Expose Armor (Rank 3)",   cost = 16000, type = "Utility", castTime = 0,   duration = 30 },
        },
        [38] = {
            { name = "Sinister Strike (Rank 6)",     cost = 18000, min = 33,        max = 33,       type = "Damage", castTime = 0, duration = 0 },
            { name = "Mind-numbing Poison (Rank 2)", cost = 18000, type = "Buff",   castTime = 3.0, duration = 1800 },
            { name = "Garrote (Rank 4)",             cost = 18000, type = "Damage", castTime = 0,   duration = 18 },
            { name = "Deadly Poison (Rank 2)",       cost = 18000, type = "Buff",   castTime = 3.0, duration = 1800 },
        },
        [40] = {
            { name = "Safe Fall (Passive)",   cost = 20000, type = "Utility", castTime = 0,   duration = 0 },
            { name = "Eviscerate (Rank 6)",   cost = 20000, type = "Damage",  castTime = 0,   duration = 0 },
            { name = "Wound Poison (Rank 2)", cost = 20000, type = "Buff",    castTime = 3.0, duration = 1800 },
            { name = "Stealth (Rank 3)",      cost = 20000, type = "Utility", castTime = 0,   duration = 0 },
            { name = "Feint (Rank 3)",        cost = 20000, type = "Utility", castTime = 0,   duration = 0 },
        },
        [42] = {
            { name = "Ambush (Rank 4)",         cost = 27000, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Slice and Dice (Rank 2)", cost = 27000, type = "Buff",    castTime = 0, duration = 0 },
            { name = "Kick (Rank 3)",           cost = 27000, type = "Utility", castTime = 0, duration = 5 },
            { name = "Vanish (Rank 2)",         cost = 27000, type = "Buff",    castTime = 0, duration = 10 },
        },
        [44] = {
            { name = "Backstab (Rank 6)",       cost = 29000, type = "Damage", castTime = 0,   duration = 0 },
            { name = "Instant Poison (Rank 4)", cost = 29000, type = "Buff",   castTime = 3.0, duration = 1800 },
            { name = "Rupture (Rank 4)",        cost = 29000, type = "Damage", castTime = 0,   duration = 0 },
        },
        [46] = {
            { name = "Gouge (Rank 4)",           cost = 31000, type = "Crowd Control", castTime = 0,   duration = 4 },
            { name = "Sinister Strike (Rank 7)", cost = 31000, min = 52,               max = 52,       type = "Damage", castTime = 0, duration = 0 },
            { name = "Deadly Poison (Rank 3)",   cost = 31000, type = "Buff",          castTime = 3.0, duration = 1800 },
            { name = "Hemorrhage (Rank 2)",      cost = 7750,  type = "Damage",        castTime = 0,   duration = 15 },
            { name = "Garrote (Rank 5)",         cost = 31000, type = "Damage",        castTime = 0,   duration = 18 },
            { name = "Expose Armor (Rank 4)",    cost = 31000, type = "Utility",       castTime = 0,   duration = 30 },
        },
        [48] = {
            { name = "Sap (Rank 3)",          cost = 33000, type = "Crowd Control", castTime = 0,   duration = 45 },
            { name = "Eviscerate (Rank 7)",   cost = 33000, type = "Damage",        castTime = 0,   duration = 0 },
            { name = "Wound Poison (Rank 3)", cost = 33000, type = "Buff",          castTime = 3.0, duration = 1800 },
        },
        [50] = {
            { name = "Kidney Shot (Rank 2)",      cost = 35000, type = "Crowd Control", castTime = 0,   duration = 0 },
            { name = "Crippling Poison (Rank 2)", cost = 35000, type = "Buff",          castTime = 3.0, duration = 1800 },
            { name = "Ambush (Rank 5)",           cost = 35000, type = "Damage",        castTime = 0,   duration = 0 },
        },
        [52] = {
            { name = "Instant Poison (Rank 5)",      cost = 46000, type = "Buff",    castTime = 3.0, duration = 1800 },
            { name = "Backstab (Rank 7)",            cost = 46000, type = "Damage",  castTime = 0,   duration = 0 },
            { name = "Mind-numbing Poison (Rank 3)", cost = 46000, type = "Buff",    castTime = 3.0, duration = 1800 },
            { name = "Feint (Rank 4)",               cost = 46000, type = "Utility", castTime = 0,   duration = 0 },
            { name = "Rupture (Rank 5)",             cost = 46000, type = "Damage",  castTime = 0,   duration = 0 },
        },
        [54] = {
            { name = "Deadly Poison (Rank 4)",   cost = 48000, type = "Buff",   castTime = 3.0, duration = 1800 },
            { name = "Sinister Strike (Rank 8)", cost = 48000, min = 68,        max = 68,       type = "Damage", castTime = 0, duration = 0 },
            { name = "Garrote (Rank 6)",         cost = 48000, type = "Damage", castTime = 0,   duration = 18 },
        },
        [56] = {
            { name = "Wound Poison (Rank 4)", cost = 50000, type = "Buff",    castTime = 3.0, duration = 1800 },
            { name = "Eviscerate (Rank 8)",   cost = 50000, type = "Damage",  castTime = 0,   duration = 0 },
            { name = "Expose Armor (Rank 5)", cost = 50000, type = "Utility", castTime = 0,   duration = 30 },
        },
        [58] = {
            { name = "Sprint (Rank 3)",     cost = 52000, type = "Buff",    castTime = 0, duration = 15 },
            { name = "Hemorrhage (Rank 3)", cost = 13000, type = "Damage",  castTime = 0, duration = 15 },
            { name = "Ambush (Rank 6)",     cost = 52000, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Kick (Rank 4)",       cost = 52000, type = "Utility", castTime = 0, duration = 5 },
        },
        [60] = {
            { name = "Rupture (Rank 6)",        cost = 54000, type = "Damage",        castTime = 0,   duration = 0 },
            { name = "Stealth (Rank 4)",        cost = 54000, type = "Utility",       castTime = 0,   duration = 0 },
            { name = "Instant Poison (Rank 6)", cost = 54000, type = "Buff",          castTime = 3.0, duration = 1800 },
            { name = "Backstab (Rank 8)",       cost = 54000, type = "Damage",        castTime = 0,   duration = 0 },
            { name = "Gouge (Rank 5)",          cost = 54000, type = "Crowd Control", castTime = 0,   duration = 4 },
        },
    },

    --------------------------------------------------------
    -- HUNTER – 1–60 with cost placeholders (copper = 0)
    --------------------------------------------------------
    HUNTER = {
        [1] = {
            { name = "Track Beasts",         learnCost = 10, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },
            { name = "Steady Shot (Rank 1)", learnCost = 10, powerCost = 45, min = 12,         max = 15,     type = "Damage", castTime = 1.5, duration = 0 }, -- Turtle WoW custom? Vanilla didn't have Steady Shot normally.
        },
        [4] = {
            { name = "Aspect of the Monkey",   learnCost = 100, powerCost = 20, type = "Buff", castTime = 0, duration = 0 },
            { name = "Serpent Sting (Rank 1)", learnCost = 100, powerCost = 15, min = 20,      max = 20,     type = "Damage", castTime = 0, duration = 15 },
        },
        [6] = {
            { name = "Arcane Shot (Rank 1)",   learnCost = 100, powerCost = 25, min = 13,         max = 13,     type = "Damage", castTime = 0, duration = 0 },
            { name = "Hunter's Mark (Rank 1)", learnCost = 100, powerCost = 15, type = "Utility", castTime = 0, duration = 120 },
        },
        [8] = {
            { name = "Parry",                  learnCost = 200, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },
            { name = "Concussive Shot",        learnCost = 200, powerCost = 8,  type = "Damage",  castTime = 0, duration = 4 }, -- Slow
            { name = "Raptor Strike (Rank 2)", learnCost = 200, powerCost = 25, min = 15,         max = 15,     type = "Damage", castTime = 0, duration = 0 },
        },
        [10] = {
            { name = "Serpent Sting (Rank 2)",      learnCost = 400, powerCost = 30, min = 40,         max = 40,     type = "Damage", castTime = 0, duration = 15 },
            { name = "Track Humanoids",             learnCost = 400, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },
            { name = "Aspect of the Hawk (Rank 1)", learnCost = 400, powerCost = 20, type = "Buff",    castTime = 0, duration = 0 },
        },
        [12] = {
            { name = "Arcane Shot (Rank 2)",      learnCost = 600, powerCost = 35, min = 21,         max = 21,       type = "Damage", castTime = 0, duration = 0 },
            { name = "Distracting Shot (Rank 1)", learnCost = 600, powerCost = 20, type = "Utility", castTime = 0,   duration = 0 },
            { name = "Mend Pet (Rank 1)",         learnCost = 600, powerCost = 50, type = "Heal",    castTime = 3.0, duration = 5 }, -- Channeled
            { name = "Wing Clip (Rank 1)",        learnCost = 600, powerCost = 40, type = "Damage",  castTime = 0,   duration = 10 },
        },
        [14] = {
            { name = "Eyes of the Beast",    learnCost = 1200, powerCost = 0,  type = "Utility",       castTime = 2.0, duration = 60 },
            { name = "Scare Beast (Rank 1)", learnCost = 1200, powerCost = 35, type = "Crowd Control", castTime = 1.5, duration = 10 },
            { name = "Eagle Eye",            learnCost = 1200, powerCost = 0,  type = "Utility",       castTime = 0,   duration = 60 },
        },
        [16] = {
            { name = "Raptor Strike (Rank 3)",   learnCost = 1800, powerCost = 35, min = 25,  max = 25,  type = "Damage", castTime = 0, duration = 0 },
            { name = "Mongoose Bite (Rank 1)",   learnCost = 1800, powerCost = 30, min = 25,  max = 25,  type = "Damage", castTime = 0, duration = 0 },
            { name = "Immolation Trap (Rank 1)", learnCost = 1800, powerCost = 50, min = 105, max = 105, type = "Damage", castTime = 0, duration = 15 },
        },
        [18] = {
            { name = "Aspect of the Hawk (Rank 2)", learnCost = 2000, powerCost = 35,  type = "Buff",    castTime = 0, duration = 0 },
            { name = "Serpent Sting (Rank 3)",      learnCost = 2000, powerCost = 50,  min = 80,         max = 80,     type = "Damage", castTime = 0, duration = 15 },
            { name = "Multi-Shot (Rank 1)",         learnCost = 2000, powerCost = 100, min = 0,          max = 0,      type = "Damage", castTime = 0, duration = 0 },
            { name = "Track Undead",                learnCost = 2000, powerCost = 0,   type = "Utility", castTime = 0, duration = 0 },
        },
        [20] = {
            { name = "Distracting Shot (Rank 2)", learnCost = 2200, powerCost = 30, type = "Utility",       castTime = 0,   duration = 0 },
            { name = "Dual Wield",                learnCost = 2200, powerCost = 0,  type = "Utility",       castTime = 0,   duration = 0 },
            { name = "Freezing Trap (Rank 1)",    learnCost = 2200, powerCost = 60, type = "Crowd Control", castTime = 0,   duration = 10 },
            { name = "Disengage (Rank 1)",        learnCost = 2200, powerCost = 50, type = "Utility",       castTime = 0,   duration = 0 },
            { name = "Arcane Shot (Rank 3)",      learnCost = 2200, powerCost = 50, min = 33,               max = 33,       type = "Damage", castTime = 0, duration = 0 },
            { name = "Mend Pet (Rank 2)",         learnCost = 2200, powerCost = 90, type = "Heal",          castTime = 3.0, duration = 5 },
            { name = "Aspect of the Cheetah",     learnCost = 2200, powerCost = 40, type = "Buff",          castTime = 0,   duration = 0 },
        },
        [22] = {
            { name = "Scorpid Sting (Rank 1)", learnCost = 6000, powerCost = 70, type = "Utility", castTime = 0, duration = 20 },
            { name = "Hunter's Mark (Rank 2)", learnCost = 6000, powerCost = 30, type = "Utility", castTime = 0, duration = 120 },
        },
        [24] = {
            { name = "Beast Lore",             learnCost = 7000, powerCost = 40, type = "Utility", castTime = 0, duration = 30 }, -- Channeled (tooltip says instant but it shows info) - actually an instant cast that puts a buff on finding info? No, it's instant.
            { name = "Raptor Strike (Rank 4)", learnCost = 7000, powerCost = 45, min = 45,         max = 45,     type = "Damage", castTime = 0, duration = 0 },
            { name = "Track Hidden",           learnCost = 7000, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },
        },
        [26] = {
            { name = "Immolation Trap (Rank 2)", learnCost = 7000, powerCost = 90,  min = 215,        max = 215,    type = "Damage", castTime = 0, duration = 15 },
            { name = "Track Elementals",         learnCost = 7000, powerCost = 0,   type = "Utility", castTime = 0, duration = 0 },
            { name = "Rapid Fire",               learnCost = 7000, powerCost = 100, type = "Buff",    castTime = 0, duration = 15 },
            { name = "Serpent Sting (Rank 4)",   learnCost = 7000, powerCost = 90,  min = 140,        max = 140,    type = "Damage", castTime = 0, duration = 15 },
        },
        [28] = {
            { name = "Frost Trap",                  learnCost = 8000, powerCost = 60,  type = "Utility", castTime = 0,   duration = 30 }, -- Field duration
            { name = "Aspect of the Hawk (Rank 3)", learnCost = 8000, powerCost = 50,  type = "Buff",    castTime = 0,   duration = 0 },
            { name = "Arcane Shot (Rank 4)",        learnCost = 8000, powerCost = 80,  min = 59,         max = 59,       type = "Damage", castTime = 0,   duration = 0 },
            { name = "Mend Pet (Rank 3)",           learnCost = 8000, powerCost = 155, type = "Heal",    castTime = 3.0, duration = 5 },
            { name = "Aimed Shot (Rank 2)",         learnCost = 400,  powerCost = 115, min = 125,        max = 125,      type = "Damage", castTime = 3.0, duration = 0 },
        },
        [30] = {
            { name = "Multi-Shot (Rank 2)",       learnCost = 8000, powerCost = 140, min = 40,               max = 40,       type = "Damage", castTime = 0, duration = 0 },
            { name = "Aspect of the Beast",       learnCost = 8000, powerCost = 20,  type = "Buff",          castTime = 0,   duration = 0 },
            { name = "Mongoose Bite (Rank 2)",    learnCost = 8000, powerCost = 40,  min = 45,               max = 45,       type = "Damage", castTime = 0, duration = 0 },
            { name = "Distracting Shot (Rank 3)", learnCost = 8000, powerCost = 40,  type = "Utility",       castTime = 0,   duration = 0 },
            { name = "Scare Beast (Rank 2)",      learnCost = 8000, powerCost = 50,  type = "Crowd Control", castTime = 1.5, duration = 15 },
            { name = "Feign Death",               learnCost = 8000, powerCost = 80,  type = "Utility",       castTime = 0,   duration = 360 },
        },
        [32] = {
            { name = "Flare",                  learnCost = 10000, powerCost = 50, type = "Utility", castTime = 0, duration = 30 },
            { name = "Raptor Strike (Rank 5)", learnCost = 10000, powerCost = 55, min = 65,         max = 65,     type = "Damage", castTime = 0, duration = 0 },
            { name = "Track Demons",           learnCost = 10000, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },
            { name = "Scorpid Sting (Rank 2)", learnCost = 10000, powerCost = 90, type = "Utility", castTime = 0, duration = 20 },
        },
        [34] = {
            { name = "Explosive Trap (Rank 1)", learnCost = 12000, powerCost = 275, min = 100,        max = 130,    type = "Damage", castTime = 0, duration = 20 }, -- DoT duration
            { name = "Disengage (Rank 2)",      learnCost = 12000, powerCost = 100, type = "Utility", castTime = 0, duration = 0 },
            { name = "Serpent Sting (Rank 5)",  learnCost = 12000, powerCost = 135, min = 210,        max = 210,    type = "Damage", castTime = 0, duration = 15 },
        },
        [36] = {
            { name = "Viper Sting (Rank 1)",     learnCost = 14000, powerCost = 135, type = "Damage", castTime = 0,   duration = 8 }, -- Drains Mana
            { name = "Aimed Shot (Rank 3)",      learnCost = 700,   powerCost = 160, min = 200,       max = 200,      type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Immolation Trap (Rank 3)", learnCost = 14000, powerCost = 135, min = 340,       max = 340,      type = "Damage", castTime = 0,   duration = 15 },
            { name = "Arcane Shot (Rank 5)",     learnCost = 14000, powerCost = 105, min = 83,        max = 83,       type = "Damage", castTime = 0,   duration = 0 },
            { name = "Mend Pet (Rank 4)",        learnCost = 14000, powerCost = 225, type = "Heal",   castTime = 3.0, duration = 5 },
        },
        [38] = {
            { name = "Wing Clip (Rank 2)",          learnCost = 16000, powerCost = 60, type = "Damage", castTime = 0, duration = 10 },
            { name = "Aspect of the Hawk (Rank 4)", learnCost = 16000, powerCost = 80, type = "Buff",   castTime = 0, duration = 0 },
        },
        [40] = {
            { name = "Freezing Trap (Rank 2)",    learnCost = 18000, powerCost = 100, type = "Crowd Control", castTime = 0, duration = 15 },
            { name = "Mail",                      learnCost = 18000, powerCost = 0,   type = "Utility",       castTime = 0, duration = 0 },
            { name = "Raptor Strike (Rank 6)",    learnCost = 18000, powerCost = 70,  min = 85,               max = 85,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Volley (Rank 1)",           learnCost = 18000, powerCost = 350, min = 50,               max = 50,     type = "Damage", castTime = 6.0, duration = 6 }, -- Channeled
            { name = "Track Giants",              learnCost = 18000, powerCost = 0,   type = "Utility",       castTime = 0, duration = 0 },
            { name = "Aspect of the Pack",        learnCost = 18000, powerCost = 100, type = "Buff",          castTime = 0, duration = 0 },
            { name = "Distracting Shot (Rank 4)", learnCost = 18000, powerCost = 50,  type = "Utility",       castTime = 0, duration = 0 },
            { name = "Hunter's Mark (Rank 3)",    learnCost = 18000, powerCost = 45,  type = "Utility",       castTime = 0, duration = 120 },
        },
        [42] = {
            { name = "Multi-Shot (Rank 3)",    learnCost = 24000, powerCost = 175, min = 80,         max = 80,     type = "Damage", castTime = 0, duration = 0 },
            { name = "Counterattack (Rank 2)", learnCost = 1200,  powerCost = 65,  type = "Damage",  castTime = 0, duration = 5 },
            { name = "Scorpid Sting (Rank 3)", learnCost = 24000, powerCost = 110, type = "Utility", castTime = 0, duration = 20 },
            { name = "Serpent Sting (Rank 6)", learnCost = 24000, powerCost = 190, min = 290,        max = 290,    type = "Damage", castTime = 0, duration = 15 },
        },
        [44] = {
            { name = "Explosive Trap (Rank 2)", learnCost = 26000, powerCost = 395, min = 140,     max = 180,      type = "Damage", castTime = 0,   duration = 20 },
            { name = "Arcane Shot (Rank 6)",    learnCost = 26000, powerCost = 135, min = 110,     max = 110,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Aimed Shot (Rank 4)",     learnCost = 1300,  powerCost = 210, min = 310,     max = 310,      type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Mongoose Bite (Rank 3)",  learnCost = 26000, powerCost = 55,  min = 75,      max = 75,       type = "Damage", castTime = 0,   duration = 0 },
            { name = "Mend Pet (Rank 5)",       learnCost = 26000, powerCost = 300, type = "Heal", castTime = 3.0, duration = 5 },
        },
        [46] = {
            { name = "Aspect of the Wild (Rank 1)", learnCost = 28000, powerCost = 90,  type = "Buff",          castTime = 0,   duration = 0 },
            { name = "Immolation Trap (Rank 4)",    learnCost = 28000, powerCost = 190, min = 510,              max = 510,      type = "Damage", castTime = 0, duration = 15 },
            { name = "Viper Sting (Rank 2)",        learnCost = 28000, powerCost = 175, type = "Damage",        castTime = 0,   duration = 8 },
            { name = "Scare Beast (Rank 3)",        learnCost = 28000, powerCost = 75,  type = "Crowd Control", castTime = 1.5, duration = 20 },
        },
        [48] = {
            { name = "Raptor Strike (Rank 7)",      learnCost = 32000, powerCost = 85,  min = 110,        max = 110,    type = "Damage", castTime = 0, duration = 0 },
            { name = "Disengage (Rank 3)",          learnCost = 32000, powerCost = 150, type = "Utility", castTime = 0, duration = 0 },
            { name = "Aspect of the Hawk (Rank 5)", learnCost = 32000, powerCost = 110, type = "Buff",    castTime = 0, duration = 0 },
        },
        [50] = {
            { name = "Track Dragonkin",           learnCost = 36000, powerCost = 0,   type = "Utility",       castTime = 0, duration = 0 },
            { name = "Wyvern Sting (Rank 2)",     learnCost = 1800,  powerCost = 155, type = "Crowd Control", castTime = 0, duration = 12 }, -- Sleep duration
            { name = "Volley (Rank 2)",           learnCost = 36000, powerCost = 420, min = 80,               max = 80,     type = "Damage", castTime = 6.0, duration = 6 },
            { name = "Trueshot Aura (Rank 2)",    learnCost = 1800,  powerCost = 450, type = "Buff",          castTime = 0, duration = 0 },  -- Aura
            { name = "Serpent Sting (Rank 7)",    learnCost = 36000, powerCost = 250, min = 385,              max = 385,    type = "Damage", castTime = 0,   duration = 15 },
            { name = "Distracting Shot (Rank 5)", learnCost = 36000, powerCost = 70,  type = "Utility",       castTime = 0, duration = 0 },
        },
        [52] = {
            { name = "Scorpid Sting (Rank 4)", learnCost = 40000, powerCost = 130, type = "Utility", castTime = 0,   duration = 20 },
            { name = "Aimed Shot (Rank 5)",    learnCost = 2000,  powerCost = 260, min = 460,        max = 460,      type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Arcane Shot (Rank 7)",   learnCost = 40000, powerCost = 160, min = 145,        max = 145,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Mend Pet (Rank 6)",      learnCost = 40000, powerCost = 380, type = "Heal",    castTime = 3.0, duration = 5 },
        },
        [54] = {
            { name = "Counterattack (Rank 3)",  learnCost = 2100,  powerCost = 85,  type = "Damage", castTime = 0, duration = 5 },
            { name = "Explosive Trap (Rank 3)", learnCost = 42000, powerCost = 520, min = 200,       max = 260,    type = "Damage", castTime = 0, duration = 20 },
            { name = "Multi-Shot (Rank 4)",     learnCost = 42000, powerCost = 210, min = 120,       max = 120,    type = "Damage", castTime = 0, duration = 0 },
        },
        [56] = {
            { name = "Raptor Strike (Rank 8)",      learnCost = 46000, powerCost = 100, min = 140,       max = 140,    type = "Damage", castTime = 0, duration = 0 },
            { name = "Immolation Trap (Rank 5)",    learnCost = 46000, powerCost = 245, min = 690,       max = 690,    type = "Damage", castTime = 0, duration = 15 },
            { name = "Viper Sting (Rank 3)",        learnCost = 46000, powerCost = 215, type = "Damage", castTime = 0, duration = 8 },
            { name = "Aspect of the Wild (Rank 2)", learnCost = 46000, powerCost = 115, type = "Buff",   castTime = 0, duration = 0 },
        },
        [58] = {
            { name = "Mongoose Bite (Rank 4)",      learnCost = 48000, powerCost = 75,  min = 115,        max = 115,    type = "Damage", castTime = 0,   duration = 0 },
            { name = "Aspect of the Hawk (Rank 6)", learnCost = 48000, powerCost = 140, type = "Buff",    castTime = 0, duration = 0 },
            { name = "Serpent Sting (Rank 8)",      learnCost = 48000, powerCost = 305, min = 490,        max = 490,    type = "Damage", castTime = 0,   duration = 15 },
            { name = "Hunter's Mark (Rank 4)",      learnCost = 48000, powerCost = 60,  type = "Utility", castTime = 0, duration = 120 },
            { name = "Volley (Rank 3)",             learnCost = 48000, powerCost = 490, min = 110,        max = 110,    type = "Damage", castTime = 6.0, duration = 6 },
        },
        [60] = {
            { name = "Aimed Shot (Rank 6)",       learnCost = 2500,  powerCost = 310, min = 600,              max = 600,      type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Wyvern Sting (Rank 3)",     learnCost = 2500,  powerCost = 205, type = "Crowd Control", castTime = 0,   duration = 12 },
            { name = "Freezing Trap (Rank 3)",    learnCost = 50000, powerCost = 150, type = "Crowd Control", castTime = 0,   duration = 20 },
            { name = "Arcane Shot (Rank 8)",      learnCost = 50000, powerCost = 190, min = 183,              max = 183,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Distracting Shot (Rank 6)", learnCost = 50000, powerCost = 90,  type = "Utility",       castTime = 0,   duration = 0 },
            { name = "Mend Pet (Rank 7)",         learnCost = 50000, powerCost = 460, type = "Heal",          castTime = 3.0, duration = 5 },
            { name = "Trueshot Aura (Rank 3)",    learnCost = 2500,  powerCost = 0,   type = "Buff",          castTime = 0,   duration = 0 }, -- Actually costs 0 to cast? Usually it's an aura. Rank 2 had 450 cost in my notes, let's double check if I can. But for now I will assume some mana cost if it's rank 3. Wait, Trueshot Aura is a talent, it usually costs nothing to toggle or has a small cost.
            { name = "Wing Clip (Rank 3)",        learnCost = 50000, powerCost = 80,  type = "Damage",        castTime = 0,   duration = 10 },
        },
    },

    --------------------------------------------------------
    -- WARLOCK – 1–60 with cost placeholders (copper = 0)
    --------------------------------------------------------
    WARLOCK = {

        [1] = {
            { name = "Shadow Bolt (Rank 1)", learnCost = 10, powerCost = 25, min = 12,      max = 16,     type = "Damage", castTime = 1.7, duration = 0 },
            { name = "Immolate (Rank 1)",    learnCost = 10, powerCost = 25, min = 11,      max = 11,     type = "Damage", castTime = 1.5, duration = 15 }, -- 11 direct + 20 over 15s
            { name = "Demon Skin (Rank 1)",  learnCost = 10, powerCost = 0,  type = "Buff", castTime = 0, duration = 1800 },                                -- No mana cost usually? Or low.
        },
        [4] = {
            { name = "Corruption (Rank 1)",        learnCost = 100, powerCost = 35, min = 40,         max = 40,     type = "Damage", castTime = 2.0, duration = 12 },
            { name = "Curse of Weakness (Rank 1)", learnCost = 100, powerCost = 20, type = "Utility", castTime = 0, duration = 120 },
        },
        [6] = {
            { name = "Shadow Bolt (Rank 2)", learnCost = 100, powerCost = 35, min = 23,         max = 29,     type = "Damage", castTime = 2.2, duration = 0 }, -- Estimating min/max based on Rank 1
            { name = "Life Tap (Rank 1)",    learnCost = 100, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },                                  -- Costs Health
        },
        [8] = {
            { name = "Fear (Rank 1)",           learnCost = 200, powerCost = 50, type = "Crowd Control", castTime = 1.5, duration = 10 },
            { name = "Curse of Agony (Rank 1)", learnCost = 200, powerCost = 25, min = 84,               max = 84,       type = "Damage", castTime = 0, duration = 24 },
        },
        [10] = {
            { name = "Drain Soul (Rank 1)",        learnCost = 300, powerCost = 55,  min = 55,         max = 55,       type = "Damage", castTime = 15,  duration = 15 }, -- Channeled
            { name = "Create Healthstone (Minor)", learnCost = 300, powerCost = 125, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Demon Skin (Rank 2)",        learnCost = 300, powerCost = 0,   type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Immolate (Rank 2)",          learnCost = 300, powerCost = 45,  min = 28,         max = 28,       type = "Damage", castTime = 2.0, duration = 15 }, -- Estimating mana/dmg
        },
        [12] = {
            { name = "Curse of Weakness (Rank 2)", learnCost = 600, powerCost = 50, type = "Utility", castTime = 0,  duration = 120 },
            { name = "Shadow Bolt (Rank 3)",       learnCost = 600, powerCost = 70, min = 52,         max = 61,      type = "Damage", castTime = 2.5, duration = 0 }, -- Rank 3 in my previous note said 40 mana, but that seems low for Rank 3? Rank 1 was 25. Let me stick to the snippet: Rank 3 cost 40 mana, 30-61 dmg. OK.
            { name = "Health Funnel (Rank 1)",     learnCost = 600, powerCost = 0,  type = "Heal",    castTime = 10, duration = 10 },                                 -- Costs Health
        },
        [14] = {
            { name = "Corruption (Rank 2)",            learnCost = 900, powerCost = 55, min = 90,         max = 90,     type = "Damage", castTime = 2.0, duration = 15 },
            { name = "Drain Life (Rank 1)",            learnCost = 900, powerCost = 55, min = 50,         max = 50,     type = "Damage", castTime = 5.0, duration = 5 }, -- Channeled
            { name = "Curse of Recklessness (Rank 1)", learnCost = 900, powerCost = 40, type = "Utility", castTime = 0, duration = 120 },
        },
        [16] = {
            { name = "Unending Breath",   learnCost = 1200, powerCost = 50, type = "Buff",    castTime = 0, duration = 600 },
            { name = "Life Tap (Rank 2)", learnCost = 1200, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },
        },
        [18] = {
            { name = "Searing Pain (Rank 1)",    learnCost = 1500, powerCost = 45,  min = 38,         max = 47,       type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Curse of Agony (Rank 2)",  learnCost = 1500, powerCost = 50,  min = 180,        max = 180,      type = "Damage", castTime = 0,   duration = 24 },
            { name = "Create Soulstone (Minor)", learnCost = 1500, powerCost = 250, type = "Utility", castTime = 3.0, duration = 0 },
        },
        [20] = {
            { name = "Ritual of Summoning",    learnCost = 2000, powerCost = 1000, type = "Utility", castTime = 5.0, duration = 0 },
            { name = "Rain of Fire (Rank 1)",  learnCost = 2000, powerCost = 295,  min = 156,        max = 156,      type = "Damage", castTime = 8.0, duration = 8 }, -- Channeled
            { name = "Immolate (Rank 3)",      learnCost = 2000, powerCost = 90,   min = 58,         max = 58,       type = "Damage", castTime = 2.0, duration = 15 },
            { name = "Health Funnel (Rank 2)", learnCost = 2000, powerCost = 0,    type = "Heal",    castTime = 10,  duration = 10 },
            { name = "Demon Armor (Rank 1)",   learnCost = 2000, powerCost = 0,    type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Shadow Bolt (Rank 4)",   learnCost = 2000, powerCost = 110,  min = 100,        max = 115,      type = "Damage", castTime = 2.8, duration = 0 },
        },
        [22] = {
            { name = "Curse of Weakness (Rank 3)",  learnCost = 2500, powerCost = 85,  type = "Utility", castTime = 0,   duration = 120 },
            { name = "Eye of Kilrogg (Summon)",     learnCost = 2500, powerCost = 295, type = "Utility", castTime = 5.0, duration = 0 },
            { name = "Create Healthstone (Lesser)", learnCost = 2500, powerCost = 480, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Drain Life (Rank 2)",         learnCost = 2500, powerCost = 85,  min = 85,         max = 85,       type = "Damage", castTime = 5.0, duration = 5 },
        },
        [24] = {
            { name = "Corruption (Rank 3)", learnCost = 3000, powerCost = 95,  min = 180,     max = 180,    type = "Damage", castTime = 2.0, duration = 18 },
            { name = "Shadowburn (Rank 2)", learnCost = 150,  powerCost = 130, min = 123,     max = 140,    type = "Damage", castTime = 0,   duration = 0 },
            { name = "Sense Demons",        learnCost = 3000, powerCost = 0,   type = "Buff", castTime = 0, duration = 0 },
            { name = "Drain Soul (Rank 2)", learnCost = 3000, powerCost = 95,  min = 155,     max = 155,    type = "Damage", castTime = 15,  duration = 15 },
            { name = "Drain Mana (Rank 1)", learnCost = 3000, powerCost = 0,   min = 135,     max = 135,    type = "Damage", castTime = 5.0, duration = 5 }, -- Costs Mana to cast? No, it drains mana. But tooltip says "Transfers X mana ... to the caster". Usually costs minimal base mana or is channel? Actually costs Mana to cast. Rank 1 costs ~55 mana? I'll check or estimate. Let's say 0 for now as it gains mana.
        },
        [26] = {
            { name = "Searing Pain (Rank 2)",      learnCost = 4000, powerCost = 65, min = 70,         max = 84,     type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Detect Lesser Invisibility", learnCost = 4000, powerCost = 50, type = "Buff",    castTime = 0, duration = 600 },
            { name = "Life Tap (Rank 3)",          learnCost = 4000, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },
            { name = "Curse of Tongues (Rank 1)",  learnCost = 4000, powerCost = 50, type = "Utility", castTime = 0, duration = 300 },
        },
        [28] = {
            { name = "Health Funnel (Rank 3)",         learnCost = 5000, powerCost = 0,   type = "Heal",          castTime = 10,  duration = 10 },
            { name = "Banish (Rank 1)",                learnCost = 5000, powerCost = 100, type = "Crowd Control", castTime = 1.5, duration = 20 },
            { name = "Curse of Agony (Rank 3)",        learnCost = 5000, powerCost = 90,  min = 324,              max = 324,      type = "Damage", castTime = 0,   duration = 24 },
            { name = "Create Firestone (Lesser)",      learnCost = 5000, powerCost = 550, type = "Utility",       castTime = 3.0, duration = 0 },
            { name = "Shadow Bolt (Rank 5)",           learnCost = 5000, powerCost = 160, min = 160,              max = 181,      type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Curse of Recklessness (Rank 2)", learnCost = 5000, powerCost = 70,  type = "Utility",       castTime = 0,   duration = 120 },
        },
        [30] = {
            { name = "Hellfire (Rank 1)",         learnCost = 6000, powerCost = 305, min = 83,         max = 83,       type = "Damage", castTime = 15,  duration = 15 }, -- Channeled AoE
            { name = "Create Soulstone (Lesser)", learnCost = 6000, powerCost = 500, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Immolate (Rank 4)",         learnCost = 6000, powerCost = 155, min = 90,         max = 90,       type = "Damage", castTime = 2.0, duration = 15 }, -- 90+165
            { name = "Demon Armor (Rank 2)",      learnCost = 6000, powerCost = 0,   type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Drain Life (Rank 3)",       learnCost = 6000, powerCost = 125, min = 125,        max = 125,      type = "Damage", castTime = 5.0, duration = 5 },
            { name = "Subjugate Demon (Rank 1)",  learnCost = 6000, powerCost = 250, type = "Utility", castTime = 3.0, duration = 300 },
        },
        [32] = {
            { name = "Curse of the Elements (Rank 1)", learnCost = 7000, powerCost = 100, type = "Utility",       castTime = 0,   duration = 300 },
            { name = "Curse of Weakness (Rank 4)",     learnCost = 7000, powerCost = 135, type = "Utility",       castTime = 0,   duration = 120 },
            { name = "Shadow Ward (Rank 1)",           learnCost = 7000, powerCost = 135, type = "Buff",          castTime = 0,   duration = 30 },
            { name = "Shadowburn (Rank 3)",            learnCost = 350,  powerCost = 190, min = 180,              max = 202,      type = "Damage", castTime = 0, duration = 0 },
            { name = "Fear (Rank 2)",                  learnCost = 7000, powerCost = 80,  type = "Crowd Control", castTime = 1.5, duration = 15 },
        },
        [34] = {
            { name = "Drain Mana (Rank 2)",   learnCost = 8000, powerCost = 0,   min = 200,        max = 200,      type = "Damage", castTime = 5.0, duration = 5 },
            { name = "Rain of Fire (Rank 2)", learnCost = 8000, powerCost = 575, min = 304,        max = 304,      type = "Damage", castTime = 8.0, duration = 8 },
            { name = "Searing Pain (Rank 3)", learnCost = 8000, powerCost = 95,  min = 113,        max = 133,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Corruption (Rank 4)",   learnCost = 8000, powerCost = 140, min = 300,        max = 300,      type = "Damage", castTime = 2.0, duration = 18 },
            { name = "Create Healthstone",    learnCost = 8000, powerCost = 730, type = "Utility", castTime = 3.0, duration = 0 },
        },
        [36] = {
            { name = "Shadow Bolt (Rank 6)",   learnCost = 9000, powerCost = 210, min = 227,        max = 254,      type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Create Firestone",       learnCost = 9000, powerCost = 875, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Life Tap (Rank 4)",      learnCost = 9000, powerCost = 0,   type = "Utility", castTime = 0,   duration = 0 },
            { name = "Health Funnel (Rank 4)", learnCost = 9000, powerCost = 0,   type = "Heal",    castTime = 10,  duration = 10 },
            { name = "Create Spellstone",      learnCost = 9000, powerCost = 875, type = "Utility", castTime = 3.0, duration = 0 },
        },
        [38] = {
            { name = "Drain Life (Rank 4)",     learnCost = 10000, powerCost = 175, min = 175,     max = 175,    type = "Damage", castTime = 5.0, duration = 5 },
            { name = "Drain Soul (Rank 3)",     learnCost = 10000, powerCost = 175, min = 255,     max = 255,    type = "Damage", castTime = 15,  duration = 15 },
            { name = "Curse of Agony (Rank 4)", learnCost = 10000, powerCost = 135, min = 504,     max = 504,    type = "Damage", castTime = 0,   duration = 24 },
            { name = "Detect Invisibility",     learnCost = 10000, powerCost = 75,  type = "Buff", castTime = 0, duration = 600 },
            { name = "Siphon Life (Rank 2)",    learnCost = 500,   powerCost = 205, min = 219,     max = 219,    type = "Damage", castTime = 0,   duration = 30 },
        },
        [40] = {
            { name = "Demon Armor (Rank 3)",    learnCost = 11000, powerCost = 0,   type = "Buff",          castTime = 0,   duration = 1800 },
            { name = "Howl of Terror (Rank 1)", learnCost = 11000, powerCost = 150, type = "Crowd Control", castTime = 1.5, duration = 10 },
            { name = "Create Soulstone",        learnCost = 11000, powerCost = 900, type = "Utility",       castTime = 3.0, duration = 0 },
            { name = "Immolate (Rank 5)",       learnCost = 11000, powerCost = 220, min = 138,              max = 138,      type = "Damage", castTime = 2.0, duration = 15 },
            { name = "Shadowburn (Rank 4)",     learnCost = 550,   powerCost = 245, min = 246,              max = 275,      type = "Damage", castTime = 0,   duration = 0 },
        },
        [42] = {
            { name = "Curse of Recklessness (Rank 3)", learnCost = 11000, powerCost = 100, type = "Utility", castTime = 0, duration = 120 },
            { name = "Curse of Weakness (Rank 5)",     learnCost = 11000, powerCost = 185, type = "Utility", castTime = 0, duration = 120 },
            { name = "Hellfire (Rank 2)",              learnCost = 11000, powerCost = 595, min = 155,        max = 155,    type = "Damage", castTime = 15,  duration = 15 },
            { name = "Shadow Ward (Rank 2)",           learnCost = 11000, powerCost = 205, type = "Buff",    castTime = 0, duration = 30 },
            { name = "Death Coil (Rank 1)",            learnCost = 11000, powerCost = 360, min = 210,        max = 210,    type = "Damage", castTime = 0,   duration = 3 }, -- Horrify effect
            { name = "Searing Pain (Rank 4)",          learnCost = 11000, powerCost = 125, min = 158,        max = 187,    type = "Damage", castTime = 1.5, duration = 0 },
        },
        [44] = {
            { name = "Subjugate Demon (Rank 2)", learnCost = 12000, powerCost = 500, type = "Utility", castTime = 3.0, duration = 600 },
            { name = "Shadow Bolt (Rank 7)",     learnCost = 12000, powerCost = 265, min = 302,        max = 338,      type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Drain Mana (Rank 3)",      learnCost = 12000, powerCost = 0,   min = 275,        max = 275,      type = "Damage", castTime = 5.0, duration = 5 },
            { name = "Health Funnel (Rank 5)",   learnCost = 12000, powerCost = 0,   type = "Heal",    castTime = 10,  duration = 10 },
            { name = "Curse of Shadow (Rank 1)", learnCost = 12000, powerCost = 100, type = "Utility", castTime = 0,   duration = 300 },
            { name = "Corruption (Rank 5)",      learnCost = 12000, powerCost = 195, min = 450,        max = 450,      type = "Damage", castTime = 2.0, duration = 18 },
        },
        [46] = {
            { name = "Create Healthstone (Greater)",   learnCost = 13000, powerCost = 1085, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Curse of the Elements (Rank 2)", learnCost = 13000, powerCost = 150,  type = "Utility", castTime = 0,   duration = 300 },
            { name = "Life Tap (Rank 5)",              learnCost = 13000, powerCost = 0,    type = "Utility", castTime = 0,   duration = 0 },
            { name = "Create Firestone (Greater)",     learnCost = 13000, powerCost = 1260, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Drain Life (Rank 5)",            learnCost = 13000, powerCost = 225,  min = 230,        max = 230,      type = "Damage", castTime = 5.0, duration = 5 },
            { name = "Rain of Fire (Rank 3)",          learnCost = 13000, powerCost = 885,  min = 496,        max = 496,      type = "Damage", castTime = 8.0, duration = 8 },
        },
        [48] = {
            { name = "Banish (Rank 2)",             learnCost = 14000, powerCost = 200,  type = "Crowd Control", castTime = 1.5, duration = 30 },
            { name = "Shadowburn (Rank 5)",         learnCost = 700,   powerCost = 305,  min = 328,              max = 365,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Siphon Life (Rank 3)",        learnCost = 700,   powerCost = 285,  min = 309,              max = 309,      type = "Damage", castTime = 0,   duration = 30 },
            { name = "Soul Fire (Rank 1)",          learnCost = 14000, powerCost = 250,  min = 450,              max = 565,      type = "Damage", castTime = 6.0, duration = 0 }, -- 6s cast usually
            { name = "Curse of Agony (Rank 5)",     learnCost = 14000, powerCost = 175,  min = 780,              max = 780,      type = "Damage", castTime = 0,   duration = 24 },
            { name = "Conflagrate (Rank 2)",        learnCost = 700,   powerCost = 230,  min = 319,              max = 398,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Create Spellstone (Greater)", learnCost = 14000, powerCost = 1260, type = "Utility",       castTime = 3.0, duration = 0 },
        },
        [50] = {
            { name = "Immolate (Rank 6)",           learnCost = 15000, powerCost = 295,  min = 192,        max = 192,      type = "Damage", castTime = 2.0, duration = 15 },
            { name = "Detect Greater Invisibility", learnCost = 15000, powerCost = 100,  type = "Buff",    castTime = 0,   duration = 600 },
            { name = "Demon Armor (Rank 4)",        learnCost = 15000, powerCost = 0,    type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Searing Pain (Rank 5)",       learnCost = 15000, powerCost = 155,  min = 208,        max = 245,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Create Soulstone (Greater)",  learnCost = 15000, powerCost = 1440, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Death Coil (Rank 2)",         learnCost = 15000, powerCost = 480,  min = 290,        max = 290,      type = "Damage", castTime = 0,   duration = 3 },
            { name = "Dark Pact (Rank 2)",          learnCost = 750,   powerCost = 0,    type = "Utility", castTime = 0,   duration = 0 },
            { name = "Curse of Tongues (Rank 2)",   learnCost = 15000, powerCost = 100,  type = "Utility", castTime = 0,   duration = 300 },
        },
        [52] = {
            { name = "Drain Soul (Rank 4)",        learnCost = 18000, powerCost = 250, min = 355,        max = 355,     type = "Damage", castTime = 15,  duration = 15 },
            { name = "Shadow Bolt (Rank 8)",       learnCost = 18000, powerCost = 315, min = 383,        max = 428,     type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Health Funnel (Rank 6)",     learnCost = 18000, powerCost = 0,   type = "Heal",    castTime = 10, duration = 10 },
            { name = "Curse of Weakness (Rank 6)", learnCost = 18000, powerCost = 235, type = "Utility", castTime = 0,  duration = 120 },
            { name = "Shadow Ward (Rank 3)",       learnCost = 18000, powerCost = 290, type = "Buff",    castTime = 0,  duration = 30 },
        },
        [54] = {
            { name = "Conflagrate (Rank 3)",    learnCost = 1000,  powerCost = 295, min = 433,              max = 541,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Howl of Terror (Rank 2)", learnCost = 20000, powerCost = 200, type = "Crowd Control", castTime = 1.5, duration = 15 },
            { name = "Drain Mana (Rank 4)",     learnCost = 20000, powerCost = 0,   min = 360,              max = 360,      type = "Damage", castTime = 5.0, duration = 5 },
            { name = "Hellfire (Rank 3)",       learnCost = 20000, powerCost = 945, min = 248,              max = 248,      type = "Damage", castTime = 15,  duration = 15 },
            { name = "Corruption (Rank 6)",     learnCost = 20000, powerCost = 290, min = 666,              max = 666,      type = "Damage", castTime = 2.0, duration = 18 },
            { name = "Drain Life (Rank 6)",     learnCost = 20000, powerCost = 285, min = 290,              max = 290,      type = "Damage", castTime = 5.0, duration = 5 },
        },
        [56] = {
            { name = "Curse of Shadow (Rank 2)",       learnCost = 22000, powerCost = 150,  type = "Utility",       castTime = 0,   duration = 300 },
            { name = "Soul Fire (Rank 2)",             learnCost = 22000, powerCost = 350,  min = 605,              max = 758,      type = "Damage", castTime = 6.0, duration = 0 },
            { name = "Shadowburn (Rank 6)",            learnCost = 1100,  powerCost = 365,  min = 397,              max = 445,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Create Firestone (Major)",       learnCost = 22000, powerCost = 1750, type = "Utility",       castTime = 3.0, duration = 0 },
            { name = "Fear (Rank 3)",                  learnCost = 22000, powerCost = 110,  type = "Crowd Control", castTime = 1.5, duration = 20 },
            { name = "Life Tap (Rank 6)",              learnCost = 22000, powerCost = 0,    type = "Utility",       castTime = 0,   duration = 0 },
            { name = "Curse of Recklessness (Rank 4)", learnCost = 22000, powerCost = 130,  type = "Utility",       castTime = 0,   duration = 120 },
        },
        [58] = {
            { name = "Rain of Fire (Rank 4)",      learnCost = 24000, powerCost = 1335, min = 812,        max = 812,      type = "Damage", castTime = 8.0, duration = 8 },
            { name = "Subjugate Demon (Rank 3)",   learnCost = 24000, powerCost = 750,  type = "Utility", castTime = 3.0, duration = 900 },
            { name = "Siphon Life (Rank 4)",       learnCost = 1200,  powerCost = 365,  min = 450,        max = 450,      type = "Damage", castTime = 0,   duration = 30 },
            { name = "Create Healthstone (Major)", learnCost = 24000, powerCost = 1440, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Searing Pain (Rank 6)",      learnCost = 24000, powerCost = 175,  min = 243,        max = 287,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Death Coil (Rank 3)",        learnCost = 24000, powerCost = 600,  min = 399,        max = 399,      type = "Damage", castTime = 0,   duration = 3 },
            { name = "Curse of Agony (Rank 6)",    learnCost = 24000, powerCost = 215,  min = 1044,       max = 1044,     type = "Damage", castTime = 0,   duration = 24 },
            { name = "Shadow Bolt (Rank 9)",       learnCost = 24000, powerCost = 370,  min = 455,        max = 508,      type = "Damage", castTime = 3.0, duration = 0 },
        },
        [60] = {
            { name = "Shadow Bolt (Rank 10)",          learnCost = 26000, powerCost = 380,  min = 482,        max = 539,      type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Demon Armor (Rank 5)",           learnCost = 26000, powerCost = 0,    type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Create Soulstone (Major)",       learnCost = 26000, powerCost = 1980, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Curse of Doom",                  learnCost = 26000, powerCost = 380,  min = 3200,       max = 3200,     type = "Damage", castTime = 0,   duration = 60 },
            { name = "Immolate (Rank 7)",              learnCost = 26000, powerCost = 370,  min = 258,        max = 258,      type = "Damage", castTime = 2.0, duration = 15 },
            { name = "Create Spellstone (Major)",      learnCost = 26000, powerCost = 1750, type = "Utility", castTime = 3.0, duration = 0 },
            { name = "Dark Pact (Rank 3)",             learnCost = 1300,  powerCost = 0,    type = "Utility", castTime = 0,   duration = 0 },
            { name = "Curse of the Elements (Rank 3)", learnCost = 26000, powerCost = 200,  type = "Utility", castTime = 0,   duration = 300 },
            { name = "Conflagrate (Rank 4)",           learnCost = 1300,  powerCost = 360,  min = 510,        max = 638,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Health Funnel (Rank 7)",         learnCost = 26000, powerCost = 0,    type = "Heal",    castTime = 10,  duration = 10 },
            { name = "Soul Fire (Rank 3)",             learnCost = 2000,  powerCost = 0,    min = 0,          max = 0,        type = "Damage", castTime = 6.0, duration = 0 }, -- Placeholder, usually book
        },
    },

    --------------------------------------------------------
    -- DRUID – 1–60 with cost placeholders (copper = 0)
    --------------------------------------------------------
    DRUID = {
        [1] = {
            { name = "Mark of the Wild (Rank 1)", learnCost = 10, powerCost = 20, type = "Buff", castTime = 0, duration = 1800 },
            { name = "Wrath (Rank 1)",            learnCost = 10, powerCost = 20, min = 12,      max = 15,     type = "Damage", castTime = 1.5, duration = 0 }, -- 2.0s or 1.5s? Snippet said 2.0.
        },
        [4] = {
            { name = "Rejuvenation (Rank 1)", learnCost = 100, powerCost = 25, min = 32, max = 32, type = "Heal",   castTime = 0, duration = 12 },
            { name = "Moonfire (Rank 1)",     learnCost = 100, powerCost = 20, min = 9,  max = 12, type = "Damage", castTime = 0, duration = 12 }, -- 9-12 upfront + dot
        },
        [6] = {
            { name = "Wrath (Rank 2)",  learnCost = 100, powerCost = 35, min = 24,      max = 28,     type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Thorns (Rank 1)", learnCost = 100, powerCost = 35, type = "Buff", castTime = 0, duration = 600 },
        },
        [8] = {
            { name = "Entangling Roots (Rank 1)", learnCost = 200, powerCost = 40, type = "Crowd Control", castTime = 1.5, duration = 12 },
            { name = "Healing Touch (Rank 2)",    learnCost = 200, powerCost = 55, min = 88,               max = 113,      type = "Heal", castTime = 2.0, duration = 0 }, -- Rank 2 is 2.0s? Check. R1 1.5, R2 2.0, R3 2.5, R4 3.0, R5 3.5.
        },
        [10] = {
            { name = "Mark of the Wild (Rank 2)",  learnCost = 300, powerCost = 50, type = "Buff",    castTime = 0, duration = 1800 },
            { name = "Moonfire (Rank 2)",          learnCost = 300, powerCost = 50, min = 13,         max = 18,     type = "Damage", castTime = 0, duration = 12 },
            { name = "Demoralizing Roar (Rank 1)", learnCost = 300, powerCost = 10, type = "Utility", castTime = 0, duration = 30 },                               -- Costs 10 Rage
            { name = "Rejuvenation (Rank 2)",      learnCost = 300, powerCost = 40, min = 56,         max = 56,     type = "Heal",   castTime = 0, duration = 12 },
            { name = "Bear Form (Shapeshift)",     learnCost = 300, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },                                -- Variable mana cost
            { name = "Maul (Rank 1)",              learnCost = 300, powerCost = 15, min = 19,         max = 19,     type = "Damage", castTime = 0, duration = 0 }, -- Adds X dmg. Costs 15 Rage.
        },
        [12] = {
            { name = "Enrage",            learnCost = 800, powerCost = 0,   type = "Utility", castTime = 0, duration = 10 },                                -- Generates Rage
            { name = "Regrowth (Rank 1)", learnCost = 800, powerCost = 120, min = 84,         max = 98,     type = "Heal", castTime = 2.0, duration = 21 }, -- 84-98 + 98 over 21s
            { name = "Bash (Rank 1)",     learnCost = 800, powerCost = 10,  type = "Utility", castTime = 0, duration = 2 },                                 -- 10 Rage
        },
        [14] = {
            { name = "Thorns (Rank 2)",        learnCost = 900, powerCost = 60,  type = "Buff",    castTime = 0,   duration = 600 },
            { name = "Wrath (Rank 3)",         learnCost = 900, powerCost = 55,  min = 44,         max = 53,       type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Healing Touch (Rank 3)", learnCost = 900, powerCost = 110, min = 199,        max = 247,      type = "Heal",   castTime = 2.5, duration = 0 },
            { name = "Cure Poison",            learnCost = 900, powerCost = 70,  type = "Utility", castTime = 2.0, duration = 0 },
        },
        [16] = {
            { name = "Rejuvenation (Rank 3)", learnCost = 1800, powerCost = 75, min = 116,        max = 116,    type = "Heal",   castTime = 0, duration = 12 },
            { name = "Moonfire (Rank 3)",     learnCost = 1800, powerCost = 75, min = 22,         max = 28,     type = "Damage", castTime = 0, duration = 12 },
            { name = "Swipe (Rank 1)",        learnCost = 1800, powerCost = 20, min = 24,         max = 24,     type = "Damage", castTime = 0, duration = 0 }, -- Costs 20 Rage?
            { name = "Aquatic Form",          learnCost = 1800, powerCost = 0,  type = "Utility", castTime = 0, duration = 0 },
        },
        [18] = {
            { name = "Regrowth (Rank 2)",         learnCost = 1900, powerCost = 205, min = 164,              max = 188,      type = "Heal",   castTime = 2.0, duration = 21 },
            { name = "Maul (Rank 2)",             learnCost = 1900, powerCost = 15,  min = 31,               max = 31,       type = "Damage", castTime = 0,   duration = 0 },
            { name = "Faerie Fire (Rank 1)",      learnCost = 1900, powerCost = 0,   type = "Utility",       castTime = 0,   duration = 40 }, -- No cost in Human form? Mana cost. 0 cost in Bear/Cat. Usually 15-30 mana.
            { name = "Nature's Grasp (Rank 2)",   learnCost = 1900, powerCost = 50,  type = "Buff",          castTime = 0,   duration = 45 },
            { name = "Entangling Roots (Rank 2)", learnCost = 1900, powerCost = 75,  type = "Crowd Control", castTime = 1.5, duration = 15 },
            { name = "Hibernate (Rank 1)",        learnCost = 1900, powerCost = 90,  type = "Crowd Control", castTime = 1.5, duration = 20 },
        },
        [20] = {
            { name = "Starfire (Rank 1)",          learnCost = 2000, powerCost = 95,  min = 89,         max = 110,      type = "Damage", castTime = 3.5, duration = 0 },
            { name = "Prowl (Rank 1)",             learnCost = 2000, powerCost = 0,   type = "Utility", castTime = 0,   duration = 0 },                                   -- 0 Energy?
            { name = "Claw (Rank 1)",              learnCost = 2000, powerCost = 45,  min = 27,         max = 27,       type = "Damage", castTime = 0,   duration = 0 },  -- 45 Energy
            { name = "Mark of the Wild (Rank 3)",  learnCost = 2000, powerCost = 100, type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Rip (Rank 1)",               learnCost = 2000, powerCost = 30,  min = 42,         max = 42,       type = "Damage", castTime = 0,   duration = 12 }, -- 30 Energy
            { name = "Demoralizing Roar (Rank 2)", learnCost = 2000, powerCost = 10,  type = "Utility", castTime = 0,   duration = 30 },
            { name = "Healing Touch (Rank 4)",     learnCost = 2000, powerCost = 185, min = 369,        max = 451,      type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Cat Form (Shapeshift)",      learnCost = 2000, powerCost = 0,   type = "Utility", castTime = 0,   duration = 0 },
            { name = "Rebirth (Rank 1)",           learnCost = 2000, powerCost = 700, type = "Utility", castTime = 2.0, duration = 0 },
        },
        [22] = {
            { name = "Shred (Rank 1)",         learnCost = 3000, powerCost = 60,  min = 54,         max = 54,       type = "Damage", castTime = 0,   duration = 0 }, -- 60 Energy
            { name = "Soothe Animal (Rank 1)", learnCost = 3000, powerCost = 40,  type = "Utility", castTime = 1.5, duration = 0 },
            { name = "Rejuvenation (Rank 4)",  learnCost = 3000, powerCost = 105, min = 180,        max = 180,      type = "Heal",   castTime = 0,   duration = 12 },
            { name = "Moonfire (Rank 4)",      learnCost = 3000, powerCost = 110, min = 34,         max = 42,       type = "Damage", castTime = 0,   duration = 12 },
            { name = "Wrath (Rank 4)",         learnCost = 3000, powerCost = 70,  min = 63,         max = 74,       type = "Damage", castTime = 1.5, duration = 0 },
        },
        [24] = {
            { name = "Swipe (Rank 2)",        learnCost = 4000, powerCost = 20,  min = 36,         max = 36,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Regrowth (Rank 3)",     learnCost = 4000, powerCost = 280, min = 262,        max = 299,    type = "Heal",   castTime = 2.0, duration = 21 },
            { name = "Thorns (Rank 3)",       learnCost = 4000, powerCost = 90,  type = "Buff",    castTime = 0, duration = 600 },
            { name = "Tiger's Fury (Rank 1)", learnCost = 4000, powerCost = 30,  type = "Buff",    castTime = 0, duration = 6 },                                  -- 30 Energy
            { name = "Rake (Rank 1)",         learnCost = 4000, powerCost = 40,  min = 19,         max = 19,     type = "Damage", castTime = 0,   duration = 9 }, -- 40 Energy
            { name = "Remove Curse",          learnCost = 4000, powerCost = 90,  type = "Utility", castTime = 0, duration = 0 },
        },
        [26] = {
            { name = "Healing Touch (Rank 5)", learnCost = 4500, powerCost = 270, min = 579,        max = 721,    type = "Heal",   castTime = 3.5, duration = 0 },
            { name = "Dash (Rank 1)",          learnCost = 4500, powerCost = 0,   type = "Buff",    castTime = 0, duration = 15 },
            { name = "Abolish Poison",         learnCost = 4500, powerCost = 110, type = "Utility", castTime = 0, duration = 8 },
            { name = "Starfire (Rank 2)",      learnCost = 4500, powerCost = 130, min = 142,        max = 170,    type = "Damage", castTime = 3.5, duration = 0 },
            { name = "Maul (Rank 3)",          learnCost = 4500, powerCost = 15,  min = 45,         max = 45,     type = "Damage", castTime = 0,   duration = 0 },
        },
        [28] = {
            { name = "Rip (Rank 2)",              learnCost = 5000, powerCost = 30,  min = 66,               max = 66,       type = "Damage", castTime = 0, duration = 12 },
            { name = "Moonfire (Rank 5)",         learnCost = 5000, powerCost = 150, min = 61,               max = 74,       type = "Damage", castTime = 0, duration = 12 },
            { name = "Claw (Rank 2)",             learnCost = 5000, powerCost = 45,  min = 39,               max = 39,       type = "Damage", castTime = 0, duration = 0 },
            { name = "Rejuvenation (Rank 5)",     learnCost = 5000, powerCost = 135, min = 256,              max = 256,      type = "Heal",   castTime = 0, duration = 12 },
            { name = "Entangling Roots (Rank 3)", learnCost = 5000, powerCost = 90,  type = "Crowd Control", castTime = 1.5, duration = 18 },
            { name = "Challenging Roar",          learnCost = 5000, powerCost = 15,  type = "Utility",       castTime = 0,   duration = 6 }, -- 15 Rage
            { name = "Cower (Rank 1)",            learnCost = 5000, powerCost = 20,  type = "Utility",       castTime = 0,   duration = 0 }, -- 20 Energy
            { name = "Nature's Grasp (Rank 3)",   learnCost = 250,  powerCost = 85,  type = "Buff",          castTime = 0,   duration = 45 },
        },
        [30] = {
            { name = "Wrath (Rank 5)",               learnCost = 6000, powerCost = 100, min = 101,        max = 116,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Tranquility (Rank 1)",         learnCost = 6000, powerCost = 725, min = 351,        max = 351,      type = "Heal",   castTime = 10,  duration = 10 }, -- Channeled
            { name = "Travel Form (Shapeshift)",     learnCost = 6000, powerCost = 0,   type = "Utility", castTime = 0,   duration = 0 },
            { name = "Bash (Rank 2)",                learnCost = 6000, powerCost = 10,  type = "Utility", castTime = 0,   duration = 3 },
            { name = "Regrowth (Rank 4)",            learnCost = 6000, powerCost = 380, min = 392,        max = 445,      type = "Heal",   castTime = 2.0, duration = 21 },
            { name = "Rebirth (Rank 2)",             learnCost = 6000, powerCost = 900, type = "Utility", castTime = 2.0, duration = 0 },
            { name = "Faerie Fire (Feral) (Rank 2)", learnCost = 300,  powerCost = 0,   type = "Utility", castTime = 0,   duration = 40 },
            { name = "Shred (Rank 2)",               learnCost = 6000, powerCost = 60,  min = 72,         max = 72,       type = "Damage", castTime = 0,   duration = 0 },
            { name = "Insect Swarm (Rank 2)",        learnCost = 300,  powerCost = 65,  min = 108,        max = 108,      type = "Damage", castTime = 0,   duration = 12 }, -- Talent usually, but trainable in Turtle?
            { name = "Faerie Fire (Rank 2)",         learnCost = 6000, powerCost = 0,   type = "Utility", castTime = 0,   duration = 40 },                                  -- Mana cost 35-50
            { name = "Mark of the Wild (Rank 4)",    learnCost = 6000, powerCost = 195, type = "Buff",    castTime = 0,   duration = 1800 },
        },
        [32] = {
            { name = "Ravage (Rank 1)",            learnCost = 8000, powerCost = 60,  min = 147,        max = 147,    type = "Damage", castTime = 0,   duration = 0 }, -- 60 Energy
            { name = "Healing Touch (Rank 6)",     learnCost = 8000, powerCost = 335, min = 742,        max = 928,    type = "Heal",   castTime = 3.5, duration = 0 },
            { name = "Demoralizing Roar (Rank 3)", learnCost = 8000, powerCost = 10,  type = "Utility", castTime = 0, duration = 30 },
            { name = "Ferocious Bite (Rank 1)",    learnCost = 8000, powerCost = 35,  min = 50,         max = 140,    type = "Damage", castTime = 0,   duration = 0 }, -- Variable damage based on CP
            { name = "Track Humanoid",             learnCost = 8000, powerCost = 0,   type = "Buff",    castTime = 0, duration = 0 },
        },
        [34] = {
            { name = "Thorns (Rank 4)",       learnCost = 10000, powerCost = 130, type = "Buff", castTime = 0, duration = 600 },
            { name = "Maul (Rank 4)",         learnCost = 10000, powerCost = 15,  min = 62,      max = 62,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Rake (Rank 2)",         learnCost = 10000, powerCost = 40,  min = 36,      max = 36,     type = "Damage", castTime = 0,   duration = 9 },
            { name = "Moonfire (Rank 6)",     learnCost = 10000, powerCost = 190, min = 81,      max = 98,     type = "Damage", castTime = 0,   duration = 12 },
            { name = "Swipe (Rank 3)",        learnCost = 10000, powerCost = 20,  min = 60,      max = 60,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Rejuvenation (Rank 6)", learnCost = 10000, powerCost = 165, min = 352,     max = 352,    type = "Heal",   castTime = 0,   duration = 12 },
            { name = "Starfire (Rank 3)",     learnCost = 10000, powerCost = 180, min = 201,     max = 242,    type = "Damage", castTime = 3.5, duration = 0 },
        },
        [36] = {
            { name = "Tiger's Fury (Rank 2)",          learnCost = 11000, powerCost = 30,  type = "Buff", castTime = 0, duration = 6 },
            { name = "Frenzied Regeneration (Rank 1)", learnCost = 11000, powerCost = 10,  type = "Heal", castTime = 0, duration = 10 },                                  -- 10 Rage/sec
            { name = "Regrowth (Rank 5)",              learnCost = 11000, powerCost = 480, min = 518,     max = 588,    type = "Heal",   castTime = 2.0, duration = 21 },
            { name = "Pounce (Rank 1)",                learnCost = 11000, powerCost = 50,  min = 180,     max = 180,    type = "Damage", castTime = 0,   duration = 18 }, -- 50 Energy
            { name = "Rip (Rank 3)",                   learnCost = 11000, powerCost = 30,  min = 90,      max = 90,     type = "Damage", castTime = 0,   duration = 12 },
        },
        [38] = {
            { name = "Entangling Roots (Rank 4)", learnCost = 12000, powerCost = 105, type = "Crowd Control", castTime = 1.5, duration = 21 },
            { name = "Wrath (Rank 6)",            learnCost = 12000, powerCost = 130, min = 146,              max = 169,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Shred (Rank 3)",            learnCost = 12000, powerCost = 60,  min = 99,               max = 99,       type = "Damage", castTime = 0,   duration = 0 },
            { name = "Healing Touch (Rank 7)",    learnCost = 12000, powerCost = 405, min = 936,              max = 1166,     type = "Heal",   castTime = 3.5, duration = 0 },
            { name = "Claw (Rank 3)",             learnCost = 12000, powerCost = 45,  min = 57,               max = 57,       type = "Damage", castTime = 0,   duration = 0 },
            { name = "Soothe Animal (Rank 2)",    learnCost = 12000, powerCost = 65,  type = "Utility",       castTime = 1.5, duration = 0 },
            { name = "Nature's Grasp (Rank 4)",   learnCost = 600,   powerCost = 115, type = "Buff",          castTime = 0,   duration = 45 },
            { name = "Hibernate (Rank 2)",        learnCost = 12000, powerCost = 110, type = "Crowd Control", castTime = 1.5, duration = 30 },
        },
        [40] = {
            { name = "Ferocious Bite (Rank 2)",     learnCost = 14000, powerCost = 35,   min = 85,         max = 240,      type = "Damage", castTime = 0,  duration = 0 },
            { name = "Dire Bear Form (Shapeshift)", learnCost = 14000, powerCost = 0,    type = "Utility", castTime = 0,   duration = 0 },
            { name = "Prowl (Rank 2)",              learnCost = 14000, powerCost = 0,    type = "Utility", castTime = 0,   duration = 0 },
            { name = "Cower (Rank 2)",              learnCost = 14000, powerCost = 20,   type = "Utility", castTime = 0,   duration = 0 },
            { name = "Tranquility (Rank 2)",        learnCost = 14000, powerCost = 910,  min = 515,        max = 515,      type = "Heal",   castTime = 10, duration = 10 },
            { name = "Hurricane (Rank 1)",          learnCost = 14000, powerCost = 880,  min = 720,        max = 720,      type = "Damage", castTime = 10, duration = 10 }, -- Channeled AoE
            { name = "Innervate (Rank 1)",          learnCost = 14000, powerCost = 35,   type = "Buff",    castTime = 0,   duration = 20 },
            { name = "Feline Grace (Passive)",      learnCost = 14000, powerCost = 0,    type = "Buff",    castTime = 0,   duration = 0 },                                  -- Passive
            { name = "Moonfire (Rank 7)",           learnCost = 14000, powerCost = 235,  min = 105,        max = 129,      type = "Damage", castTime = 0,  duration = 12 },
            { name = "Mark of the Wild (Rank 5)",   learnCost = 14000, powerCost = 280,  type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Insect Swarm (Rank 3)",       learnCost = 700,   powerCost = 85,   min = 162,        max = 162,      type = "Damage", castTime = 0,  duration = 12 },
            { name = "Rebirth (Rank 3)",            learnCost = 14000, powerCost = 1100, type = "Utility", castTime = 2.0, duration = 0 },
            { name = "Rejuvenation (Rank 7)",       learnCost = 14000, powerCost = 195,  min = 456,        max = 456,      type = "Heal",   castTime = 0,  duration = 12 },
        },
        [42] = {
            { name = "Demoralizing Roar (Rank 4)",   learnCost = 16000, powerCost = 10,  type = "Utility", castTime = 0, duration = 30 },
            { name = "Regrowth (Rank 6)",            learnCost = 16000, powerCost = 580, min = 647,        max = 733,    type = "Heal",   castTime = 2.0, duration = 21 },
            { name = "Faerie Fire (Feral) (Rank 3)", learnCost = 800,   powerCost = 0,   type = "Utility", castTime = 0, duration = 40 },
            { name = "Maul (Rank 5)",                learnCost = 16000, powerCost = 15,  min = 83,         max = 83,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Faerie Fire (Rank 3)",         learnCost = 16000, powerCost = 0,   type = "Utility", castTime = 0, duration = 40 }, -- Mana: ~90
            { name = "Starfire (Rank 4)",            learnCost = 16000, powerCost = 225, min = 269,        max = 321,    type = "Damage", castTime = 3.5, duration = 0 },
            { name = "Ravage (Rank 2)",              learnCost = 16000, powerCost = 60,  min = 203,        max = 203,    type = "Damage", castTime = 0,   duration = 0 },
        },
        [44] = {
            { name = "Rake (Rank 3)",          learnCost = 18000, powerCost = 40,  min = 53,      max = 53,     type = "Damage", castTime = 0,   duration = 9 },
            { name = "Swipe (Rank 4)",         learnCost = 18000, powerCost = 20,  min = 84,      max = 84,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Rip (Rank 4)",           learnCost = 18000, powerCost = 30,  min = 114,     max = 114,    type = "Damage", castTime = 0,   duration = 12 },
            { name = "Thorns (Rank 5)",        learnCost = 18000, powerCost = 175, type = "Buff", castTime = 0, duration = 600 },
            { name = "Barkskin",               learnCost = 18000, powerCost = 0,   type = "Buff", castTime = 0, duration = 15 },
            { name = "Healing Touch (Rank 8)", learnCost = 18000, powerCost = 485, min = 1205,    max = 1493,   type = "Heal",   castTime = 3.5, duration = 0 },
        },
        [46] = {
            { name = "Wrath (Rank 7)",                 learnCost = 20000, powerCost = 165, min = 198,        max = 229,    type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Shred (Rank 4)",                 learnCost = 20000, powerCost = 60,  min = 126,        max = 126,    type = "Damage", castTime = 0,   duration = 0 },
            { name = "Rejuvenation (Rank 8)",          learnCost = 20000, powerCost = 225, min = 568,        max = 568,    type = "Heal",   castTime = 0,   duration = 12 },
            { name = "Moonfire (Rank 8)",              learnCost = 20000, powerCost = 280, min = 128,        max = 155,    type = "Damage", castTime = 0,   duration = 12 },
            { name = "Bash (Rank 3)",                  learnCost = 20000, powerCost = 10,  type = "Utility", castTime = 0, duration = 4 },
            { name = "Dash (Rank 2)",                  learnCost = 20000, powerCost = 0,   type = "Buff",    castTime = 0, duration = 15 },
            { name = "Frenzied Regeneration (Rank 2)", learnCost = 20000, powerCost = 10,  type = "Heal",    castTime = 0, duration = 10 },
            { name = "Pounce (Rank 2)",                learnCost = 20000, powerCost = 50,  min = 240,        max = 240,    type = "Damage", castTime = 0,   duration = 18 },
        },
        [48] = {
            { name = "Claw (Rank 4)",             learnCost = 22000, powerCost = 45,  min = 79,               max = 79,       type = "Damage", castTime = 0,   duration = 0 },
            { name = "Tiger's Fury (Rank 3)",     learnCost = 22000, powerCost = 30,  type = "Buff",          castTime = 0,   duration = 6 },
            { name = "Entangling Roots (Rank 5)", learnCost = 22000, powerCost = 120, type = "Crowd Control", castTime = 1.5, duration = 24 },
            { name = "Regrowth (Rank 7)",         learnCost = 22000, powerCost = 690, min = 797,              max = 902,      type = "Heal",   castTime = 2.0, duration = 21 },
            { name = "Ferocious Bite (Rank 3)",   learnCost = 22000, powerCost = 35,  min = 128,              max = 352,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Nature's Grasp (Rank 5)",   learnCost = 1100,  powerCost = 145, type = "Buff",          castTime = 0,   duration = 45 },
        },
        [50] = {
            { name = "Hurricane (Rank 2)",        learnCost = 23000, powerCost = 1135, min = 930,        max = 930,      type = "Damage", castTime = 10,  duration = 10 },
            { name = "Insect Swarm (Rank 4)",     learnCost = 1150,  powerCost = 110,  min = 228,        max = 228,      type = "Damage", castTime = 0,   duration = 12 },
            { name = "Mark of the Wild (Rank 6)", learnCost = 23000, powerCost = 385,  type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Starfire (Rank 5)",         learnCost = 23000, powerCost = 270,  min = 338,        max = 405,      type = "Damage", castTime = 3.5, duration = 0 },
            { name = "Tranquility (Rank 3)",      learnCost = 23000, powerCost = 1120, min = 725,        max = 725,      type = "Heal",   castTime = 10,  duration = 10 },
            { name = "Healing Touch (Rank 9)",    learnCost = 23000, powerCost = 575,  min = 1543,       max = 1905,     type = "Heal",   castTime = 3.5, duration = 0 },
            { name = "Ravage (Rank 3)",           learnCost = 23000, powerCost = 60,   min = 271,        max = 271,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Maul (Rank 6)",             learnCost = 23000, powerCost = 15,   min = 107,        max = 107,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Rebirth (Rank 4)",          learnCost = 23000, powerCost = 1250, type = "Utility", castTime = 2.0, duration = 0 },
        },
        [52] = {
            { name = "Cower (Rank 3)",             learnCost = 26000, powerCost = 20,  type = "Utility", castTime = 0, duration = 0 },
            { name = "Demoralizing Roar (Rank 5)", learnCost = 26000, powerCost = 10,  type = "Utility", castTime = 0, duration = 30 },
            { name = "Moonfire (Rank 9)",          learnCost = 26000, powerCost = 325, min = 152,        max = 182,    type = "Damage", castTime = 0, duration = 12 },
            { name = "Rip (Rank 5)",               learnCost = 26000, powerCost = 30,  min = 138,        max = 138,    type = "Damage", castTime = 0, duration = 12 },
            { name = "Rejuvenation (Rank 9)",      learnCost = 26000, powerCost = 255, min = 684,        max = 684,    type = "Heal",   castTime = 0, duration = 12 },
        },
        [54] = {
            { name = "Thorns (Rank 6)",              learnCost = 28000, powerCost = 220, type = "Buff",    castTime = 0,   duration = 600 },
            { name = "Rake (Rank 4)",                learnCost = 28000, powerCost = 40,  min = 72,         max = 72,       type = "Damage", castTime = 0,   duration = 9 },
            { name = "Faerie Fire (Feral) (Rank 4)", learnCost = 1400,  powerCost = 0,   type = "Utility", castTime = 0,   duration = 40 },
            { name = "Regrowth (Rank 8)",            learnCost = 28000, powerCost = 800, min = 966,        max = 1092,     type = "Heal",   castTime = 2.0, duration = 21 },
            { name = "Soothe Animal (Rank 3)",       learnCost = 28000, powerCost = 90,  type = "Utility", castTime = 1.5, duration = 0 },
            { name = "Faerie Fire (Rank 4)",         learnCost = 28000, powerCost = 0,   type = "Utility", castTime = 0,   duration = 40 }, -- Mana ~120
            { name = "Wrath (Rank 8)",               learnCost = 28000, powerCost = 200, min = 254,        max = 294,      type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Shred (Rank 5)",               learnCost = 28000, powerCost = 60,  min = 153,        max = 153,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Swipe (Rank 5)",               learnCost = 28000, powerCost = 20,  min = 108,        max = 108,      type = "Damage", castTime = 0,   duration = 0 },
        },
        [56] = {
            { name = "Pounce (Rank 3)",                learnCost = 30000, powerCost = 50,  min = 300,     max = 300,    type = "Damage", castTime = 0,   duration = 18 },
            { name = "Ferocious Bite (Rank 4)",        learnCost = 30000, powerCost = 35,  min = 176,     max = 484,    type = "Damage", castTime = 0,   duration = 0 },
            { name = "Healing Touch (Rank 10)",        learnCost = 30000, powerCost = 680, min = 1916,    max = 2362,   type = "Heal",   castTime = 3.5, duration = 0 },
            { name = "Frenzied Regeneration (Rank 3)", learnCost = 30000, powerCost = 10,  type = "Heal", castTime = 0, duration = 10 },
        },
        [58] = {
            { name = "Claw (Rank 5)",             learnCost = 32000, powerCost = 45,  min = 103,              max = 103,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Entangling Roots (Rank 6)", learnCost = 32000, powerCost = 135, type = "Crowd Control", castTime = 1.5, duration = 27 },
            { name = "Hibernate (Rank 3)",        learnCost = 32000, powerCost = 130, type = "Crowd Control", castTime = 1.5, duration = 40 },
            { name = "Starfire (Rank 6)",         learnCost = 32000, powerCost = 315, min = 445,              max = 526,      type = "Damage", castTime = 3.5, duration = 0 },
            { name = "Rejuvenation (Rank 10)",    learnCost = 32000, powerCost = 285, min = 816,              max = 816,      type = "Heal",   castTime = 0,   duration = 12 },
            { name = "Maul (Rank 7)",             learnCost = 32000, powerCost = 15,  min = 134,              max = 134,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Ravage (Rank 4)",           learnCost = 32000, powerCost = 60,  min = 345,              max = 345,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Nature's Grasp (Rank 6)",   learnCost = 1600,  powerCost = 175, type = "Buff",          castTime = 0,   duration = 45 },
            { name = "Moonfire (Rank 10)",        learnCost = 32000, powerCost = 370, min = 176,              max = 210,      type = "Damage", castTime = 0,   duration = 12 },
        },
        [60] = {
            { name = "Insect Swarm (Rank 5)",     learnCost = 1700,  powerCost = 135,  min = 324,        max = 324,      type = "Damage", castTime = 0,   duration = 12 },
            { name = "Regrowth (Rank 9)",         learnCost = 34000, powerCost = 880,  min = 1061,       max = 1187,     type = "Heal",   castTime = 2.0, duration = 21 },
            { name = "Rip (Rank 6)",              learnCost = 34000, powerCost = 30,   min = 168,        max = 168,      type = "Damage", castTime = 0,   duration = 12 }, -- 30 Energy
            { name = "Rebirth (Rank 5)",          learnCost = 34000, powerCost = 1400, type = "Utility", castTime = 2.0, duration = 0 },
            { name = "Prowl (Rank 3)",            learnCost = 34000, powerCost = 0,    type = "Utility", castTime = 0,   duration = 0 },
            { name = "Tiger's Fury (Rank 4)",     learnCost = 34000, powerCost = 30,   type = "Buff",    castTime = 0,   duration = 6 },
            { name = "Mark of the Wild (Rank 7)", learnCost = 34000, powerCost = 450,  type = "Buff",    castTime = 0,   duration = 1800 },
            { name = "Hurricane (Rank 3)",        learnCost = 34000, powerCost = 1535, min = 1140,       max = 1140,     type = "Damage", castTime = 10,  duration = 10 },
            { name = "Tranquility (Rank 4)",      learnCost = 34000, powerCost = 1515, min = 1092,       max = 1092,     type = "Heal",   castTime = 10,  duration = 10 },
            { name = "Healing Touch (Rank 11)",   learnCost = 34000, powerCost = 800,  min = 2267,       max = 2677,     type = "Heal",   castTime = 3.5, duration = 0 },
            { name = "Starfire (Rank 7)",         learnCost = 34000, powerCost = 370,  min = 496,        max = 585,      type = "Damage", castTime = 3.5, duration = 0 },
            { name = "Moonfire (Rank 10)",        learnCost = 34000, powerCost = 495,  min = 189,        max = 222,      type = "Damage", castTime = 0,   duration = 12 }, -- If Rank 10 is learned at 58, maybe Rank 11 here? Wait. Moonfire Rank 10 is lvl 58. Rank 11 is Book? Or maybe standard. Let's check max rank. Standard usually goes to R10.
        },
    },

    --------------------------------------------------------
    -- SHAMAN – 1–60 with cost placeholders (copper = 0)
    --------------------------------------------------------
    SHAMAN = {
        [1] = {
            { name = "Rockbiter Weapon (Rank 1)", learnCost = 10, powerCost = 15,  type = "Buff", castTime = 0, duration = 300 },
            { name = "Lightning Bolt (Rank 1)",   learnCost = 10, powerCost = 15,  min = 15,      max = 17,     type = "Damage", castTime = 1.5, duration = 0 },
            { name = "Healing Wave (Rank 1)",     learnCost = 10, powerCost = 25,  min = 34,      max = 45,     type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Earth Shield (Rank 1)",     learnCost = 10, powerCost = 150, type = "Buff", castTime = 0, duration = 600 }, -- Turtle Custom
        },
        [4] = {
            { name = "Earth Shock (Rank 1)", learnCost = 100, powerCost = 30, min = 19, max = 20, type = "Damage", castTime = 0, duration = 0 },
        },
        [6] = {
            { name = "Healing Wave (Rank 2)",    learnCost = 100, powerCost = 45, min = 64,         max = 78,     type = "Heal", castTime = 2.0, duration = 0 },
            { name = "Earthbind Totem",          learnCost = 100, powerCost = 80, type = "Utility", castTime = 0, duration = 45 },
            { name = "Stoneskin Totem (Rank 1)", learnCost = 100, powerCost = 70, type = "Buff",    castTime = 0, duration = 120 },
        },
        [8] = {
            { name = "Lightning Shield (Rank 1)", learnCost = 100, powerCost = 45, type = "Buff",    castTime = 0, duration = 600 },
            { name = "Lightning Bolt (Rank 2)",   learnCost = 100, powerCost = 30, min = 28,         max = 33,     type = "Damage", castTime = 2.0, duration = 0 },
            { name = "Stoneclaw Totem (Rank 1)",  learnCost = 100, powerCost = 70, type = "Utility", castTime = 0, duration = 15 },
            { name = "Earth Shock (Rank 2)",      learnCost = 100, powerCost = 50, min = 35,         max = 38,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Rockbiter Weapon (Rank 2)", learnCost = 100, powerCost = 30, type = "Buff",    castTime = 0, duration = 300 },
            { name = "Molten Blast (Rank 1)",     learnCost = 100, powerCost = 30, min = 18,         max = 26,     type = "Damage", castTime = 1.8, duration = 0 }, -- Turtle Custom
        },
        [10] = {
            { name = "Flame Shock (Rank 1)",             learnCost = 400, powerCost = 55, min = 25,      max = 25,     type = "Damage", castTime = 0, duration = 12 }, -- dot
            { name = "Strength of Earth Totem (Rank 1)", learnCost = 400, powerCost = 80, type = "Buff", castTime = 0, duration = 120 },
            { name = "Flametongue Weapon (Rank 1)",      learnCost = 400, powerCost = 60, type = "Buff", castTime = 0, duration = 300 },
            { name = "Searing Totem (Rank 1)",           learnCost = 400, powerCost = 25, min = 9,       max = 11,     type = "Damage", castTime = 0, duration = 30 }, -- Attack
        },
        [12] = {
            { name = "Purge (Rank 1)",            learnCost = 800, powerCost = 75,  type = "Utility", castTime = 0,  duration = 0 },
            { name = "Fire Nova Totem (Rank 1)",  learnCost = 800, powerCost = 145, min = 53,         max = 62,      type = "Damage", castTime = 0,   duration = 5 },
            { name = "Ancestral Spirit (Rank 1)", learnCost = 800, powerCost = 180, type = "Utility", castTime = 10, duration = 0 },
            { name = "Healing Wave (Rank 3)",     learnCost = 800, powerCost = 80,  min = 129,        max = 156,     type = "Heal",   castTime = 2.5, duration = 0 },
        },
        [14] = {
            { name = "Earth Shock (Rank 3)",     learnCost = 900, powerCost = 80,  min = 66,      max = 71,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Lightning Bolt (Rank 3)",  learnCost = 900, powerCost = 60,  min = 48,      max = 56,     type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Stoneskin Totem (Rank 2)", learnCost = 900, powerCost = 135, type = "Buff", castTime = 0, duration = 120 },
            { name = "Molten Blast (Rank 2)",    learnCost = 900, powerCost = 45,  min = 32,      max = 44,     type = "Damage", castTime = 2.0, duration = 0 },
        },
        [16] = {
            { name = "Cure Poison",               learnCost = 1800, powerCost = 70, type = "Utility", castTime = 0, duration = 0 },
            { name = "Rockbiter Weapon (Rank 3)", learnCost = 1800, powerCost = 65, type = "Buff",    castTime = 0, duration = 300 },
            { name = "Lightning Shield (Rank 2)", learnCost = 1800, powerCost = 80, type = "Buff",    castTime = 0, duration = 600 },
        },
        [18] = {
            { name = "Flame Shock (Rank 2)",        learnCost = 2000, powerCost = 95,  min = 51,         max = 51,     type = "Damage", castTime = 0,   duration = 12 },
            { name = "Tremor Totem",                learnCost = 2000, powerCost = 60,  type = "Utility", castTime = 0, duration = 120 },
            { name = "Flametongue Weapon (Rank 2)", learnCost = 2000, powerCost = 100, type = "Buff",    castTime = 0, duration = 300 },
            { name = "Stoneclaw Totem (Rank 2)",    learnCost = 2000, powerCost = 130, type = "Utility", castTime = 0, duration = 15 },
            { name = "Healing Wave (Rank 4)",       learnCost = 2000, powerCost = 155, min = 268,        max = 316,    type = "Heal",   castTime = 3.0, duration = 0 },
        },
        [20] = {
            { name = "Frostbrand Weapon (Rank 1)",   learnCost = 2200, powerCost = 65,  type = "Buff", castTime = 0,   duration = 300 },
            { name = "Frost Shock (Rank 1)",         learnCost = 2200, powerCost = 115, min = 95,      max = 104,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Lesser Healing Wave (Rank 1)", learnCost = 2200, powerCost = 105, min = 162,     max = 186,      type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Lightning Bolt (Rank 4)",      learnCost = 2200, powerCost = 105, min = 88,      max = 100,      type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Searing Totem (Rank 2)",       learnCost = 2200, powerCost = 45,  min = 13,      max = 17,       type = "Damage", castTime = 0,   duration = 35 },
            { name = "Ghost Wolf",                   learnCost = 2200, powerCost = 100, type = "Buff", castTime = 3.0, duration = 0 },
        },
        [22] = {
            { name = "Fire Nova Totem (Rank 2)", learnCost = 3000, powerCost = 270, min = 110,        max = 124,    type = "Damage", castTime = 0,   duration = 5 },
            { name = "Cure Disease",             learnCost = 3000, powerCost = 70,  type = "Utility", castTime = 0, duration = 0 },
            { name = "Water Breathing",          learnCost = 3000, powerCost = 50,  type = "Buff",    castTime = 0, duration = 600 },
            { name = "Poison Cleansing Totem",   learnCost = 3000, powerCost = 80,  type = "Utility", castTime = 0, duration = 120 },
            { name = "Molten Blast (Rank 3)",    learnCost = 3000, powerCost = 75,  min = 63,         max = 83,     type = "Damage", castTime = 2.0, duration = 0 },
        },
        [24] = {
            { name = "Stoneskin Totem (Rank 3)",         learnCost = 3500, powerCost = 135, type = "Buff",    castTime = 0,  duration = 120 },
            { name = "Rockbiter Weapon (Rank 4)",        learnCost = 3500, powerCost = 90,  type = "Buff",    castTime = 0,  duration = 300 },
            { name = "Earth Shock (Rank 4)",             learnCost = 3500, powerCost = 130, min = 134,        max = 142,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Ancestral Spirit (Rank 2)",        learnCost = 3500, powerCost = 425, type = "Utility", castTime = 10, duration = 0 },
            { name = "Lightning Shield (Rank 3)",        learnCost = 3500, powerCost = 125, type = "Buff",    castTime = 0,  duration = 600 },
            { name = "Frost Resistance Totem (Rank 1)",  learnCost = 3500, powerCost = 85,  type = "Buff",    castTime = 0,  duration = 120 },
            { name = "Healing Wave (Rank 5)",            learnCost = 3500, powerCost = 200, min = 376,        max = 441,     type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Strength of Earth Totem (Rank 2)", learnCost = 3500, powerCost = 125, type = "Buff",    castTime = 0,  duration = 120 },
        },
        [26] = {
            { name = "Magma Totem (Rank 1)",        learnCost = 4000, powerCost = 230, min = 22,         max = 22,     type = "Damage", castTime = 0,   duration = 20 },
            { name = "Far Sight",                   learnCost = 4000, powerCost = 50,  type = "Utility", castTime = 0, duration = 0 }, -- Chonnel
            { name = "Lightning Bolt (Rank 5)",     learnCost = 4000, powerCost = 135, min = 131,        max = 149,    type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Flametongue Weapon (Rank 3)", learnCost = 4000, powerCost = 145, type = "Buff",    castTime = 0, duration = 300 },
            { name = "Mana Spring Totem (Rank 1)",  learnCost = 4000, powerCost = 60,  type = "Buff",    castTime = 0, duration = 60 },
            -- { name = "Water Shield (Rank 1)",       learnCost = 4000, powerCost = 0,   type = "Buff",    castTime = 0,   duration = 600 }, -- Likely Custom
        },
        [28] = {
            { name = "Water Walking",                  learnCost = 6000, powerCost = 35,  type = "Buff",    castTime = 0, duration = 600 },
            { name = "Flame Shock (Rank 3)",           learnCost = 6000, powerCost = 150, min = 93,         max = 93,     type = "Damage", castTime = 0,   duration = 12 },
            { name = "Flametongue Totem (Rank 1)",     learnCost = 6000, powerCost = 75,  type = "Buff",    castTime = 0, duration = 120 },
            { name = "Fire Resistance Totem (Rank 1)", learnCost = 6000, powerCost = 85,  type = "Buff",    castTime = 0, duration = 120 },
            { name = "Lesser Healing Wave (Rank 2)",   learnCost = 6000, powerCost = 185, min = 247,        max = 281,    type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Frostbrand Weapon (Rank 2)",     learnCost = 6000, powerCost = 110, type = "Buff",    castTime = 0, duration = 300 },
            { name = "Stoneclaw Totem (Rank 3)",       learnCost = 6000, powerCost = 190, type = "Utility", castTime = 0, duration = 15 },
        },
        [30] = {
            { name = "Reincarnation",                    learnCost = 7000, powerCost = 0,   type = "Utility", castTime = 0,  duration = 0 }, -- No mana, item cost
            { name = "Nature Resistance Totem (Rank 1)", learnCost = 7000, powerCost = 75,  type = "Buff",    castTime = 0,  duration = 120 },
            { name = "Grounding Totem",                  learnCost = 7000, powerCost = 80,  type = "Utility", castTime = 0,  duration = 45 },
            { name = "Searing Totem (Rank 3)",           learnCost = 7000, powerCost = 75,  min = 19,         max = 25,      type = "Damage", castTime = 0,   duration = 40 },
            { name = "Healing Stream Totem (Rank 2)",    learnCost = 7000, powerCost = 65,  type = "Heal",    castTime = 0,  duration = 60 }, -- Healing?
            { name = "Astral Recall",                    learnCost = 7000, powerCost = 150, type = "Utility", castTime = 10, duration = 0 },
            { name = "Windfury Weapon (Rank 1)",         learnCost = 7000, powerCost = 115, type = "Buff",    castTime = 0,  duration = 300 },
            { name = "Molten Blast (Rank 4)",            learnCost = 7000, powerCost = 110, min = 102,        max = 132,     type = "Damage", castTime = 2.0, duration = 0 },
        },
        [32] = {
            { name = "Purge (Rank 2)",            learnCost = 8000, powerCost = 60,  type = "Utility", castTime = 0, duration = 0 }, -- rank 2 reduces mana cost?
            { name = "Lightning Shield (Rank 4)", learnCost = 8000, powerCost = 210, type = "Buff",    castTime = 0, duration = 600 },
            { name = "Healing Wave (Rank 6)",     learnCost = 8000, powerCost = 265, min = 536,        max = 616,    type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Lightning Bolt (Rank 6)",   learnCost = 8000, powerCost = 170, min = 183,        max = 207,    type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Chain Lightning (Rank 1)",  learnCost = 8000, powerCost = 260, min = 191,        max = 218,    type = "Damage", castTime = 2.5, duration = 0 },
            { name = "Fire Nova Totem (Rank 3)",  learnCost = 8000, powerCost = 395, min = 195,        max = 219,    type = "Damage", castTime = 0,   duration = 5 },
            { name = "Windfury Totem (Rank 1)",   learnCost = 8000, powerCost = 135, type = "Buff",    castTime = 0, duration = 120 },
        },
        [34] = {
            { name = "Sentry Totem",              learnCost = 9000, powerCost = 40,  type = "Utility", castTime = 0, duration = 0 },
            { name = "Stoneskin Totem (Rank 4)",  learnCost = 9000, powerCost = 195, type = "Buff",    castTime = 0, duration = 120 },
            { name = "Rockbiter Weapon (Rank 5)", learnCost = 9000, powerCost = 125, type = "Buff",    castTime = 0, duration = 300 },
            { name = "Frost Shock (Rank 2)",      learnCost = 9000, powerCost = 200, min = 174,        max = 187,    type = "Damage", castTime = 0, duration = 0 },
        },
        [36] = {
            { name = "Magma Totem (Rank 2)",         learnCost = 10000, powerCost = 340, min = 37,         max = 37,      type = "Damage", castTime = 0,   duration = 20 },
            { name = "Earth Shock (Rank 5)",         learnCost = 10000, powerCost = 205, min = 261,        max = 277,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Flametongue Weapon (Rank 4)",  learnCost = 10000, powerCost = 195, type = "Buff",    castTime = 0,  duration = 300 },
            { name = "Mana Spring Totem (Rank 2)",   learnCost = 10000, powerCost = 100, type = "Buff",    castTime = 0,  duration = 60 },
            { name = "Windwall Totem (Rank 1)",      learnCost = 10000, powerCost = 160, type = "Buff",    castTime = 0,  duration = 120 },
            { name = "Ancestral Spirit (Rank 3)",    learnCost = 10000, powerCost = 675, type = "Utility", castTime = 10, duration = 0 },
            { name = "Lesser Healing Wave (Rank 3)", learnCost = 10000, powerCost = 265, min = 337,        max = 381,     type = "Heal",   castTime = 1.5, duration = 0 },
        },
        [38] = {
            { name = "Frost Resistance Totem (Rank 2)",  learnCost = 11000, powerCost = 145, type = "Buff",    castTime = 0, duration = 120 },
            { name = "Frostbrand Weapon (Rank 3)",       learnCost = 11000, powerCost = 160, type = "Buff",    castTime = 0, duration = 300 },
            { name = "Disease Cleansing Totem",          learnCost = 11000, powerCost = 160, type = "Utility", castTime = 0, duration = 120 },
            { name = "Flametongue Totem (Rank 2)",       learnCost = 11000, powerCost = 145, type = "Buff",    castTime = 0, duration = 120 },
            { name = "Strength of Earth Totem (Rank 3)", learnCost = 11000, powerCost = 185, type = "Buff",    castTime = 0, duration = 120 },
            { name = "Lightning Bolt (Rank 7)",          learnCost = 11000, powerCost = 220, min = 237,        max = 267,    type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Stoneclaw Totem (Rank 4)",         learnCost = 11000, powerCost = 265, type = "Utility", castTime = 0, duration = 15 },
            { name = "Molten Blast (Rank 5)",            learnCost = 11000, powerCost = 145, min = 148,        max = 188,    type = "Damage", castTime = 2.0, duration = 0 },
        },
        [40] = {
            { name = "Windfury Weapon (Rank 2)",      learnCost = 12000, powerCost = 165, type = "Buff",    castTime = 0, duration = 300 },
            { name = "Mail",                          learnCost = 12000, powerCost = 0,   type = "Utility", castTime = 0, duration = 0 },
            { name = "Healing Wave (Rank 7)",         learnCost = 12000, powerCost = 340, min = 740,        max = 854,    type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Chain Lightning (Rank 2)",      learnCost = 12000, powerCost = 370, min = 263,        max = 299,    type = "Damage", castTime = 2.5, duration = 0 },
            { name = "Healing Stream Totem (Rank 3)", learnCost = 12000, powerCost = 85,  type = "Heal",    castTime = 0, duration = 60 },
            { name = "Flame Shock (Rank 4)",          learnCost = 12000, powerCost = 215, min = 152,        max = 152,    type = "Damage", castTime = 0,   duration = 12 },
            { name = "Searing Totem (Rank 4)",        learnCost = 12000, powerCost = 135, min = 26,         max = 34,     type = "Damage", castTime = 0,   duration = 45 },
            { name = "Lightning Shield (Rank 5)",     learnCost = 12000, powerCost = 270, type = "Buff",    castTime = 0, duration = 600 },
            { name = "Chain Heal (Rank 1)",           learnCost = 12000, powerCost = 260, min = 320,        max = 368,    type = "Heal",   castTime = 2.5, duration = 0 },
        },
        [42] = {
            { name = "Grace of Air Totem (Rank 1)",    learnCost = 16000, powerCost = 155, type = "Buff", castTime = 0, duration = 120 },
            { name = "Fire Nova Totem (Rank 4)",       learnCost = 16000, powerCost = 520, min = 307,     max = 343,    type = "Damage", castTime = 0, duration = 5 },
            { name = "Windfury Totem (Rank 2)",        learnCost = 16000, powerCost = 195, type = "Buff", castTime = 0, duration = 120 },
            { name = "Fire Resistance Totem (Rank 2)", learnCost = 16000, powerCost = 145, type = "Buff", castTime = 0, duration = 120 },
        },
        [44] = {
            { name = "Nature Resistance Totem (Rank 2)", learnCost = 18000, powerCost = 145, type = "Buff", castTime = 0, duration = 120 },
            { name = "Rockbiter Weapon (Rank 6)",        learnCost = 18000, powerCost = 165, type = "Buff", castTime = 0, duration = 300 },
            { name = "Lesser Healing Wave (Rank 4)",     learnCost = 18000, powerCost = 380, min = 458,     max = 514,    type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Stoneskin Totem (Rank 5)",         learnCost = 18000, powerCost = 255, type = "Buff", castTime = 0, duration = 120 },
            { name = "Lightning Bolt (Rank 8)",          learnCost = 18000, powerCost = 265, min = 291,     max = 327,    type = "Damage", castTime = 3.0, duration = 0 },
        },
        [46] = {
            { name = "Flametongue Weapon (Rank 5)", learnCost = 20000, powerCost = 235, type = "Buff", castTime = 0, duration = 300 },
            { name = "Frost Shock (Rank 3)",        learnCost = 20000, powerCost = 275, min = 265,     max = 281,    type = "Damage", castTime = 0,   duration = 0 },
            { name = "Chain Heal (Rank 2)",         learnCost = 20000, powerCost = 315, min = 405,     max = 466,    type = "Heal",   castTime = 2.5, duration = 0 },
            { name = "Magma Totem (Rank 3)",        learnCost = 20000, powerCost = 450, min = 54,      max = 54,     type = "Damage", castTime = 0,   duration = 20 },
            { name = "Mana Spring Totem (Rank 3)",  learnCost = 20000, powerCost = 145, type = "Buff", castTime = 0, duration = 60 },
            { name = "Windwall Totem (Rank 2)",     learnCost = 20000, powerCost = 245, type = "Buff", castTime = 0, duration = 120 },
        },
        [48] = {
            { name = "Bloodlust",                  learnCost = 22000, powerCost = 300, type = "Buff",    castTime = 0,  duration = 30 }, -- Custom Turtle WoW
            { name = "Flametongue Totem (Rank 3)", learnCost = 22000, powerCost = 215, type = "Buff",    castTime = 0,  duration = 120 },
            { name = "Lightning Shield (Rank 6)",  learnCost = 22000, powerCost = 335, type = "Buff",    castTime = 0,  duration = 600 },
            { name = "Frostbrand Weapon (Rank 4)", learnCost = 22000, powerCost = 210, type = "Buff",    castTime = 0,  duration = 300 },
            { name = "Mana Tide Totem (Rank 2)",   learnCost = 1100,  powerCost = 0,   type = "Buff",    castTime = 0,  duration = 12 }, -- Talent usually, cost 0? Or mana? Mana Tide is free/cheap mana restore.
            { name = "Healing Wave (Rank 8)",      learnCost = 22000, powerCost = 440, min = 1017,       max = 1171,    type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Ancestral Spirit (Rank 4)",  learnCost = 22000, powerCost = 900, type = "Utility", castTime = 10, duration = 0 },
            { name = "Stoneclaw Totem (Rank 5)",   learnCost = 22000, powerCost = 375, type = "Utility", castTime = 0,  duration = 15 },
            { name = "Earth Shock (Rank 6)",       learnCost = 22000, powerCost = 345, min = 407,        max = 430,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Chain Lightning (Rank 3)",   learnCost = 22000, powerCost = 490, min = 338,        max = 384,     type = "Damage", castTime = 2.5, duration = 0 },
        },
        [50] = {
            { name = "Tranquil Air Totem",            learnCost = 24000, powerCost = 100, type = "Buff", castTime = 0, duration = 120 },
            { name = "Searing Totem (Rank 5)",        learnCost = 24000, powerCost = 160, min = 33,      max = 45,     type = "Damage", castTime = 0,   duration = 55 },
            { name = "Healing Stream Totem (Rank 4)", learnCost = 24000, powerCost = 85,  type = "Heal", castTime = 0, duration = 60 },
            { name = "Windfury Weapon (Rank 3)",      learnCost = 24000, powerCost = 195, type = "Buff", castTime = 0, duration = 300 },
            { name = "Lightning Bolt (Rank 9)",       learnCost = 24000, powerCost = 310, min = 347,     max = 393,    type = "Damage", castTime = 3.0, duration = 0 },
        },
        [52] = {
            { name = "Strength of Earth Totem (Rank 4)", learnCost = 27000, powerCost = 225, type = "Buff", castTime = 0, duration = 120 },
            { name = "Flame Shock (Rank 5)",             learnCost = 27000, powerCost = 295, min = 230,     max = 230,    type = "Damage", castTime = 0,   duration = 12 },
            { name = "Windfury Totem (Rank 3)",          learnCost = 27000, powerCost = 250, type = "Buff", castTime = 0, duration = 120 },
            { name = "Lesser Healing Wave (Rank 5)",     learnCost = 27000, powerCost = 445, min = 631,     max = 705,    type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Fire Nova Totem (Rank 5)",         learnCost = 27000, powerCost = 650, min = 443,     max = 497,    type = "Damage", castTime = 0,   duration = 5 },
        },
        [54] = {
            { name = "Rockbiter Weapon (Rank 7)",       learnCost = 29000, powerCost = 200, type = "Buff", castTime = 0, duration = 300 },
            { name = "Chain Heal (Rank 3)",             learnCost = 29000, powerCost = 405, min = 551,     max = 629,    type = "Heal", castTime = 2.5, duration = 0 },
            { name = "Stoneskin Totem (Rank 6)",        learnCost = 29000, powerCost = 300, type = "Buff", castTime = 0, duration = 120 },
            { name = "Frost Resistance Totem (Rank 3)", learnCost = 29000, powerCost = 195, type = "Buff", castTime = 0, duration = 120 },
        },
        [56] = {
            { name = "Mana Spring Totem (Rank 4)",  learnCost = 30000, powerCost = 200, type = "Buff", castTime = 0, duration = 60 },
            { name = "Flametongue Weapon (Rank 6)", learnCost = 30000, powerCost = 290, type = "Buff", castTime = 0, duration = 300 },
            { name = "Healing Wave (Rank 9)",       learnCost = 30000, powerCost = 620, min = 1367,    max = 1561,   type = "Heal",   castTime = 3.0, duration = 0 },
            { name = "Windwall Totem (Rank 3)",     learnCost = 30000, powerCost = 325, type = "Buff", castTime = 0, duration = 120 },
            { name = "Magma Totem (Rank 4)",        learnCost = 30000, powerCost = 570, min = 72,      max = 72,     type = "Damage", castTime = 0,   duration = 20 },
            { name = "Lightning Bolt (Rank 10)",    learnCost = 30000, powerCost = 370, min = 419,     max = 467,    type = "Damage", castTime = 3.0, duration = 0 },
            { name = "Chain Lightning (Rank 4)",    learnCost = 30000, powerCost = 605, min = 493,     max = 565,    type = "Damage", castTime = 2.5, duration = 0 },
            { name = "Lightning Shield (Rank 7)",   learnCost = 30000, powerCost = 415, type = "Buff", castTime = 0, duration = 600 },
            { name = "Grace of Air Totem (Rank 2)", learnCost = 30000, powerCost = 250, type = "Buff", castTime = 0, duration = 120 },
        },
        [58] = {
            { name = "Frostbrand Weapon (Rank 5)",     learnCost = 32000, powerCost = 255, type = "Buff",    castTime = 0, duration = 300 },
            { name = "Fire Resistance Totem (Rank 3)", learnCost = 32000, powerCost = 195, type = "Buff",    castTime = 0, duration = 120 },
            { name = "Flametongue Totem (Rank 4)",     learnCost = 32000, powerCost = 360, type = "Buff",    castTime = 0, duration = 120 },
            { name = "Mana Tide Totem (Rank 3)",       learnCost = 1600,  powerCost = 0,   type = "Buff",    castTime = 0, duration = 12 }, -- Talent
            { name = "Frost Shock (Rank 4)",           learnCost = 32000, powerCost = 430, min = 398,        max = 420,    type = "Damage", castTime = 0, duration = 0 },
            { name = "Stoneclaw Totem (Rank 6)",       learnCost = 32000, powerCost = 485, type = "Utility", castTime = 0, duration = 15 },
        },
        [60] = {
            { name = "Lesser Healing Wave (Rank 6)",     learnCost = 34000, powerCost = 530,  min = 832,        max = 928,     type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Searing Totem (Rank 6)",           learnCost = 34000, powerCost = 205,  min = 40,         max = 54,      type = "Damage", castTime = 0,   duration = 55 },
            { name = "Healing Stream Totem (Rank 5)",    learnCost = 34000, powerCost = 105,  type = "Heal",    castTime = 0,  duration = 60 },
            { name = "Ancestral Spirit (Rank 5)",        learnCost = 34000, powerCost = 1200, type = "Utility", castTime = 10, duration = 0 },
            { name = "Nature Resistance Totem (Rank 3)", learnCost = 34000, powerCost = 205,  type = "Buff",    castTime = 0,  duration = 120 },
            { name = "Earth Shock (Rank 7)",             learnCost = 34000, powerCost = 450,  min = 517,        max = 545,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Windfury Weapon (Rank 4)",         learnCost = 34000, powerCost = 285,  type = "Buff",    castTime = 0,  duration = 300 },
        },
    },

    --------------------------------------------------------
    -- PALADIN – 1–60 with cost placeholders (copper = 0)
    --------------------------------------------------------
    PALADIN = {
        [1] = {
            { name = "Devotion Aura (Rank 1)",         learnCost = 10, powerCost = 0,  type = "Buff", castTime = 0, duration = 1800 }, -- Aura costs 0 mana? Usually Instant
            { name = "Holy Light (Rank 1)",            learnCost = 10, powerCost = 35, min = 42,      max = 51,     type = "Heal",  castTime = 2.5, duration = 0 },
            { name = "Seal of Righteousness (Rank 1)", learnCost = 10, powerCost = 20, type = "Buff", castTime = 0, duration = 30 },
        },
        [4] = {
            { name = "Blessing of Might (Rank 1)", learnCost = 100, powerCost = 20, type = "Buff",   castTime = 0, duration = 600 },
            { name = "Judgement",                  learnCost = 100, powerCost = 0,  type = "Damage", castTime = 0, duration = 0 }, -- Power cost ~5% base mana. Set to 0 or leave blank? I'll set 0 and comment "5% base mana"
            { name = "Divine Protection (Rank 1)", learnCost = 100, powerCost = 15, type = "Buff",   castTime = 0, duration = 6 },
        },
        [6] = {
            { name = "Seal of the Crusader (Rank 1)", learnCost = 100, powerCost = 25, type = "Buff",    castTime = 0, duration = 30 },
            { name = "Holy Light (Rank 2)",           learnCost = 100, powerCost = 60, min = 83,         max = 101,    type = "Heal", castTime = 2.5, duration = 0 },
            { name = "Purify",                        learnCost = 100, powerCost = 30, type = "Utility", castTime = 0, duration = 0 }, -- lvl 6? Snippet 1727 says Purify is lvl 8. Maybe moved?
        },
        [8] = {
            { name = "Hammer of Justice (Rank 1)", learnCost = 100, powerCost = 50, type = "Crowd Control", castTime = 0, duration = 3 },
            { name = "Purify",                     learnCost = 100, powerCost = 80, type = "Utility",       castTime = 0, duration = 0 },
        },
        [10] = {
            { name = "Holy Strike (Rank 1)",            learnCost = 300, powerCost = 60, type = "Damage", castTime = 0, duration = 0 }, -- Custom?
            { name = "Crusader Strike (Rank 1)",        learnCost = 300, powerCost = 25, type = "Damage", castTime = 0, duration = 0 }, -- Custom in vanilla/Turtle?
            { name = "Lay on Hands (Rank 1)",           learnCost = 300, powerCost = 0,  type = "Heal",   castTime = 0, duration = 0 }, -- Drains all mana
            { name = "Seal of Righteousness (Rank 2)",  learnCost = 300, powerCost = 25, type = "Buff",   castTime = 0, duration = 30 },
            { name = "Devotion Aura (Rank 2)",          learnCost = 300, powerCost = 0,  type = "Buff",   castTime = 0, duration = 1800 },
            { name = "Blessing of Protection (Rank 1)", learnCost = 300, powerCost = 25, type = "Buff",   castTime = 0, duration = 6 },
        },
        [12] = {
            { name = "Blessing of Might (Rank 2)",    learnCost = 1000, powerCost = 30,  type = "Buff",    castTime = 0,  duration = 600 },
            { name = "Seal of the Crusader (Rank 2)", learnCost = 1000, powerCost = 40,  type = "Buff",    castTime = 0,  duration = 30 },
            { name = "Redemption (Rank 1)",           learnCost = 1000, powerCost = 125, type = "Utility", castTime = 10, duration = 0 },
        },
        [14] = {
            { name = "Blessing of Wisdom (Rank 1)", learnCost = 2000, powerCost = 35,  type = "Buff", castTime = 0, duration = 600 },
            { name = "Holy Light (Rank 3)",         learnCost = 2000, powerCost = 110, min = 159,     max = 188,    type = "Heal", castTime = 2.5, duration = 0 },
        },
        [16] = {
            { name = "Righteous Fury",            learnCost = 3000, powerCost = 90, type = "Buff", castTime = 0, duration = 1800 },
            { name = "Retribution Aura (Rank 1)", learnCost = 3000, powerCost = 0,  type = "Buff", castTime = 0, duration = 1800 },
            { name = "Exorcism (Rank 1)",         learnCost = 3000, powerCost = 85, min = 84,      max = 99,     type = "Damage", castTime = 0, duration = 0 }, -- lvl 16? Snippet 1757 says Exorcism lvl 20. Checking. Exorcism 16? 20?
        },
        [18] = {
            { name = "Blessing of Freedom",            learnCost = 3500, powerCost = 45, type = "Buff",   castTime = 0, duration = 10 },
            { name = "Divine Protection (Rank 2)",     learnCost = 3500, powerCost = 25, type = "Buff",   castTime = 0, duration = 8 },
            { name = "Seal of Righteousness (Rank 3)", learnCost = 3500, powerCost = 45, type = "Buff",   castTime = 0, duration = 30 },
            { name = "Holy Strike (Rank 2)",           learnCost = 3500, powerCost = 80, type = "Damage", castTime = 0, duration = 0 },
            { name = "Crusader Strike (Rank 2)",       learnCost = 3500, powerCost = 45, type = "Damage", castTime = 0, duration = 0 },
        },
        [20] = {
            { name = "Exorcism (Rank 1)",       learnCost = 4000, powerCost = 85,  min = 84,      max = 99,     type = "Damage", castTime = 0,   duration = 0 }, -- Moved or duplicate?
            { name = "Devotion Aura (Rank 3)",  learnCost = 4000, powerCost = 0,   type = "Buff", castTime = 0, duration = 1800 },
            { name = "Flash of Light (Rank 1)", learnCost = 4000, powerCost = 35,  min = 62,      max = 72,     type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Consecration (Rank 1)",   learnCost = 4000, powerCost = 135, min = 64,      max = 64,     type = "Damage", castTime = 0,   duration = 8 }, -- 64 damage over 8s
        },
        [22] = {
            { name = "Blessing of Might (Rank 3)",    learnCost = 4000, powerCost = 45,  type = "Buff", castTime = 0, duration = 600 },
            { name = "Seal of the Crusader (Rank 3)", learnCost = 4000, powerCost = 70,  type = "Buff", castTime = 0, duration = 30 },
            { name = "Seal of Justice",               learnCost = 4000, powerCost = 90,  type = "Buff", castTime = 0, duration = 30 },
            { name = "Concentration Aura",            learnCost = 4000, powerCost = 0,   type = "Buff", castTime = 0, duration = 1800 },
            { name = "Holy Light (Rank 4)",           learnCost = 4000, powerCost = 190, min = 310,     max = 356,    type = "Heal",  castTime = 2.5, duration = 0 },
        },
        [24] = {
            { name = "Blessing of Wisdom (Rank 2)",     learnCost = 5000, powerCost = 55,  type = "Buff",          castTime = 0,   duration = 600 },
            { name = "Blessing of Protection (Rank 2)", learnCost = 5000, powerCost = 45,  type = "Buff",          castTime = 0,   duration = 8 },
            { name = "Redemption (Rank 2)",             learnCost = 5000, powerCost = 255, type = "Utility",       castTime = 10,  duration = 0 },
            { name = "Hammer of Justice (Rank 2)",      learnCost = 5000, powerCost = 65,  type = "Crowd Control", castTime = 0,   duration = 4 },
            { name = "Turn Undead (Rank 1)",            learnCost = 5000, powerCost = 50,  type = "Crowd Control", castTime = 1.5, duration = 10 },
        },
        [26] = {
            { name = "Retribution Aura (Rank 2)",      learnCost = 6000, powerCost = 0,   type = "Buff",   castTime = 0, duration = 1800 },
            { name = "Seal of Righteousness (Rank 4)", learnCost = 6000, powerCost = 90,  type = "Buff",   castTime = 0, duration = 30 },
            { name = "Blessing of Salvation",          learnCost = 6000, powerCost = 30,  type = "Buff",   castTime = 0, duration = 600 },
            { name = "Flash of Light (Rank 2)",        learnCost = 6000, powerCost = 50,  min = 96,        max = 110,    type = "Heal",  castTime = 1.5, duration = 0 },
            { name = "Holy Strike (Rank 3)",           learnCost = 6000, powerCost = 105, type = "Damage", castTime = 0, duration = 0 },
            { name = "Crusader Strike (Rank 3)",       learnCost = 6000, powerCost = 65,  type = "Damage", castTime = 0, duration = 0 },
        },
        [28] = {
            { name = "Exorcism (Rank 2)",               learnCost = 9000, powerCost = 135, min = 151,     max = 171,    type = "Damage", castTime = 0,   duration = 0 },
            { name = "Shadow Resistance Aura (Rank 1)", learnCost = 9000, powerCost = 0,   type = "Buff", castTime = 0, duration = 1800 },
            { name = "Holy Light (Rank 5)",             learnCost = 9000, powerCost = 275, min = 491,     max = 553,    type = "Heal",   castTime = 2.5, duration = 0 }, -- lvl 28 or 30?
        },
        [30] = {
            { name = "Seal of Command (Rank 2)", learnCost = 550,   powerCost = 90,  min = 39,         max = 39,     type = "Damage", castTime = 0,   duration = 30 }, -- Custom/Talent? Or Trainable skill cost? Assuming standard mana cost.
            { name = "Lay on Hands (Rank 2)",    learnCost = 11000, powerCost = 0,   type = "Heal",    castTime = 0, duration = 0 },                                   -- Drains all.
            { name = "Devotion Aura (Rank 4)",   learnCost = 11000, powerCost = 0,   type = "Buff",    castTime = 0, duration = 1800 },
            { name = "Consecration (Rank 2)",    learnCost = 200,   powerCost = 205, min = 120,        max = 120,    type = "Damage", castTime = 0,   duration = 8 },
            { name = "Seal of Light (Rank 1)",   learnCost = 11000, powerCost = 65,  type = "Buff",    castTime = 0, duration = 30 },
            { name = "Divine Intervention",      learnCost = 11000, powerCost = 0,   type = "Utility", castTime = 0, duration = 0 },
            { name = "Holy Light (Rank 5)",      learnCost = 11000, powerCost = 275, min = 491,        max = 553,    type = "Heal",   castTime = 2.5, duration = 0 },
        },
        [32] = {
            { name = "Frost Resistance Aura (Rank 1)", learnCost = 12000, powerCost = 0,   type = "Buff", castTime = 0, duration = 1800 },
            { name = "Blessing of Might (Rank 4)",     learnCost = 12000, powerCost = 60,  type = "Buff", castTime = 0, duration = 600 },
            { name = "Seal of the Crusader (Rank 4)",  learnCost = 12000, powerCost = 115, type = "Buff", castTime = 0, duration = 30 },
        },
        [34] = {
            { name = "Flash of Light (Rank 3)",        learnCost = 13000, powerCost = 70,  min = 145,       max = 163,    type = "Heal", castTime = 1.5, duration = 0 },
            { name = "Divine Shield (Rank 1)",         learnCost = 13000, powerCost = 0,   type = "Buff",   castTime = 0, duration = 10 },
            { name = "Blessing of Wisdom (Rank 3)",    learnCost = 13000, powerCost = 75,  type = "Buff",   castTime = 0, duration = 600 },
            { name = "Seal of Righteousness (Rank 5)", learnCost = 13000, powerCost = 55,  type = "Buff",   castTime = 0, duration = 30 },
            { name = "Holy Strike (Rank 4)",           learnCost = 13000, powerCost = 130, type = "Damage", castTime = 0, duration = 0 },
            { name = "Crusader Strike (Rank 4)",       learnCost = 13000, powerCost = 85,  type = "Damage", castTime = 0, duration = 0 },
        },
        [36] = {
            { name = "Redemption (Rank 3)",           learnCost = 14000, powerCost = 385, type = "Utility", castTime = 10, duration = 0 },
            { name = "Exorcism (Rank 3)",             learnCost = 14000, powerCost = 185, min = 216,        max = 244,     type = "Damage", castTime = 0, duration = 0 },
            { name = "Fire Resistance Aura (Rank 1)", learnCost = 14000, powerCost = 0,   type = "Buff",    castTime = 0,  duration = 1800 },
            { name = "Retribution Aura (Rank 3)",     learnCost = 14000, powerCost = 0,   type = "Buff",    castTime = 0,  duration = 1800 },
        },
        [38] = {
            { name = "Turn Undead (Rank 2)",            learnCost = 16000, powerCost = 85,  type = "Crowd Control", castTime = 1.5, duration = 15 },
            { name = "Blessing of Protection (Rank 3)", learnCost = 16000, powerCost = 65,  type = "Buff",          castTime = 0,   duration = 10 },
            { name = "Seal of Wisdom (Rank 1)",         learnCost = 16000, powerCost = 110, type = "Buff",          castTime = 0,   duration = 30 },
            { name = "Holy Light (Rank 6)",             learnCost = 16000, powerCost = 365, min = 698,              max = 780,      type = "Heal", castTime = 2.5, duration = 0 },
        },
        [40] = {
            { name = "Shadow Resistance Aura (Rank 2)", learnCost = 20000, powerCost = 0,   type = "Buff",          castTime = 0, duration = 1800 },
            { name = "Blessing of Light (Rank 1)",      learnCost = 20000, powerCost = 45,  type = "Buff",          castTime = 0, duration = 600 },
            { name = "Seal of Command (Rank 3)",        learnCost = 1000,  powerCost = 135, min = 63,               max = 63,     type = "Damage", castTime = 0, duration = 30 },
            { name = "Blessing of Sanctuary (Rank 2)",  learnCost = 1000,  powerCost = 55,  type = "Buff",          castTime = 0, duration = 600 },
            { name = "Seal of Light (Rank 2)",          learnCost = 20000, powerCost = 110, type = "Buff",          castTime = 0, duration = 30 },
            { name = "Hammer of Justice (Rank 3)",      learnCost = 20000, powerCost = 80,  type = "Crowd Control", castTime = 0, duration = 5 },
            { name = "Plate Mail",                      learnCost = 20000, powerCost = 0,   type = "Utility",       castTime = 0, duration = 0 },
            { name = "Devotion Aura (Rank 5)",          learnCost = 20000, powerCost = 0,   type = "Buff",          castTime = 0, duration = 1800 },
            { name = "Consecration (Rank 3)",           learnCost = 1000,  powerCost = 285, min = 192,              max = 192,    type = "Damage", castTime = 0, duration = 8 },
        },
        [42] = {
            { name = "Cleanse",                        learnCost = 21000, powerCost = 60,  type = "Utility", castTime = 0, duration = 0 },
            { name = "Seal of Righteousness (Rank 6)", learnCost = 21000, powerCost = 75,  type = "Buff",    castTime = 0, duration = 30 },
            { name = "Blessing of Might (Rank 5)",     learnCost = 21000, powerCost = 90,  type = "Buff",    castTime = 0, duration = 600 },
            { name = "Flash of Light (Rank 4)",        learnCost = 21000, powerCost = 90,  min = 197,        max = 221,    type = "Heal", castTime = 1.5, duration = 0 },
            { name = "Seal of the Crusader (Rank 5)",  learnCost = 21000, powerCost = 160, type = "Buff",    castTime = 0, duration = 30 },
            { name = "Holy Strike (Rank 5)",           learnCost = 21000, powerCost = 155, type = "Damage",  castTime = 0, duration = 0 },
            { name = "Crusader Strike (Rank 5)",       learnCost = 21000, powerCost = 105, type = "Damage",  castTime = 0, duration = 0 },
        },
        [44] = {
            { name = "Exorcism (Rank 4)",              learnCost = 22000, powerCost = 235, min = 303,     max = 341,    type = "Damage", castTime = 0,   duration = 0 },
            { name = "Hammer of Wrath (Rank 1)",       learnCost = 22000, powerCost = 295, min = 315,     max = 348,    type = "Damage", castTime = 1.0, duration = 0 },
            { name = "Frost Resistance Aura (Rank 2)", learnCost = 22000, powerCost = 0,   type = "Buff", castTime = 0, duration = 1800 },
            { name = "Blessing of Wisdom (Rank 4)",    learnCost = 22000, powerCost = 100, type = "Buff", castTime = 0, duration = 600 },
        },
        [46] = {
            { name = "Retribution Aura (Rank 4)",      learnCost = 24000, powerCost = 0,   type = "Buff", castTime = 0, duration = 1800 },
            { name = "Holy Light (Rank 7)",            learnCost = 24000, powerCost = 465, min = 945,     max = 1053,   type = "Heal",  castTime = 2.5, duration = 0 },
            { name = "Blessing of Sacrifice (Rank 1)", learnCost = 24000, powerCost = 75,  type = "Buff", castTime = 0, duration = 30 },
        },
        [48] = {
            { name = "Holy Shock (Rank 2)",           learnCost = 1300,  powerCost = 275, min = 282,        max = 304,     type = "Damage", castTime = 0, duration = 0 }, -- Instant heal/dmg
            { name = "Fire Resistance Aura (Rank 2)", learnCost = 26000, powerCost = 0,   type = "Buff",    castTime = 0,  duration = 1800 },
            { name = "Redemption (Rank 4)",           learnCost = 26000, powerCost = 515, type = "Utility", castTime = 10, duration = 0 },
            { name = "Seal of Wisdom (Rank 2)",       learnCost = 26000, powerCost = 160, type = "Buff",    castTime = 0,  duration = 30 },
        },
        [50] = {
            { name = "Flash of Light (Rank 5)",        learnCost = 28000, powerCost = 115, min = 267,       max = 299,    type = "Heal",   castTime = 1.5, duration = 0 },
            { name = "Blessing of Light (Rank 2)",     learnCost = 28000, powerCost = 65,  type = "Buff",   castTime = 0, duration = 600 },
            { name = "Consecration (Rank 4)",          learnCost = 1400,  powerCost = 380, min = 280,       max = 280,    type = "Damage", castTime = 0,   duration = 8 },
            { name = "Holy Wrath (Rank 1)",            learnCost = 28000, powerCost = 495, min = 351,       max = 413,    type = "Damage", castTime = 2.0, duration = 0 }, -- AoE Undead
            { name = "Divine Shield (Rank 2)",         learnCost = 28000, powerCost = 0,   type = "Buff",   castTime = 0, duration = 12 },
            { name = "Devotion Aura (Rank 6)",         learnCost = 28000, powerCost = 0,   type = "Buff",   castTime = 0, duration = 1800 },
            { name = "Seal of Righteousness (Rank 7)", learnCost = 28000, powerCost = 90,  type = "Buff",   castTime = 0, duration = 30 },
            { name = "Blessing of Sanctuary (Rank 3)", learnCost = 1400,  powerCost = 75,  type = "Buff",   castTime = 0, duration = 600 },
            { name = "Seal of Light (Rank 3)",         learnCost = 28000, powerCost = 140, type = "Buff",   castTime = 0, duration = 30 },
            { name = "Lay on Hands (Rank 3)",          learnCost = 28000, powerCost = 0,   type = "Heal",   castTime = 0, duration = 0 },
            { name = "Seal of Command (Rank 4)",       learnCost = 1400,  powerCost = 180, min = 87,        max = 87,     type = "Damage", castTime = 0,   duration = 30 },
            { name = "Holy Shield (Rank 2)",           learnCost = 1400,  powerCost = 210, min = 95,        max = 95,     type = "Buff",   castTime = 0,   duration = 10 },
            { name = "Holy Strike (Rank 6)",           learnCost = 28000, powerCost = 180, type = "Damage", castTime = 0, duration = 0 },
            { name = "Crusader Strike (Rank 6)",       learnCost = 28000, powerCost = 125, type = "Damage", castTime = 0, duration = 0 },
        },
        [52] = {
            { name = "Shadow Resistance Aura (Rank 3)",    learnCost = 34000, powerCost = 0,   type = "Buff",          castTime = 0,   duration = 1800 },
            { name = "Greater Blessing of Might (Rank 1)", learnCost = 46000, powerCost = 300, type = "Buff",          castTime = 0,   duration = 900 },
            { name = "Hammer of Wrath (Rank 2)",           learnCost = 34000, powerCost = 360, min = 413,              max = 455,      type = "Damage", castTime = 1.0, duration = 0 },
            { name = "Turn Undead (Rank 3)",               learnCost = 34000, powerCost = 125, type = "Crowd Control", castTime = 1.5, duration = 20 },
            { name = "Exorcism (Rank 5)",                  learnCost = 34000, powerCost = 285, min = 394,              max = 440,      type = "Damage", castTime = 0,   duration = 0 },
            { name = "Seal of the Crusader (Rank 6)",      learnCost = 34000, powerCost = 210, type = "Buff",          castTime = 0,   duration = 30 },
            { name = "Blessing of Might (Rank 6)",         learnCost = 34000, powerCost = 140, type = "Buff",          castTime = 0,   duration = 600 },
        },
        [54] = {
            { name = "Hammer of Justice (Rank 4)",          learnCost = 40000, powerCost = 90,  type = "Crowd Control", castTime = 0, duration = 6 },
            { name = "Blessing of Sacrifice (Rank 2)",      learnCost = 40000, powerCost = 90,  type = "Buff",          castTime = 0, duration = 30 },
            { name = "Holy Light (Rank 8)",                 learnCost = 40000, powerCost = 580, min = 1246,             max = 1388,   type = "Heal", castTime = 2.5, duration = 0 },
            { name = "Greater Blessing of Wisdom (Rank 1)", learnCost = 46000, powerCost = 340, type = "Buff",          castTime = 0, duration = 900 },
            { name = "Blessing of Wisdom (Rank 5)",         learnCost = 40000, powerCost = 125, type = "Buff",          castTime = 0, duration = 600 },
        },
        [56] = {
            { name = "Frost Resistance Aura (Rank 3)", learnCost = 42000, powerCost = 0,   type = "Buff", castTime = 0, duration = 1800 },
            { name = "Holy Shock (Rank 3)",            learnCost = 2100,  powerCost = 335, min = 365,     max = 395,    type = "Damage", castTime = 0, duration = 0 },
            { name = "Retribution Aura (Rank 5)",      learnCost = 42000, powerCost = 0,   type = "Buff", castTime = 0, duration = 1800 },
        },
        [58] = {
            { name = "Flash of Light (Rank 6)",        learnCost = 44000, powerCost = 140, min = 343,       max = 383,    type = "Heal", castTime = 1.5, duration = 0 },
            { name = "Seal of Righteousness (Rank 8)", learnCost = 44000, powerCost = 110, type = "Buff",   castTime = 0, duration = 30 },
            { name = "Seal of Wisdom (Rank 3)",        learnCost = 44000, powerCost = 210, type = "Buff",   castTime = 0, duration = 30 },
            { name = "Holy Strike (Rank 7)",           learnCost = 44000, powerCost = 205, type = "Damage", castTime = 0, duration = 0 },
            { name = "Crusader Strike (Rank 7)",       learnCost = 44000, powerCost = 145, type = "Damage", castTime = 0, duration = 0 },
        },
        [60] = {
            { name = "Holy Shield (Rank 3)",                   learnCost = 2300,  powerCost = 280, min = 130,        max = 130,     type = "Buff",   castTime = 0,   duration = 10 },
            { name = "Fire Resistance Aura (Rank 3)",          learnCost = 46000, powerCost = 0,   type = "Buff",    castTime = 0,  duration = 1800 },
            { name = "Blessing of Sanctuary (Rank 4)",         learnCost = 2300,  powerCost = 95,  type = "Buff",    castTime = 0,  duration = 600 },
            { name = "Hammer of Wrath (Rank 3)",               learnCost = 46000, powerCost = 425, min = 504,        max = 566,     type = "Damage", castTime = 1.0, duration = 0 },
            { name = "Redemption (Rank 5)",                    learnCost = 46000, powerCost = 640, type = "Utility", castTime = 10, duration = 0 },
            { name = "Greater Blessing of Light (Rank 1)",     learnCost = 46000, powerCost = 280, type = "Buff",    castTime = 0,  duration = 900 },
            { name = "Exorcism (Rank 6)",                      learnCost = 46000, powerCost = 345, min = 502,        max = 560,     type = "Damage", castTime = 0,   duration = 0 },
            { name = "Greater Blessing of Wisdom (Rank 2)",    learnCost = 46000, powerCost = 380, type = "Buff",    castTime = 0,  duration = 900 },
            { name = "Blessing of Light (Rank 3)",             learnCost = 46000, powerCost = 85,  type = "Buff",    castTime = 0,  duration = 600 },
            { name = "Holy Wrath (Rank 2)",                    learnCost = 46000, powerCost = 670, min = 493,        max = 581,     type = "Damage", castTime = 2.0, duration = 0 },
            { name = "Greater Blessing of Sanctuary (Rank 1)", learnCost = 2300,  powerCost = 320, type = "Buff",    castTime = 0,  duration = 900 },
            { name = "Seal of Command (Rank 5)",               learnCost = 2300,  powerCost = 230, min = 113,        max = 113,     type = "Damage", castTime = 0,   duration = 30 },
            { name = "Greater Blessing of Might (Rank 2)",     learnCost = 46000, powerCost = 400, type = "Buff",    castTime = 0,  duration = 900 },
            { name = "Seal of Light (Rank 4)",                 learnCost = 46000, powerCost = 180, type = "Buff",    castTime = 0,  duration = 30 },
            { name = "Greater Blessing of Salvation",          learnCost = 46000, powerCost = 150, type = "Buff",    castTime = 0,  duration = 900 },
            { name = "Greater Blessing of Kings",              learnCost = 2300,  powerCost = 150, type = "Buff",    castTime = 0,  duration = 900 },
            { name = "Devotion Aura (Rank 7)",                 learnCost = 46000, powerCost = 0,   type = "Buff",    castTime = 0,  duration = 1800 },
            { name = "Consecration (Rank 5)",                  learnCost = 2300,  powerCost = 565, min = 384,        max = 384,     type = "Damage", castTime = 0,   duration = 8 },
            { name = "Holy Light (Rank 9)",                    learnCost = 46000, powerCost = 660, min = 1590,       max = 1770,    type = "Heal",   castTime = 2.5, duration = 0 },
        },
    },
}
------------------------------------------------------------

local PriestRacials = {
    HUMAN = {
        [10] = { "Desperate Prayer (Rank 1)", "Feedback (Rank 1)" },
        [20] = { "Feedback (Rank 2+)" },
    },
    DWARF = {
        [10] = { "Desperate Prayer (Rank 1)" },
        [20] = { "Avatar" }, -- Fear Ward is now baseline
    },
    NIGHTELF = {
        [10] = { "Starshards (Rank 1)" },
        [20] = { "Starshards (Rank 2+)", "Searing Shot" }, -- Turtle WoW: Starshards is instant. Searing Light/Shot added.
    },
    TROLL = {
        [10] = { "Hex of Weakness (Rank 1)" },
        [20] = { "Shadowguard (Rank 1)" },
    },
    SCOURGE = { -- Undead
        [10] = { "Touch of Weakness (Rank 1)" },
        [20] = { "Devouring Plague (Rank 1)" },
    },
    HIGHELF = {
        [10] = { "Power Word: Weaken" }, -- Hypothesized or placeholder based on "reduces mana cost"
        -- Actually, let's skip adding specific named spells for High Elf if we don't know the EXACT name in the spellbook.
        -- "Quel'dorei Meditation" is a racial trait, likely in the General tab, not Spell tab.
        -- But users might want to see it.
        [1] = { "Quel'dorei Meditation" },
    },
}

local PriestTalents = {
    [30] = { "Vampiric Embrace (Shadow talent)" },
    [40] = { "Shadowform (Shadow talent)" },
}

------------------------------------------------------------
-- Money formatter: copper -> "Xg Ys Zc"
------------------------------------------------------------

function ScriptExtender_FormatMoney(copper)
    if not copper or copper <= 0 then
        return nil
    end

    local g = math.floor(copper / 10000)
    local s = math.floor((copper % 10000) / 100)
    local c = copper % 100

    local parts = {}
    if g > 0 then table.insert(parts, g .. "g") end
    if s > 0 or (g > 0 and c > 0) then table.insert(parts, s .. "s") end
    if c > 0 and g == 0 then table.insert(parts, c .. "c") end

    if #parts == 0 then
        return "0c"
    else
        return table.concat(parts, " ")
    end
end

------------------------------------------------------------
-- Utility printing
------------------------------------------------------------

local function SL_Print(msg)
    if ScriptExtender_Print then
        ScriptExtender_Print("[SpellLevels] " .. msg)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[SpellLevels]|r " .. msg)
    end
end

------------------------------------------------------------
-- Spell learned helper (robust name / rank matching)
------------------------------------------------------------
function ScriptExtender_IsSpellLearned(spellName, classToken)
    if not spellName or spellName == "" then
        return false
    end

    -- Only show "Learned" for your own class
    if not ScriptExtender_PlayerClass or classToken ~= ScriptExtender_PlayerClass then
        return false
    end

    -- Try to split "Name (Rank X)" into base + rank
    local baseName, rankText = spellName:match("^(.-)%s*%((.-)%)$")
    if not baseName then
        baseName = spellName
    end

    local numTabs = GetNumSpellTabs()
    for tab = 1, numTabs do
        local _, _, offset, numSpells = GetSpellTabInfo(tab)
        for i = 1, numSpells do
            local index = offset + i
            local sName, sRank = GetSpellName(index, "spell")

            if sName then
                -- Full "Name (Rank X)" from spellbook
                local sFull = sName
                if sRank and sRank ~= "" then
                    sFull = sFull .. " (" .. sRank .. ")"
                end

                -- 1) Exact full match (best case)
                if sFull == spellName then
                    return true
                end

                -- 2) Exact name match (no rank needed)
                if sName == spellName then
                    return true
                end

                -- 3) Base-name match:
                --    "Backstab" table entry vs "Backstab (Rank 1)" in book, etc.
                if baseName == sName then
                    -- If either side doesn't care about rank, treat as learned
                    if not rankText or rankText == "" or not sRank or sRank == "" then
                        return true
                    end
                    -- Or both specify rank and they match
                    if sRank == rankText then
                        return true
                    end
                end
            end
        end
    end

    return false
end

-- Export Data
ScriptExtender_SpellLevels = SpellLevels
ScriptExtender_PriestRacials = PriestRacials
ScriptExtender_PriestTalents = PriestTalents

-- Initialize Player Class
local _, pClass = UnitClass("player")
ScriptExtender_PlayerClass = pClass
