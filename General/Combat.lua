-- Combat Stats and Tools

ScriptExtender_Register("ReportAggro", "Scans nearby mobs and reports who they are attacking.")
function ReportAggro()
    local total, dist = GetMobDistribution()
    
    ScriptExtender_Print("--- COMBAT REPORT ("..total.." Mobs) ---")
    
    local safe = true
    for id, count in pairs(dist) do
        if count > 0 then
            safe = false
            local name = UnitName(id) or "Unknown"
            ScriptExtender_Print(" > " .. name .. " is tanking " .. count)
        end
    end
    
    if safe then
        ScriptExtender_Print(" > No aggro detected.")
    end
end
