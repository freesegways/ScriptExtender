-- Standalone Test Runner for ScriptExtender
-- This script mocks the WoW 1.12 API and loads the addon files to run unit tests from the command line.
-- Usage: lua Tests/StandaloneRunner.lua

-- =========================================================
-- 1. WOW API MOCKS
-- =========================================================
_G = _G or {}
function getglobal(n) return _G[n] end

function setglobal(n, v) _G[n] = v end

-- Command Registry
SlashCmdList = {}
function UnitIsFriend(u1, u2) return true end

function UnitIsUnit(u1, u2) return u1 == u2 end

-- Table Polyfills
table.getn = function(t)
    if not t then return 0 end
    return #t
end

-- String Polyfills
string.gfind = string.gmatch

-- UI Globals
DEFAULT_CHAT_FRAME = { AddMessage = function(self, msg) print(msg) end }
UIErrorsFrame = { AddMessage = function(self, msg) print("[UI-ERR] " .. msg) end }

-- Function Mocks (Stubs to prevent load errors)
function ScriptExtender_Register(name, help)
    -- print("Registered: " .. name)
end

function ScriptExtender_Log(msg)
    -- print("[LOG] " .. msg)
end

function ScriptExtender_Print(msg)
    -- Strip WoW Color Codes
    msg = string.gsub(msg, "|c%x%x%x%x%x%x%x%x", "")
    msg = string.gsub(msg, "|r", "")
    print("[MSG] " .. msg)
end

function UnitName(u) return "Name_" .. tostring(u) end

function UnitHealth(u) return 100 end

function UnitLevel(u) return 60 end

function UnitHealthMax(u) return 100 end

function UnitClass(u) return "WARRIOR", "WARRIOR" end

function UnitExists(u) return true end

function UnitIsConnected(u) return true end

function UnitCreatureType(u) return "Humanoid" end

function UnitIsDeadOrGhost(u) return false end

function UnitCanAssist(u) return true end

function UnitBuff(u, i) return nil end

function UnitDebuff(u, i) return nil end

function GetTime() return os.time() end

function CheckInteractDistance(u, dist) return true end

function UnitIsVisible(u) return true end

function TargetUnit(u) end

function ClearTarget() end

function TargetLastTarget() end

function CastSpellByName(n) end

function SpellStopCasting() end

function SpellIsTargeting() return false end

function GetContainerNumSlots(b) return 0 end

function GetContainerItemLink(b, s) return nil end

function GetContainerItemInfo(b, s) return nil, 1 end

function GetContainerItemCooldown(b, s) return 0, 0, 1 end

function UseContainerItem(b, s) end

function GetInventoryItemLink(u, s) return nil end

function GetSpellName(i, book) return nil end

function GetSpellCooldown(i, book) return 0, 0 end

function PickupContainerItem(b, s) end

function DeleteCursorItem() end

function UnitPowerType(u) return 0 end

function UnitMana(u) return 100 end

function UnitManaMax(u) return 100 end

function UnitAffectingCombat(u) return false end

function IsActionInRange(s) return 1 end

function GetNumPartyMembers() return 0 end

function GetNumRaidMembers() return 0 end

function UnitClassification(u) return "normal" end

-- Constants
BOOKTYPE_SPELL = "spell"

function CreateFrame(type, name, parent, template)
    -- Return a mock table representing the frame
    local frame = {}
    frame.SetOwner = function() end
    frame.ClearLines = function() end
    frame.SetPlayerBuff = function() end
    return frame
end

-- =========================================================
-- 2. FILE LOADER (TOC Parser)
-- =========================================================
print("Loading ScriptExtender files...")

-- We assume we are running from the Addon Root directory
local tocFile = "ScriptExtender.toc"
local fh = io.open(tocFile, "r")

if not fh then
    print("Error: Could not find " .. tocFile)
    print("Please run this script from the Addon root directory: lua Tests/StandaloneRunner.lua")
    os.exit(1)
end

for line in fh:lines() do
    -- Strip comments
    line = line:gsub("#.*", "")
    -- Trim whitespace
    line = line:gsub("^%s*(.-)%s*$", "%1")

    if line ~= "" then
        -- Handle Windows Paths
        local path = line:gsub("\\", "/")

        -- Try to load
        local chunk, err = loadfile(path)
        if chunk then
            chunk()
        else
            print("Error loading " .. path .. ": " .. err)
            os.exit(1)
        end
    end
end

fh:close()
print("All files loaded.")

-- =========================================================
-- 3. RUN TESTS
-- =========================================================
print("\n=== STARTING TESTS ===")

if RunTests then
    local failed = false
    local original_Print = ScriptExtender_Print

    ScriptExtender_Print = function(msg)
        original_Print(msg)
        if string.find(msg, "%[FAIL%]") or string.find(msg, "%[ERR%]") then
            failed = true
        end
    end

    RunTests()

    if failed then
        print("\nTESTS FAILED!")
        os.exit(1)
    else
        print("\nTESTS PASSED!")
        os.exit(0)
    end
else
    print("Error: RunTests function not found.")
    os.exit(1)
end
