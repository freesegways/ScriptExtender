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
                local texture = GetActionTexture(slot)
                -- We only care about specific spells we use for range checking
                -- This will be populated by the Scanner/Analyzer looking up spells
                -- or we can scan everything. For efficiency, let's scan everything
                -- but store by name so we can look it up easily.

                -- Tooltip scanning is expensive, so we only do this when registered/needed.
                -- For V1, we will rely on the Analyzer to register "Range Spells" it cares about.
                -- Just kidding, we need a way to look up "Hammer of Justice" -> Slot 5.

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
    end
}
