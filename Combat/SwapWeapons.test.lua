-- Tests for SwapWeapons

ScriptExtender_Tests["SwapWeapons_Toggle"] = function(t)
    -- SCENARIO: Equipped: Sword (16), Shield (17). 
    -- Request: Swap to Axe (Weapon2).
    local equippedItem = nil
    
    t.Mock("GetInventoryItemLink", function(u, s) 
        if s == 16 then return "item:123:Sword" end
        return "item:456:Shield"
    end)
    
    -- Mock Equip Helper (which calls UseContainerItem)
    -- But EquipItemByName scans bags. Mock strict bag content.
    t.Mock("GetContainerNumSlots", function(b) return 5 end)
    t.Mock("GetContainerItemLink", function(b, s)
        if b==0 and s==1 then return "item:999:Axe" end
        return nil
    end)
    t.Mock("UseContainerItem", function(b, s) 
        if s==1 then equippedItem = "Axe" end
    end)
    
    SwapWeapons("Sword", "Axe", "Shield")
    
    t.AssertEqual(equippedItem, "Axe", "Should swap to Axe when holding Sword.")
end

ScriptExtender_Tests["SwapWeapons_EnsureShield"] = function(t)
    -- SCENARIO: Equipped: Sword (16), NONE (17).
    -- Request: Swap to Sword (no change) but Shield is missing.
    local equippedShield = false
    
    t.Mock("GetInventoryItemLink", function(u, s) 
        if s == 16 then return "item:123:Sword" end
        return nil -- No Shield
    end)
    
    t.Mock("GetContainerNumSlots", function(b) return 5 end)
    t.Mock("GetContainerItemLink", function(b, s)
        if b==0 and s==1 then return "item:456:Shield" end
        return nil
    end)
    t.Mock("UseContainerItem", function(b, s) 
        if s==1 then equippedShield = true end
    end)
    
    SwapWeapons("Sword", "Axe", "Shield")
    
    t.Assert(equippedShield, "Should equip Shield if missing.")
end
