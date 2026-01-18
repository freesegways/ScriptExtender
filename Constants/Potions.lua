-- Database of Instant Consumables (Potions, Runes, Etc)
-- Used by General/Survival.lua (Health) and General/Mana.lua (Mana)

ScriptExtender_PotionDB = {
    
    -- ==========================================
    -- HEALTH CONSUMABLES
    -- Checked by UseSurvival() for keeping you alive
    -- ==========================================
    HEALTH = {
        -- HEALTHSTONES (Shared Cooldown: Conjured)
        { name = "Major Healthstone", min = 1200, max = 1200, type = "Healthstone" },
        { name = "Great Healthstone", min = 800, max = 800, type = "Healthstone" },
        { name = "Healthstone", min = 500, max = 500, type = "Healthstone" },
        { name = "Lesser Healthstone", min = 250, max = 250, type = "Healthstone" },
        { name = "Minor Healthstone", min = 100, max = 100, type = "Healthstone" },

        -- HEALING POTIONS (Shared Cooldown: Potion)
        { name = "Major Healing Potion", min = 1050, max = 1750, type = "Potion" }, 
        { name = "Superior Healing Potion", min = 700, max = 900, type = "Potion" }, 
        { name = "Great Healing Potion", min = 455, max = 585, type = "Potion" }, 
        { name = "Healing Potion", min = 280, max = 360, type = "Potion" }, 
        { name = "Lesser Healing Potion", min = 140, max = 180, type = "Potion" }, 
        { name = "Minor Healing Potion", min = 70, max = 90, type = "Potion" }, 

        -- PLANTS / CRYSTALS
        { name = "Whipper Root Tuber", min = 700, max = 900, type = "Plant" },
        { name = "Crystal Restore", min = 670, max = 890, type = "Crystal" },
        
        -- HYBRIDS (Listed here effectively as a ~425 HP potion)
        { name = "Night Dragon's Breath", min = 394, max = 456, type = "Plant" }
    },

    -- ==========================================
    -- MANA CONSUMABLES
    -- Checked by UseSmartMana() for resource efficiency
    -- ==========================================
    MANA = {
        -- MANA POTIONS
        { name = "Major Mana Potion", min = 1350, max = 2250, type = "Potion" },  -- Avg 1800
        { name = "Superior Mana Potion", min = 900, max = 1500, type = "Potion" }, -- Avg 1200
        { name = "Great Mana Potion", min = 700, max = 900, type = "Potion" },    -- Avg 800
        { name = "Mana Potion", min = 455, max = 585, type = "Potion" },         -- Avg 520
        { name = "Lesser Mana Potion", min = 280, max = 360, type = "Potion" },    -- Avg 320
        { name = "Minor Mana Potion", min = 140, max = 180, type = "Potion" },     -- Avg 160

        -- RUNES (Danger: Costs Health!)
        { name = "Dark Rune", min = 900, max = 1500, type = "Rune", healthCost = 600 }, 
        { name = "Demonic Rune", min = 900, max = 1500, type = "Rune", healthCost = 600 },
        
        -- HYBRIDS
        { name = "Night Dragon's Breath", min = 394, max = 456, type = "Plant" }
    }
}
