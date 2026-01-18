-- UseBestBandage Script
-- Simple script to use the best bandage on self.

ScriptExtender_Register("UseBestBandage", "Scans bags for the best available bandage and uses it on self.")
function UseBestBandage()
    if not ScriptExtender_Bandages then
        ScriptExtender_Print("Error: Bandage database not loaded.")
        return
    end

    for _, bandage in ipairs(ScriptExtender_Bandages) do
        local name = bandage.name
        for b = 0, 4 do
            for s = 1, GetContainerNumSlots(b) do
                local link = GetContainerItemLink(b, s)
                if link and string.find(link, name) then
                    ScriptExtender_Log("Using Bandage: " .. name)
                    UseContainerItem(b, s)
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
