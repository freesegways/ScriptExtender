-- Tests for AutoFeedPet
-- Covers: no pet, pet dead, in combat, already happy, diet matching, no food, cheapest pick

-- Helper: build a mock bag with specific items
local function mockBag(items)
    -- items = { { bag=0, slot=1, link="item:123:[Boar Meat]" }, ... }
    return function(b, s)
        for _, item in ipairs(items) do
            if item.bag == b and item.slot == s then
                return item.link
            end
        end
        return nil
    end
end

-- 1. NO PET
ScriptExtender_Tests["AutoFeedPet_NoPet"] = function(t)
    local castCalled = false
    t.Mock("UnitExists", function(unit)
        if unit == "pet" then return false end
        return true
    end)
    t.Mock("CastSpellByName", function() castCalled = true end)

    AutoFeedPet()
    t.AssertEqual({ actual = castCalled, expected = false })
end

-- 2. PET IS DEAD
ScriptExtender_Tests["AutoFeedPet_PetDead"] = function(t)
    local castCalled = false
    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitIsDead", function(unit)
        if unit == "pet" then return true end
        return false
    end)
    t.Mock("CastSpellByName", function() castCalled = true end)

    AutoFeedPet()
    t.AssertEqual({ actual = castCalled, expected = false })
end

-- 3. IN COMBAT
ScriptExtender_Tests["AutoFeedPet_InCombat"] = function(t)
    local castCalled = false
    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitIsDead", function() return false end)
    t.Mock("UnitAffectingCombat", function() return true end)
    t.Mock("CastSpellByName", function() castCalled = true end)

    AutoFeedPet()
    t.AssertEqual({ actual = castCalled, expected = false })
end

-- 4. ALREADY HAPPY
ScriptExtender_Tests["AutoFeedPet_AlreadyHappy"] = function(t)
    local castCalled = false
    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitIsDead", function() return false end)
    t.Mock("UnitAffectingCombat", function() return false end)
    t.Mock("GetPetHappiness", function() return 3 end)
    t.Mock("CastSpellByName", function() castCalled = true end)

    AutoFeedPet()
    t.AssertEqual({ actual = castCalled, expected = false })
end

-- 5. CAT WITH MEAT AND FISH — picks lowest level food
ScriptExtender_Tests["AutoFeedPet_CatPicksCheapest"] = function(t)
    local usedBag, usedSlot = nil, nil

    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitIsDead", function() return false end)
    t.Mock("UnitAffectingCombat", function() return false end)
    t.Mock("GetPetHappiness", function() return 1 end)        -- Unhappy
    t.Mock("UnitCreatureFamily", function() return "Cat" end) -- Cat eats Meat, Fish

    t.Mock("GetContainerNumSlots", function() return 3 end)
    t.Mock("GetContainerItemLink", mockBag({
        { bag = 0, slot = 1, link = "item:1:[Cured Ham Steak]" },   -- Meat, level 35
        { bag = 0, slot = 2, link = "item:2:[Tough Jerky]" },       -- Meat, level 1
        { bag = 0, slot = 3, link = "item:3:[Raw Rockscale Cod]" }, -- Fish, level 25
    }))

    t.Mock("CastSpellByName", function() end)
    t.Mock("UseContainerItem", function(b, s)
        usedBag = b
        usedSlot = s
    end)

    -- Backup and set known DB
    local BACKUP_PFI = PET_FOOD_ITEMS
    PET_FOOD_ITEMS = {
        ["Cured Ham Steak"]   = { category = "Meat", level = 35 },
        ["Tough Jerky"]       = { category = "Meat", level = 1 },
        ["Raw Rockscale Cod"] = { category = "Fish", level = 25 },
    }

    local BACKUP_PFD = PET_FAMILY_DIETS
    PET_FAMILY_DIETS = {
        ["Cat"] = { "Meat", "Fish" },
    }

    AutoFeedPet()

    PET_FOOD_ITEMS = BACKUP_PFI
    PET_FAMILY_DIETS = BACKUP_PFD

    -- Should pick Tough Jerky (level 1, cheapest)
    t.AssertEqual({ actual = usedBag, expected = 0 })
    t.AssertEqual({ actual = usedSlot, expected = 2 })
