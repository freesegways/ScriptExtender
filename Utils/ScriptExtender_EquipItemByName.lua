-- Helper to find and equip an item by name
function ScriptExtender_EquipItemByName(itemName)
    if not itemName then return false end
    
    for b=0,4 do 
        for s=1,GetContainerNumSlots(b) do
            local link = GetContainerItemLink(b,s) 
            if link and string.find(link, itemName) then 
                UseContainerItem(b,s)
                return true -- Item found and used
            end 
        end 
    end
    return false
end
