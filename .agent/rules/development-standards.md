---
description: Project development standards and coding rules for ScriptExtender (Turtle WoW 1.12)
---

# Development Standards & Rules

## 1. Environment & API (Turtle WoW 1.12.1)

- **Lua 5.0**:
  - Use `table.getn(t)` instead of `#t`.
  - Avoid Lua 5.1+ features.
- **WoW API (Vanilla 1.12)**:
  - Use `DEFAULT_CHAT_FRAME:AddMessage("...")` instead of `print()`.
  - Event handlers receive args via globals (`event`, `arg1`, `this`), not function parameters.
  - `CastSpellByName` is secure and unrestricted.
  - No `C_Timer` or modern namespaces.

## 2. File Organization

- **One Function Per File**: The filename MUST match the main function name exactly.
  - Example: `UseSmartMana.lua` contains `UseSmartMana`.
- **No Monolithic Files**: Do not create `Core.lua` or large generic `Utils.lua` files. Split logic into specific, named files.
- **Directory Structure**:
  - `Classes/<Class>/`: Class-specific logic (e.g. `Classes/Warlock/DeleteExcessShards.lua`).
  - `Combat/`: Aggro, Equipment, Survival logic.
  - `Consumables/`: Food, Water, Potions.
  - `Healing/`: Healing logic.
  - `Utils/`: Specific, focused helper functions (e.g. `Utils/GetTankInfo.lua`).
  - `Constants/`: Data tables.
  - `Tests/`: Framework and runners.

## 3. Testing

- **Mandatory Usage**: Every public function MUST have a corresponding `.test.lua` file.
- **Naming Convention**: Test keys must differ: `ScriptExtender_Tests["FunctionName_Scenario"]`.
- **Execution**: Run `./RunTests.bat` (or `RunTests.bat` in terminal) before committing any changes.

## 4. Execution & Loading

- **TOC Driven**: Do NOT use `require` or `dofile`. All files must be loaded via `ScriptExtender.toc`.
- **Update TOC**: Ensure every new file is added to `ScriptExtender.toc` immediately.
