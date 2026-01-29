-- Combat/AutoCombat2/Cache/RangeSlotCache.lua
-- Caches action bar slots for spells used for range checking (0-90 yards)

if ScriptExtender_RangeSlotCache then return end

ScriptExtender_RangeSlotCache = {
    cache = {}, -- Map: SpellName -> SlotID

    -- Function to refresh the cache (Called on SPELLS_CHANGED or initialization)
    Update = function()
        ScriptExtender_Log("RangeSlotCache: Updating...")
        -- Ensure Tooltip Frame exists
        if not ScriptExtender_Tooltip then
            CreateFrame("GameTooltip", "ScriptExtender_Tooltip", nil, "GameTooltipTemplate")
        end

        -- Reset cache
        ScriptExtender_RangeSlotCache.cache = {}

        -- Iterate all 120 action slots
        for slot = 1, 120 do
            if HasAction(slot) then
                ScriptExtender_Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
                ScriptExtender_Tooltip:SetAction(slot)
                local name = ScriptExtender_TooltipTextLeft1:GetText()

                if name then
                    -- Store the *first* slot found for a spell.
                    if not ScriptExtender_RangeSlotCache.cache[name] then
                        ScriptExtender_RangeSlotCache.cache[name] = slot
                    end
                end
            end
        end
        -- ScriptExtender_Log("RangeSlotCache Updated.")
    end,

    -- Helper to get a slot
    GetSlot = function(spellName)
        if not spellName then return nil end
        return ScriptExtender_RangeSlotCache.cache[spellName]
    end,

    -- Check if spell is in range of specific unit
    InRange = function(spellName, unit)
        local slot = ScriptExtender_RangeSlotCache.GetSlot(spellName)
        if not slot then return nil end -- Unknown spell/slot

        -- IsActionInRange usually only checks "target", but we pass unit in case
        -- the client supports it or usage is specific to target-mapped units.
        return IsActionInRange(slot, unit) == 1
    end,

    Dump = function()
        ScriptExtender_Log("--- Range Slot Cache ---")
        local count = 0
        local keys = {}
        for k in pairs(ScriptExtender_RangeSlotCache.cache) do table.insert(keys, k) end
        table.sort(keys)

        -- Ensure tooltip exists
        if not ScriptExtender_Tooltip then
            CreateFrame("GameTooltip", "ScriptExtender_Tooltip", nil, "GameTooltipTemplate")
        end

        for _, name in ipairs(keys) do
            local slot = ScriptExtender_RangeSlotCache.cache[name]

            -- Scan Tooltip for Range
            ScriptExtender_Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
            ScriptExtender_Tooltip:SetAction(slot)

            local rangeText = ""

            -- Scan first 5 lines
            for i = 2, 5 do
                local line = getglobal("ScriptExtender_TooltipTextLeft" .. i)
                if line and line:IsVisible() then
                    local text = line:GetText()
                    if text then
                        -- Matches "30 yd range" or "8 - 25 yd range"
                        if string.find(text, "yd range") then
                            rangeText = text
                            break
                        elseif text == "Melee Range" then
                            rangeText = text
                            break
                        end
                    end
                end
            end

            if rangeText ~= "" then
                ScriptExtender_Log(string.format("%s: %s (Slot %d)", name, rangeText, slot))
            else
                ScriptExtender_Log(string.format("%s: (No Range Info) (Slot %d)", name, slot))
            end
            count = count + 1
        end
        ScriptExtender_Log("Total cached ranges: " .. count)
    end
}

-- Global Wrapper
function RangeDump()
    ScriptExtender_RangeSlotCache.Dump()
end

if ScriptExtender_Register then
    ScriptExtender_Register({
        name = "RangeDump",
        command = "ranges",
        description = "Lists all cached range slots"
    })
end
