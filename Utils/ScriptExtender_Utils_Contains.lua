-- Example: Check if a value exists in a simple list/table
function ScriptExtender_Utils_Contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
