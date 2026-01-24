-- Warlock Specific Scripts

ScriptExtender_Register("DeleteExcessShards", "Deletes excess Soul Shards, keeping the specified limit (default 10).")
function DeleteExcessShards(limit)
    limit = tonumber(limit)
    if not limit then limit = 10 end -- Default to keeping 10
    local count = 0
    local deleted = 0

    -- MODIFIED: Iterate Forwards (Bag 0 -> Bag 4)
    -- This prioritizes keeping shards in your Backpack (Bag 0)
    -- and deletes the excess found in your Soul Bag (Bag 4)
    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        for slot = 1, slots do
            local link = GetContainerItemLink(bag, slot)

            -- Check if item exists and is a Soul Shard
            if link and string.find(link, "Soul Shard") then
                count = count + 1

                -- If we found more than our limit, DELETE IT
                if count > limit then
                    PickupContainerItem(bag, slot)
                    DeleteCursorItem()
                    deleted = deleted + 1
                end
            end
        end
    end

    if deleted > 0 then
        ScriptExtender_Log("Soul Shards: Deleted " .. deleted .. " excess shards (Kept " .. limit .. ").")
    else
        ScriptExtender_Log("Soul Shards: Count is within limit (" .. count .. "/" .. limit .. ").")
    end
end
