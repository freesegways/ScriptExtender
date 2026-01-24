function SE_OnLoad()
    tinsert(UISpecialFrames, "ScriptExtenderFrame");
    this:RegisterForDrag("LeftButton");
    this:SetMovable(1);
    this:SetScript("OnDragStart", function() this:StartMoving() end);
    this:SetScript("OnDragStop", function() this:StopMovingOrSizing() end);

    -- Register slash command to open UI
    SLASH_SEUI1 = "/seui"
    SlashCmdList["SEUI"] = function()
        if ScriptExtenderFrame:IsVisible() then
            ScriptExtenderFrame:Hide()
        else
            ScriptExtenderFrame:Show()
        end
    end

    ScriptExtender_Print("UI Loaded. Type /seui to open.")
end

function SE_ToggleDebug(checked)
    ScriptExtender_Debug = checked
    ScriptExtender_Print("Debug logging " .. (checked and "enabled" or "disabled"))
end

local headerPool = {}
local entryPool = {}

function SE_OnShow()
    -- Sync Debug Checkbox
    if ScriptExtender_Debug then
        SE_DebugCheck:SetChecked(1)
    else
        SE_DebugCheck:SetChecked(nil)
    end

    -- Clear List
    for _, f in pairs(headerPool) do f:Hide() end
    for _, f in pairs(entryPool) do f:Hide() end

    local child = SE_ScrollChild
    local yOffset = -5

    -- Sort Categories
    local categories = {}
    for k, v in pairs(ScriptExtender_Commands) do
        local cat = v.category or "Uncategorized"
        if not categories[cat] then categories[cat] = {} end
        table.insert(categories[cat], v)
    end

    local sortedCats = {}
    for k in pairs(categories) do table.insert(sortedCats, k) end
    table.sort(sortedCats)

    local hIdx = 1
    local eIdx = 1

    for _, cat in ipairs(sortedCats) do
        -- Header
        local h = headerPool[hIdx]
        if not h then
            h = CreateFrame("Frame", "SE_Header_" .. hIdx, child, "SE_CategoryHeaderTemplate")
            headerPool[hIdx] = h
        end
        h:SetPoint("TOPLEFT", child, "TOPLEFT", 5, yOffset)
        getglobal(h:GetName() .. "Text"):SetText(cat)
        h:Show()
        yOffset = yOffset - 25
        hIdx = hIdx + 1

        -- Entries
        local cmds = categories[cat]
        -- sort cmds by name
        table.sort(cmds, function(a, b) return a.name < b.name end)

        for _, cmd in ipairs(cmds) do
            local e = entryPool[eIdx]
            if not e then
                e = CreateFrame("Frame", "SE_Entry_" .. eIdx, child, "SE_MacroEntryTemplate")
                entryPool[eIdx] = e
            end
            e:SetPoint("TOPLEFT", child, "TOPLEFT", 10, yOffset)
            getglobal(e:GetName() .. "Name"):SetText(cmd.name)
            getglobal(e:GetName() .. "Desc"):SetText(cmd.desc)
            e.commandName = cmd.name
            e:Show()
            yOffset = yOffset - 45
            eIdx = eIdx + 1
        end

        yOffset = yOffset - 5 -- Padding between categories
    end

    child:SetHeight(math.abs(yOffset) + 20)
end

function SE_MacroEntry_Run(frame)
    local cmdName = frame.commandName
    if cmdName then
        ScriptExtender_Print("Executing UI command: " .. cmdName)
        local func = getglobal(cmdName)
        if type(func) == "function" then
            local status, err = pcall(func)
            if not status then
                ScriptExtender_Print("Error: " .. tostring(err))
            end
        else
            ScriptExtender_Print("Command not found.")
        end
    end
end

-- Minimap Button Logic
function SE_MinimapButton_OnLoad()
    this:SetFrameLevel(Minimap:GetFrameLevel() + 1)
    this:RegisterForDrag("RightButton")
    this:SetScript("OnDragStart", function() this.isDragging = true end)
    this:SetScript("OnDragStop", function() this.isDragging = false end)
    this:SetScript("OnUpdate", SE_MinimapButton_OnUpdate)
    this:SetScript("OnClick", SE_MinimapButton_OnClick)
    this:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText("Script Extender UI\nLeft-Click to Toggle UI\nRight-Click to Drag")
        GameTooltip:Show()
    end)
    this:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function SE_MinimapButton_OnClick()
    if ScriptExtenderFrame:IsVisible() then
        ScriptExtenderFrame:Hide()
    else
        ScriptExtenderFrame:Show()
    end
end

function SE_MinimapButton_OnUpdate()
    if this.isDragging then
        local xpos, ypos = GetCursorPosition()
        local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
        xpos = xmin - xpos / UIParent:GetScale() + 70
        ypos = ypos / UIParent:GetScale() - ymin - 70
        local angle = math.deg(math.atan2(ypos, xpos))
        local radius = 80

        local newX = math.cos(math.rad(angle)) * radius -- 52 is half width of minimap? No, usually 80 radius
        local newY = math.sin(math.rad(angle)) * radius

        -- Adjust for TopRight corner usually
        this:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52 - (math.cos(math.rad(angle)) * 80),
            (52 - (math.sin(math.rad(angle)) * 80)) * -1)
    end
end
