-- Utils/GetTargetPriority.lua
-- Returns a numeric priority for a unit based on its RAID target icon.
-- 4 = Skull (High/Primary)
-- 3 = Cross (Secondary)
-- 2 = Unmarked / Circle / Diamond (Normal)
-- 1 = Others (Low / Moon / Star / Square / Triangle - usually associated with CC)

function ScriptExtender_GetTargetPriority(unit)
    if not UnitExists(unit) then return 0 end

    local mark = GetRaidTargetIndex(unit)

    if mark == 8 then return 4 end -- Skull
    if mark == 7 then return 3 end -- Cross

    -- Normal Priority: Unmarked, Circle(2), Diamond(4)
    if not mark or mark == 2 or mark == 4 then
        return 2
    end

    -- Low Priority / CC: Star(1), Square(3), Moon(5), Triangle(6)
    return 1
end
