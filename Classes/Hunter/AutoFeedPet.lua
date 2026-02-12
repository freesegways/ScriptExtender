-- Classes/Hunter/AutoFeedPet.lua
-- Automatically feeds your Hunter pet with appropriate food from your bags.
-- Checks pet happiness, pet family diet, and scans bags for matching food.
-- Depends on: Constants/PetFood.lua

function AutoFeedPet()
    -- 1. Must have a pet
    if not UnitExists("pet") then
        ScriptExtender_Print("You don't have a pet out.")
        return
    end

    -- 2. Must not be dead
    if UnitIsDead("pet") then
        ScriptExtender_Print("Your pet is dead!")
        return
    end

    -- 3. Must not be in combat
    if UnitAffectingCombat("player") then
        ScriptExtender_Print("Cannot feed pet during combat!")
        return
    end

    -- 4. Check happiness (1=Unhappy, 2=Content, 3=Happy)
    local happiness = GetPetHappiness()
    if happiness and happiness == 3 then
        ScriptExtender_Print("Your pet is already happy!")
        return
    end

    -- 5. Get pet family and look up diet
    local family = UnitCreatureFamily("pet")
    if not family then
        ScriptExtender_Print("Could not determine pet family.")
        return
    end

    local diet = PET_FAMILY_DIETS[family]
    if not diet then
        ScriptExtender_Print("Unknown pet family: " .. tostring(family) .. ". Cannot determine diet.")
        return
    end

    -- Build a quick lookup set: { Meat = true, Fish = true, ... }
    local allowedCategories = {}
    for _, cat in ipairs(diet) do
        allowedCategories[cat] = true
    end

    -- 6. Scan bags for food the pet can eat
    local candidates = {} -- { name, category, level, bag, slot }

    for b = 0, 4 do
        for s = 1, GetContainerNumSlots(b) do
            local link = GetContainerItemLink(b, s)
            if link then
                -- Check against PET_FOOD_ITEMS database
                for itemName, info in pairs(PET_FOOD_ITEMS) do
                    if string.find(link, "%[" .. itemName .. "%]") then
                        -- This bag item is a known pet food — is it in the pet's diet?
                        if allowedCategories[info.category] then
                            table.insert(candidates, {
                                name = itemName,
                                category = info.category,
                                level = info.level,
                                bag = b,
                                slot = s,
                            })
                        end
                        break -- found the item in the DB, stop searching
                    end
                end
            end
        end
    end

    -- Also check TURTLE_FOOD_DB (player food) — some cooked foods are also pet food
    -- Items in TURTLE_FOOD_DB that also have an entry in PET_FOOD_ITEMS are already covered.
    -- No extra scanning needed since PET_FOOD_ITEMS includes cooked food.

    if table.getn(candidates) == 0 then
        ScriptExtender_Print("No suitable food for your " .. family .. " (eats: " .. table.concat(diet, ", ") .. ").")
        return
    end

    -- 7. Pick the LOWEST level food (don't waste expensive food on the pet)
    table.sort(candidates, function(a, b) return a.level < b.level end)
    local pick = candidates[1]

    ScriptExtender_Log("Feeding pet: " .. pick.name .. " [" .. pick.category .. ", Lvl " .. pick.level .. "]")

    -- 8. Cast Feed Pet, then pick up the food item to feed it
    -- PickupContainerItem simulates clicking the bag slot, which completes
    -- the Feed Pet targeting cursor. UseContainerItem would try to eat it.
    CastSpellByName("Feed Pet")
    PickupContainerItem(pick.bag, pick.slot)

    local happinessLabels = { "Unhappy", "Content", "Happy" }
    local label = "Unknown"
    if happiness and happinessLabels[happiness] then
        label = happinessLabels[happiness]
    end

    ScriptExtender_Print("Fed " ..
        pick.name .. " (" .. pick.category .. ") to your " .. family .. ". Happiness: " .. label)
end

ScriptExtender_Register({
    name = "AutoFeedPet",
    command = "feedpet",
    description = "Feeds your Hunter pet with the cheapest suitable food from your bags.",
})
