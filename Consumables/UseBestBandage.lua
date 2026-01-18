-- UseBestBandage Script
-- Simple script to use the best bandage on self.

ScriptExtender_Register("UseBestBandage", "Scans bags for the best available bandage and uses it on self.")
function UseBestBandage()
    -- Kept local as Bandages are not yet in the DB
    -- Ideally this should move to Constants if it grows
    local bandages = {
        "Heavy Runecloth Bandage", "Runecloth Bandage", 
        "Heavy Mageweave Bandage", "Mageweave Bandage", 
        "Heavy Silk Bandage", "Silk Bandage", 
        "Heavy Wool Bandage", "Wool Bandage", 
        "Heavy Linen Bandage", "Linen Bandage" 
    }

    for _, name in ipairs(bandages) do
        for b=0,4 do
            for s=1,GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b,s)
                if link and string.find(link, name) then
                    ScriptExtender_Log("Using Bandage: " .. name)
                    UseContainerItem(b,s)
                    if SpellIsTargeting() then
                        SpellTargetUnit("player")
                    end
                    return
                end
            end
        end
    end
    ScriptExtender_Log("No bandages found!")
end
