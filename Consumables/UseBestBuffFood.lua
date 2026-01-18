-- UseBestBuffFood Script
-- Depends on: Utils/Core.lua (ScriptExtender_GetSortedFoodItems), Constants/FoodAndWater.lua

ScriptExtender_Register("UseBestBuffFood", "Scans bags for the best available Stats Food (Well Fed) and eats it.")
function UseBestBuffFood()
    -- Get sorted list of Buff Foods ("Food", Buff=true)
    local foods = ScriptExtender_GetSortedFoodItems("Food", true, nil)

    for _, name in ipairs(foods) do
        for b=0,4 do
            for s=1,GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b,s)
                if link and string.find(link, name) then
                    -- Find item helper
                    local level = 0
                    for _, item in ipairs(TURTLE_FOOD_DB) do
                         if item.name == name then level = item.level_req break end
                    end

                    ScriptExtender_Log("Eating (Buff): " .. name .. " (Lvl " .. level .. ")")
                    UseContainerItem(b,s)
                    return
                end
            end
        end
    end
    ScriptExtender_Log("No stat buff food found!")
end
