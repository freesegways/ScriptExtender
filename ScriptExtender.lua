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
-- name: The string name of the function (e.g. "HelloWorld")
-- description: A short description of what it does
function ScriptExtender_Register(name, description)
    ScriptExtender_Commands[name] = description
    DEFAULT_CHAT_FRAME:AddMessage("SE: Registered " .. name)
end

-- Slash Command Handler
SLASH_SCRIPTEXTENDER1 = "/se"
SLASH_SCRIPTEXTENDER2 = "/scriptextender"
SlashCmdList["SCRIPTEXTENDER"] = function(msg)
    -- Fixed: string.find returns start, end, capture1, capture2
    -- We need to grab the captures, not the indices.
    local _, _, cmd, rest = string.find(msg, "^%s*(%S+)(.*)")
    
    if not cmd or cmd == "" or cmd == "help" then
        ScriptExtender_Help()
    elseif cmd == "debug" then
        if ScriptExtender_Debug then
            ScriptExtender_Debug = false
            ScriptExtender_Print("Debug checks disabled.")
        else
            ScriptExtender_Debug = true
            ScriptExtender_Print("Debug checks enabled.")
        end
    elseif ScriptExtender_Commands[cmd] then
        local func = getglobal(cmd)
        if func and type(func) == "function" then
            func()
        else
            ScriptExtender_Print("Error: Function " .. cmd .. " is not executable.")
        end
    else
        ScriptExtender_Print("Unknown command: " .. tostring(cmd) .. ". Type /se help for a list.")
    end
end

function ScriptExtender_Help()
    ScriptExtender_Print("Available Commands:")
    
    local sortedCmds = {}
    local count = 0
    for name, desc in pairs(ScriptExtender_Commands) do
        table.insert(sortedCmds, {name=name, desc=desc})
        count = count + 1
    end
    
    if count == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("SE Error: No commands found in registry.")
    end
    
    table.sort(sortedCmds, function(a,b) return a.name < b.name end)
    
    for _, cmd in ipairs(sortedCmds) do
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd700/se " .. cmd.name .. "|r - " .. cmd.desc)
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd700/se debug|r - Toggles debug logging.")
end
