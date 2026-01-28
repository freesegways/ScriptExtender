-- ScriptExtender
-- Targeted for Turtle WoW (Vanilla 1.12.1)

-- Configuration
ScriptExtender_Debug = false
ScriptExtender_Commands = {}

-- Global Logging Helper
function ScriptExtender_Log(msg)
    if ScriptExtender_Debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[SE Debug]|r: " .. tostring(msg))
    end
end

-- Global Helper for important user messages (always shows)
function ScriptExtender_Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffScriptExtender|r: " .. tostring(msg))
end

-- Global Error Reporting (Fails Loudly)
function ScriptExtender_Error(msg)
    local formattedMsg = "ScriptExtender: " .. tostring(msg)
    error(formattedMsg, 2)
end

-- Register a function for the Help command
-- Supports:
-- 1. ScriptExtender_Register({ name = "FuncName", command = "alias", description = "..." })
-- 2. ScriptExtender_Register("FuncName", "description", "category")
function ScriptExtender_Register(a1, a2, a3)
    local name, command, description, category
    if type(a1) == "table" then
        name = a1.name
        command = a1.command or a1.name
        description = a1.description
        category = a1.category
    else
        name = a1
        command = a1
        description = a2
        category = a3
    end

    if not name then return end
    local key = string.lower(command)

    if not category then
        category = "Unknown"
        if debug and debug.getinfo then
            local status, info = pcall(debug.getinfo, 2, "S")
            if status and info and info.source then
                local src = string.gsub(info.source, "\\", "/")
                if string.sub(src, 1, 1) == "@" then src = string.sub(src, 2) end
                local _, _, msg = string.find(src, "ScriptExtender/(.*)/[^/]+%.lua$")
                if msg then category = msg end
            end
        end
    end

    ScriptExtender_Commands[key] = { name = name, desc = description, category = category }

    -- Also register the full name as a fallback command if it differs from the alias
    local nameKey = string.lower(name)
    if nameKey ~= key then
        ScriptExtender_Commands[nameKey] = { name = name, desc = description, category = category, isAlias = true }
    end

    ScriptExtender_Log("Registered: " .. key .. " -> " .. name .. " [" .. category .. "]")
end

-- Slash Command Handler
SLASH_SCRIPTEXTENDER1 = "/se"
SLASH_SCRIPTEXTENDER2 = "/scriptextender"
SlashCmdList["SCRIPTEXTENDER"] = function(msg)
    local _, _, cmd, rest = string.find(msg, "^%s*(%S+)(.*)")
    ScriptExtender_Log("DEBUG: Received command: " .. tostring(cmd))

    if not cmd or cmd == "" or string.lower(cmd) == "help" then
        ScriptExtender_Help()
        return
    end

    local commandKey = string.lower(cmd)

    if commandKey == "debug" then
        ScriptExtender_Debug = not ScriptExtender_Debug
        ScriptExtender_Print("Debug checks " .. (ScriptExtender_Debug and "enabled." or "disabled."))
    elseif commandKey == "registry" or commandKey == "list" then
        ScriptExtender_Print("Currently Registered Commands:")
        for k, v in pairs(ScriptExtender_Commands) do
            DEFAULT_CHAT_FRAME:AddMessage(" - " .. k .. " -> " .. v.name)
        end
    elseif ScriptExtender_Commands[commandKey] then
        local cmdData = ScriptExtender_Commands[commandKey]
        local func = getglobal(cmdData.name)

        if type(func) == "function" then
            ScriptExtender_Log("DEBUG: Calling function " .. cmdData.name)
            local status, err = pcall(func, rest)
            if not status then
                ScriptExtender_Print("ERROR calling " .. cmdData.name .. ": " .. tostring(err))
            else
                ScriptExtender_Log("DEBUG: Function return successfully")
            end
        else
            ScriptExtender_Print("Error: Function " .. tostring(cmdData.name) .. " not found.")
        end
    else
        ScriptExtender_Print("Unknown command: " .. tostring(cmd) .. ". Type /se help for a list.")
    end
end

function ScriptExtender_Help()
    ScriptExtender_Print("Available Commands:")

    local keys = {}
    for k in pairs(ScriptExtender_Commands) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for i = 1, table.getn(keys) do
        local k = keys[i]
        local cmd = ScriptExtender_Commands[k]
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700/se " .. cmd.name .. "|r - " .. cmd.desc)
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd700/se debug|r - Toggles debug logging.")
end

----------------------------------------------------------
-- Channel Tracking (Polyfill for UnitChannelInfo in 1.12)
----------------------------------------------------------
local SE_ChannelFrame = CreateFrame("Frame")
ScriptExtender_ChannelInfo = { name = nil, endTime = 0 }

SE_ChannelFrame:RegisterEvent("SPELLCAST_CHANNEL_START")
SE_ChannelFrame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
SE_ChannelFrame:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")

SE_ChannelFrame:SetScript("OnEvent", function()
    -- Capture globals for linter and safety in 1.12
    local event = event
    local arg1 = arg1

    if event == "SPELLCAST_CHANNEL_START" then
        -- arg1 is duration in ms
        ScriptExtender_ChannelInfo.endTime = GetTime() + (arg1 / 1000)

        -- Infer name from last cast action if recent
        if ScriptExtender_LastCastAction and ScriptExtender_LastCastTime and (GetTime() - ScriptExtender_LastCastTime) < 2.0 then
            ScriptExtender_ChannelInfo.name = ScriptExtender_LastCastAction
        else
            ScriptExtender_ChannelInfo.name = "Channeling"
        end
        ScriptExtender_Log("Channel Started: " .. tostring(ScriptExtender_ChannelInfo.name))
    elseif event == "SPELLCAST_CHANNEL_STOP" then
        ScriptExtender_ChannelInfo.name = nil
        ScriptExtender_ChannelInfo.endTime = 0
    elseif event == "SPELLCAST_CHANNEL_UPDATE" then
        if arg1 == 0 then
            ScriptExtender_ChannelInfo.name = nil
            ScriptExtender_ChannelInfo.endTime = 0
        else
            ScriptExtender_ChannelInfo.endTime = GetTime() + (arg1 / 1000)
        end
    end
end)

if not UnitChannelInfo then
    function UnitChannelInfo(unit)
        if unit == "player" and ScriptExtender_ChannelInfo.endTime and ScriptExtender_ChannelInfo.endTime > GetTime() then
            return ScriptExtender_ChannelInfo.name, nil, nil, nil, ScriptExtender_ChannelInfo.endTime, nil
        end
        return nil
    end
end