end

-- 6. WOLF WITH ONLY BREAD — no suitable food
ScriptExtender_Tests["AutoFeedPet_WolfNoBread"] = function(t)
    local castCalled = false

    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitIsDead", function() return false end)
    t.Mock("UnitAffectingCombat", function() return false end)
    t.Mock("GetPetHappiness", function() return 2 end)
    t.Mock("UnitCreatureFamily", function() return "Wolf" end) -- Wolf eats Meat only

    t.Mock("GetContainerNumSlots", function() return 2 end)
    t.Mock("GetContainerItemLink", mockBag({
        { bag = 0, slot = 1, link = "item:1:[Freshly Baked Bread]" }, -- Bread
        { bag = 0, slot = 2, link = "item:2:[Conjured Rye]" },        -- Bread
    }))

    t.Mock("CastSpellByName", function() castCalled = true end)
    t.Mock("UseContainerItem", function() end)

    local BACKUP_PFI = PET_FOOD_ITEMS
    PET_FOOD_ITEMS = {
        ["Freshly Baked Bread"] = { category = "Bread", level = 5 },
        ["Conjured Rye"]        = { category = "Bread", level = 15 },
    }

    local BACKUP_PFD = PET_FAMILY_DIETS
    PET_FAMILY_DIETS = { ["Wolf"] = { "Meat" } }

    AutoFeedPet()

    PET_FOOD_ITEMS = BACKUP_PFI
    PET_FAMILY_DIETS = BACKUP_PFD

    -- Should NOT have called CastSpellByName (no valid food)
    t.AssertEqual({ actual = castCalled, expected = false })
end

-- 7. BEAR (Omnivore) — picks from its diet, cheapest item
ScriptExtender_Tests["AutoFeedPet_BearOmnivore"] = function(t)
    local usedSlot = nil

    t.Mock("UnitExists", function() return true end)
    t.Mock("UnitIsDead", function() return false end)
    t.Mock("UnitAffectingCombat", function() return false end)
    t.Mock("GetPetHappiness", function() return 2 end)         -- Content
    t.Mock("UnitCreatureFamily", function() return "Bear" end) -- Bear eats everything

    t.Mock("GetContainerNumSlots", function() return 4 end)
    t.Mock("GetContainerItemLink", mockBag({
        { bag = 0, slot = 1, link = "item:1:[Alterac Swiss]" },       -- Cheese, level 35
        { bag = 0, slot = 2, link = "item:2:[Forest Mushroom Cap]" }, -- Fungus, level 1
        { bag = 0, slot = 3, link = "item:3:[Cured Ham Steak]" },     -- Meat, level 35
        { bag = 0, slot = 4, link = "item:4:[Shiny Red Apple]" },     -- Fruit, level 1
    }))

    t.Mock("CastSpellByName", function() end)
    t.Mock("UseContainerItem", function(b, s) usedSlot = s end)

    local BACKUP_PFI = PET_FOOD_ITEMS
    PET_FOOD_ITEMS = {
        ["Alterac Swiss"]       = { category = "Cheese", level = 35 },
        ["Forest Mushroom Cap"] = { category = "Fungus", level = 1 },
        ["Cured Ham Steak"]     = { category = "Meat", level = 35 },
        ["Shiny Red Apple"]     = { category = "Fruit", level = 1 },
    }

    local BACKUP_PFD = PET_FAMILY_DIETS
    PET_FAMILY_DIETS = {
        ["Bear"] = { "Meat", "Fish", "Bread", "Fruit", "Fungus", "Cheese" },
    }

    AutoFeedPet()

    PET_FOOD_ITEMS = BACKUP_PFI
    PET_FAMILY_DIETS = BACKUP_PFD

    -- Should pick one of the level-1 items (Forest Mushroom Cap or Shiny Red Apple)
    -- Both are level 1; sort is stable-ish, but either slot 2 or 4 is correct.
    -- We just check that it didn't pick a level-35 item.
    t.Assert(usedSlot == 2 or usedSlot == 4,
        "Expected slot 2 or 4 (level 1 food), got: " .. tostring(usedSlot))
end
