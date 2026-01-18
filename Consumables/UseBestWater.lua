-- UseBestWater Script
-- Depends on: Utils/Core.lua (ScriptExtender_GetSortedFoodItems), Constants/FoodAndWater.lua

ScriptExtender_Register("UseBestWater", "Finds the best available water and drinks it.")
function UseBestWater()
    if UnitAffectingCombat("player") then
        ScriptExtender_Print("Error: You are in combat and cannot drink!")
        return
    end

    -- 1. Check if already drinking
    for i = 1, 16 do
        local b = UnitBuff("player", i)
        if not b then break end
        if string.find(b, "Drink") or string.find(b, "Bottle") then
            return -- Already drinking
        end
    end

    -- 2. Check if mana is full
    if UnitMana("player") >= UnitManaMax("player") then
        return
    end

    -- Get sorted list of Drink ("Drink", Buff=any, Conjured=any)
    local drinks = ScriptExtender_GetSortedFoodItems("Drink", nil, nil)

    local foundBag, foundSlot, foundLink = nil, nil, nil
    local bestDrinkName = ""

    -- Check Sorted Drinks
    for _, name in ipairs(drinks) do
        for b = 0, 4 do
            for s = 1, GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b, s)
                if link and string.find(link, name) then
                    foundBag = b
                    foundSlot = s
                    foundLink = link
                    bestDrinkName = name
                    break
                end
            end
            if foundBag then break end
        end
        if foundBag then break end
    end

    -- If no water found
    if not foundBag then
        ScriptExtender_Print("Error: No water found in your bags.")
        return
    end

    UseContainerItem(foundBag, foundSlot)

    -- Count Remaining
    local totalCount = 0
    for b = 0, 4 do
        for s = 1, GetContainerNumSlots(b) do
            local link = GetContainerItemLink(b, s)
            if link and string.find(link, bestDrinkName) then
                local _, count = GetContainerItemInfo(b, s)
                totalCount = totalCount + count
            end
        end
    end

    local remaining = totalCount - 1
    if remaining < 0 then remaining = 0 end
    ScriptExtender_Log("Drank: " .. bestDrinkName .. ". Total Left: " .. remaining)
end
