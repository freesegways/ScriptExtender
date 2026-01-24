function ScriptExtender_IsTargetMatch(b, u)
    if not UnitExists(u) then return false end
    if UnitName(u) ~= b.targetName then return false end

    -- Enhanced Checks (Level + MaxHP)
    -- Only check if we have data for them (strict mode)
    if b.strict then
        if b.targetLevel and UnitLevel(u) ~= b.targetLevel then return false end
        if b.targetMaxHP and UnitHealthMax(u) ~= b.targetMaxHP then return false end
    end

    return true
end
