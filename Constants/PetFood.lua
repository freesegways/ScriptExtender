-- Constants/PetFood.lua
-- Pet food database for Hunter auto-feed.
-- Two tables:
--   PET_FAMILY_DIETS: maps pet family -> list of food categories it eats
--   PET_FOOD_ITEMS:   maps item name  -> { category, level }
--     "level" = the food's effective level for happiness calculation

---------------------------------------------------------------------------
-- PET FAMILY DIETS
-- Source: vanilla 1.12 pet family data (Petopia / wowwiki)
---------------------------------------------------------------------------
PET_FAMILY_DIETS = {
    ["Cat"]          = { "Meat", "Fish" },
    ["Wolf"]         = { "Meat" },
    ["Bear"]         = { "Meat", "Fish", "Bread", "Fruit", "Fungus", "Cheese" },
    ["Boar"]         = { "Meat", "Fish", "Bread", "Fruit", "Fungus", "Cheese" },
    ["Raptor"]       = { "Meat" },
    ["Tallstrider"]  = { "Meat", "Fruit", "Fungus" },
    ["Spider"]       = { "Meat" },
    ["Scorpid"]      = { "Meat" },
    ["Crab"]         = { "Meat", "Fish", "Bread", "Fruit", "Fungus" },
    ["Gorilla"]      = { "Fruit", "Fungus" },
    ["Crocolisk"]    = { "Meat", "Fish" },
    ["Carrion Bird"] = { "Meat", "Fish" },
    ["Owl"]          = { "Meat" },
    ["Wind Serpent"] = { "Fish", "Bread", "Cheese" },
    ["Bat"]          = { "Fruit", "Fungus" },
    ["Hyena"]        = { "Meat", "Fruit" },
    ["Turtle"]       = { "Fish", "Fruit", "Fungus" },
    ["Serpent"]      = { "Meat" },
    -- TurtleWoW custom families (if any, add here)
}

