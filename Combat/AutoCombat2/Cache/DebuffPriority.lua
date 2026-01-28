-- Combat/AutoCombat2/Cache/DebuffPriority.lua
-- Defines the static priority table for dispels (Higher = More Urgent)

if ScriptExtender_DebuffPriority then return end

ScriptExtender_DebuffPriority = {
    -- HARD CC (100) - Target is useless
    ["Polymorph"] = { type = "Magic", priority = 100 },
    ["Fear"] = { type = "Magic", priority = 100 },
    ["Psychic Scream"] = { type = "Magic", priority = 100 },
    ["Hammer of Justice"] = { type = "Magic", priority = 100 },

    -- HEAVY DOTS (70) - Target dying fast
    ["Shadow Word: Pain"] = { type = "Magic", priority = 70 },
    ["Corruption"] = { type = "Magic", priority = 60 },
    ["Immolate"] = { type = "Magic", priority = 60 },

    -- SLOWS/ROOTS (40)
    ["Frost Nova"] = { type = "Magic", priority = 40 },
    ["Entangling Roots"] = { type = "Magic", priority = 40 },
    ["Cone of Cold"] = { type = "Magic", priority = 30 },
    ["Frostbolt"] = { type = "Magic", priority = 30 },

    -- MINOR/ANNOYANCE (20)
    ["Curse of Weakness"] = { type = "Curse", priority = 20 },
    ["Curse of Tongues"] = { type = "Curse", priority = 20 },
    ["Faerie Fire"] = { type = "Magic", priority = 10 }
}
