-- SwapWeapons Script
-- Depends on: Utils/Core.lua (ScriptExtender_EquipItemByName)

ScriptExtender_Register("SwapWeapons", "Toggles between two weapons while ensuring a shield is equipped. Usage: SwapWeapons('Weapon1', 'Weapon2', 'Shield')")
function SwapWeapons(weapon1, weapon2, shield)
    if not weapon1 or not weapon2 then
        ScriptExtender_Print("Error: SwapWeapons requires at least two weapon names.")
        return
    end

    -- Get Main Hand Item Link (Slot 16)
    local mhLink = GetInventoryItemLink("player", 16)
    
    -- Check if we are wearing Weapon 1
    if mhLink and string.find(mhLink, weapon1) then
        -- Wear Weapon 2
        ScriptExtender_EquipItemByName(weapon2)
    else
        -- Otherwise (Wearing Weapon 2, or neither) -> Wear Weapon 1
        ScriptExtender_EquipItemByName(weapon1)
    end

    -- Always ensure shield is equipped
    if shield then
        local ohLink = GetInventoryItemLink("player", 17)
        -- Only try to equip shield if it's not already equipped
        if not ohLink or not string.find(ohLink, shield) then
             ScriptExtender_EquipItemByName(shield)
        end
    end
end