---------------------------------------------------------------------------
-- PET FOOD ITEMS
-- Maps item name -> { category = "Meat"|"Fish"|"Bread"|"Fruit"|"Fungus"|"Cheese", level = N }
-- "level" is the item's effective food level (roughly itemLevel / 10).
-- Pets refuse food more than 30 levels below them.
---------------------------------------------------------------------------
PET_FOOD_ITEMS = {

    -- =====================================================================
    -- MEAT (Raw drops, cooked dishes, vendor jerky)
    -- =====================================================================

    -- Raw Meat (trade goods / drops)
    ["Chunk of Boar Meat"]          = { category = "Meat", level = 1 },
    ["Stringy Wolf Meat"]           = { category = "Meat", level = 5 },
    ["Boar Meat"]                   = { category = "Meat", level = 5 },
    ["Small Spider Leg"]            = { category = "Meat", level = 5 },
    ["Coyote Meat"]                 = { category = "Meat", level = 8 },
    ["Bear Meat"]                   = { category = "Meat", level = 10 },
    ["Lean Wolf Flank"]             = { category = "Meat", level = 10 },
    ["Boar Ribs"]                   = { category = "Meat", level = 10 },
    ["Crawler Meat"]                = { category = "Meat", level = 10 },
    ["Crawler Claw"]                = { category = "Meat", level = 10 },
    ["Kodo Meat"]                   = { category = "Meat", level = 12 },
    ["Stag Meat"]                   = { category = "Meat", level = 12 },
    ["Raptor Flesh"]                = { category = "Meat", level = 15 },
    ["Raptor Egg"]                  = { category = "Meat", level = 15 },
    ["Lean Venison"]                = { category = "Meat", level = 15 },
    ["Murloc Eye"]                  = { category = "Meat", level = 15 },
    ["Tiger Meat"]                  = { category = "Meat", level = 18 },
    ["Tender Crocolisk Meat"]       = { category = "Meat", level = 18 },
    ["Mystery Meat"]                = { category = "Meat", level = 25 },
    ["Red Wolf Meat"]               = { category = "Meat", level = 25 },
    ["Lion Meat"]                   = { category = "Meat", level = 25 },
    ["Giant Egg"]                   = { category = "Meat", level = 25 },
    ["Buzzard Wing"]                = { category = "Meat", level = 30 },
    ["Tender Wolf Meat"]            = { category = "Meat", level = 30 },
    ["Big Bear Meat"]               = { category = "Meat", level = 30 },
    ["Turtle Meat"]                 = { category = "Meat", level = 28 },
    ["Heavy Kodo Meat"]             = { category = "Meat", level = 35 },
    ["Sandworm Meat"]               = { category = "Meat", level = 45 },
    ["Bear Flank"]                  = { category = "Meat", level = 45 },
    ["Tender Crab Meat"]            = { category = "Meat", level = 30 },
    ["White Spider Meat"]           = { category = "Meat", level = 20 },
    ["Leg Meat"]                    = { category = "Meat", level = 1 },

    -- Cooked Meat
    ["Charred Wolf Meat"]           = { category = "Meat", level = 1 },
    ["Roasted Boar Meat"]           = { category = "Meat", level = 5 },
    ["Smoked Bear Meat"]            = { category = "Meat", level = 10 },
    ["Coyote Steak"]                = { category = "Meat", level = 10 },
    ["Dry Pork Ribs"]               = { category = "Meat", level = 12 },
    ["Crab Cake"]                   = { category = "Meat", level = 10 },
    ["Seasoned Wolf Kabob"]         = { category = "Meat", level = 15 },
    ["Roast Raptor"]                = { category = "Meat", level = 20 },
    ["Lean Wolf Steak"]             = { category = "Meat", level = 20 },
    ["Murloc Fin Soup"]             = { category = "Meat", level = 15 },
    ["Scorpid Surprise"]            = { category = "Meat", level = 12 },
    ["Carrion Surprise"]            = { category = "Meat", level = 35 },
    ["Barbecued Buzzard Wing"]      = { category = "Meat", level = 35 },
    ["Tender Wolf Steak"]           = { category = "Meat", level = 40 },
    ["Monster Omelet"]              = { category = "Meat", level = 40 },
    ["Spider Sausage"]              = { category = "Meat", level = 35 },
    ["Roasted Quail"]               = { category = "Meat", level = 35 },
    ["Smoked Desert Dumplings"]     = { category = "Meat", level = 45 },
    ["Frog Leg Stew"]               = { category = "Meat", level = 20 },
    ["Goblin Deviled Clams"]        = { category = "Meat", level = 20 },
    ["Soothing Turtle Bisque"]      = { category = "Meat", level = 30 },
    ["Juicy Bear Burger"]           = { category = "Meat", level = 45 },
    ["Spiced Chili Crab"]           = { category = "Meat", level = 40 },
    ["Hot Lion Chops"]              = { category = "Meat", level = 25 },
    ["Curiously Tasty Omelet"]      = { category = "Meat", level = 25 },
    ["Dragonbreath Chili"]          = { category = "Meat", level = 35 },

    -- Vendor Meat / Jerky
    ["Tough Jerky"]                 = { category = "Meat", level = 1 },
    ["Haunch of Meat"]              = { category = "Meat", level = 5 },
    ["Mutton Chop"]                 = { category = "Meat", level = 15 },
    ["Wild Hog Shank"]              = { category = "Meat", level = 25 },
    ["Cured Ham Steak"]             = { category = "Meat", level = 35 },

    -- =====================================================================
    -- FISH (Raw catches, cooked fish)
    -- =====================================================================

    -- Raw Fish
    ["Raw Brilliant Smallfish"]     = { category = "Fish", level = 1 },
    ["Raw Slitherskin Mackerel"]    = { category = "Fish", level = 1 },
    ["Raw Longjaw Mud Snapper"]     = { category = "Fish", level = 5 },
    ["Raw Loch Frenzy"]             = { category = "Fish", level = 5 },
    ["Raw Bristle Whisker Catfish"] = { category = "Fish", level = 15 },
    ["Raw Sagefish"]                = { category = "Fish", level = 10 },
    ["Raw Rockscale Cod"]           = { category = "Fish", level = 25 },
    ["Raw Mithril Head Trout"]      = { category = "Fish", level = 25 },
    ["Raw Redgill"]                 = { category = "Fish", level = 35 },
    ["Raw Spotted Yellowtail"]      = { category = "Fish", level = 35 },
    ["Raw Nightfin Snapper"]        = { category = "Fish", level = 35 },
    ["Raw Sunscale Salmon"]         = { category = "Fish", level = 35 },
    ["Raw Glossy Mightfish"]        = { category = "Fish", level = 45 },
    ["Large Raw Mightfish"]         = { category = "Fish", level = 45 },
    ["Raw Whitescale Salmon"]       = { category = "Fish", level = 45 },
    ["Winter Squid"]                = { category = "Fish", level = 35 },
    ["Raw Summer Bass"]             = { category = "Fish", level = 25 },
    ["Deviate Fish"]                = { category = "Fish", level = 5 },
    ["Sickly Looking Fish"]         = { category = "Fish", level = 1 },
    ["Nightcrawlers"]               = { category = "Fish", level = 15 },
    ["Bloodbelly Fish"]             = { category = "Fish", level = 1 },

    -- Cooked Fish
    ["Slitherskin Mackerel"]        = { category = "Fish", level = 1 },
    ["Brilliant Smallfish"]         = { category = "Fish", level = 1 },
    ["Longjaw Mud Snapper"]         = { category = "Fish", level = 5 },
    ["Smoked Sagefish"]             = { category = "Fish", level = 10 },
    ["Bristle Whisker Catfish"]     = { category = "Fish", level = 15 },
    ["Sagefish Delight"]            = { category = "Fish", level = 30 },
    ["Mithril Head Trout"]          = { category = "Fish", level = 25 },
    ["Rockscale Cod"]               = { category = "Fish", level = 25 },
    ["Spotted Yellowtail"]          = { category = "Fish", level = 35 },
    ["Grilled Squid"]               = { category = "Fish", level = 35 },
    ["Nightfin Soup"]               = { category = "Fish", level = 40 },
    ["Poached Sunscale Salmon"]     = { category = "Fish", level = 40 },
    ["Hot Smoked Bass"]             = { category = "Fish", level = 25 },
    ["Cooked Glossy Mightfish"]     = { category = "Fish", level = 45 },
    ["Filet of Redgill"]            = { category = "Fish", level = 35 },
    ["Baked Salmon"]                = { category = "Fish", level = 45 },
    ["Lobster Stew"]                = { category = "Fish", level = 45 },
    ["Savory Deviate Delight"]      = { category = "Fish", level = 5 },
    ["Clamlette Surprise"]          = { category = "Fish", level = 20 },
    ["Boiled Clams"]                = { category = "Fish", level = 5 },

    -- =====================================================================
    -- BREAD (Vendor bread, conjured bread, baked goods)
    -- =====================================================================

    ["Tough Hunk of Bread"]         = { category = "Bread", level = 1 },
    ["Freshly Baked Bread"]         = { category = "Bread", level = 5 },
    ["Moist Cornbread"]             = { category = "Bread", level = 15 },
    ["Mulgore Spice Bread"]         = { category = "Bread", level = 25 },
    ["Soft Banana Bread"]           = { category = "Bread", level = 35 },
    ["Homemade Cherry Pie"]         = { category = "Bread", level = 45 },
    ["Spice Bread"]                 = { category = "Bread", level = 5 },

    -- Conjured Bread (Mage)
    ["Conjured Muffin"]             = { category = "Bread", level = 1 },
    ["Conjured Bread"]              = { category = "Bread", level = 5 },
    ["Conjured Rye"]                = { category = "Bread", level = 15 },
    ["Conjured Pumpernickel"]       = { category = "Bread", level = 25 },
    ["Conjured Sourdough"]          = { category = "Bread", level = 35 },
    ["Conjured Sweet Roll"]         = { category = "Bread", level = 45 },
    ["Conjured Cinnamon Roll"]      = { category = "Bread", level = 50 },

    -- Enriched Manna Biscuit (Conjured combo food/drink)
    ["Enriched Manna Biscuit"]      = { category = "Bread", level = 55 },
    ["Alterac Manna Biscuit"]       = { category = "Bread", level = 35 },

    -- =====================================================================
    -- FRUIT
    -- =====================================================================

    ["Shiny Red Apple"]             = { category = "Fruit", level = 1 },
    ["Tel'Abim Banana"]             = { category = "Fruit", level = 1 },
    ["Snapvine Watermelon"]         = { category = "Fruit", level = 25 },
    ["Goldenbark Apple"]            = { category = "Fruit", level = 35 },
    ["Moon Harvest Pumpkin"]        = { category = "Fruit", level = 35 },
    ["Dried Peaches"]               = { category = "Fruit", level = 5 },
    ["Green Garden Tea"]            = { category = "Fruit", level = 15 },
    ["Skullfish Soup"]              = { category = "Fruit", level = 35 },
    ["Essence Mango"]               = { category = "Fruit", level = 45 },
    ["Hyjal Nectar"]                = { category = "Fruit", level = 35 },
    ["Blessed Sunfruit"]            = { category = "Fruit", level = 45 },
    ["Whipper Root Tuber"]          = { category = "Fruit", level = 45 },
    ["Deep Fried Plantains"]        = { category = "Fruit", level = 45 },
    ["Runn Tum Tuber"]              = { category = "Fruit", level = 1 },
    ["Runn Tum Tuber Surprise"]     = { category = "Fruit", level = 45 },

    -- =====================================================================
    -- FUNGUS
    -- =====================================================================

    ["Forest Mushroom Cap"]         = { category = "Fungus", level = 1 },
    ["Red-Speckled Mushroom"]       = { category = "Fungus", level = 5 },
    ["Spongy Morel"]                = { category = "Fungus", level = 15 },
    ["Delicious Cave Mold"]         = { category = "Fungus", level = 25 },
    ["Raw Black Truffle"]           = { category = "Fungus", level = 35 },
    ["Dried King Bolete"]           = { category = "Fungus", level = 45 },
    ["Deeprock Salt"]               = { category = "Fungus", level = 35 },

    -- =====================================================================
    -- CHEESE
    -- =====================================================================

    ["Dwarven Mild"]                = { category = "Cheese", level = 1 },
    ["Dalaran Sharp"]               = { category = "Cheese", level = 5 },
    ["Stormwind Brie"]              = { category = "Cheese", level = 15 },
    ["Fine Aged Cheddar"]           = { category = "Cheese", level = 25 },
    ["Alterac Swiss"]               = { category = "Cheese", level = 35 },
    ["Darnassian Bleu"]             = { category = "Cheese", level = 45 },
}
