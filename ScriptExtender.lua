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

-- Register a function for the Help command
function ScriptExtender_Register(name, description)
    local key = string.lower(name)
    ScriptExtender_Commands[key] = { name = name, desc = description }
    -- We'll log to debug instead of chat to avoid cluttering at login
    ScriptExtender_Log("Registered: " .. name)
end

-- Slash Command Handler
SLASH_SCRIPTEXTENDER1 = "/se"
SLASH_SCRIPTEXTENDER2 = "/scriptextender"
SlashCmdList["SCRIPTEXTENDER"] = function(msg)
    local _, _, cmd, rest = string.find(msg, "^%s*(%S+)(.*)")

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
            func(rest)
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
