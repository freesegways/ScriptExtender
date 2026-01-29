-- Combat/AutoCombat2/Cache/PetCache.lua
-- Caches Pet Action Bar slots for quick lookup

if ScriptExtender_PetCache then return end

ScriptExtender_PetCache = {
    actions = {}, -- Map: SpellName -> SlotID (1-10)

    Update = function()
        -- ScriptExtender_Log("PetCache: Updating...")
        ScriptExtender_PetCache.actions = {}

        for i = 1, 10 do
            local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
            if name then
                ScriptExtender_PetCache.actions[name] = i
            end
        end
    end,

    GetSlot = function(spellName)
        return ScriptExtender_PetCache.actions[spellName]
    end,

    IsReady = function(spellName)
        local slot = ScriptExtender_PetCache.actions[spellName]
        if not slot then return false end

        local start, duration, enable = GetPetActionCooldown(slot)
        return (start == 0 or duration <= 1.5)
    end,

    -- Check range for pet actions
    InRange = function(spellName)
        -- 1.12.1 engine does not have IsPetActionInRange.
        -- We return true and let the pet's native AI handle moving into range.
        return true
    end,

    -- Unified Pet Action Dispatcher
    Cast = function(spellName, skipRangeCheck)
        if not UnitExists("pet") or UnitIsDead("pet") then return false end

        -- 1. Standard API Commands
        -- These ALWAYS skip range checks (PetAttack starts the run to target)
        local isCommand = false
        if spellName == "PetAttack" then
            PetAttack()
            isCommand = true
        elseif spellName == "PetFollow" then
            PetFollow()
            isCommand = true
        elseif spellName == "PetStay" then
            PetStay()
            isCommand = true
        elseif spellName == "PetPassive" then
            PetPassiveMode()
            isCommand = true
        elseif spellName == "PetDefensive" then
            PetDefensiveMode()
            isCommand = true
        end

        if isCommand then return true end

        -- 2. Action Bar Spells
        local slot = ScriptExtender_PetCache.actions[spellName]
        if slot then
            -- Check range unless explicitly told to skip
            if not skipRangeCheck then
                if ScriptExtender_PetCache.InRange(spellName) == false then
                    return false -- Out of Range
                end
            end

            CastPetAction(slot)
            return true
        end

        return false
    end,

    Dump = function()
        ScriptExtender_Log("--- Pet Cache ---")
        local count = 0
        local keys = {}
        for k in pairs(ScriptExtender_PetCache.actions) do table.insert(keys, k) end
        table.sort(keys)

        for _, name in ipairs(keys) do
            local slot = ScriptExtender_PetCache.actions[name]
            ScriptExtender_Log(string.format("PetAction: %s -> Slot: %d", name, slot))
            count = count + 1
        end
        ScriptExtender_Log("Total cached pet actions: " .. count)
    end
}

-- Global Wrapper
function PetDump()
    ScriptExtender_PetCache.Dump()
end

if ScriptExtender_Register then
    ScriptExtender_Register({
        name = "PetDump",
        command = "petcache",
        description = "Lists all cached pet actions"
    })
end
