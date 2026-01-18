# ScriptExtender Coding Standards

## 1. File Organization

**Rule: One Main Function Per File.**

- **Do not** create `Core.lua` files that contain multiple unrelated functions.
- **Do not** create large "Utils" files.
- **Naming:** The filename MUST match the main function name exactly.
  - Example: `UseSmartMana.lua` contains the `UseSmartMana` function.
  - Test Example: `UseSmartMana.test.lua` contains tests for `UseSmartMana`.

## 2. Directory Structure

- `Classes/<Class>/`: Class-specific logic (e.g. `Classes/Warlock/DeleteExcessShards.lua`).
- `Combat/`: Aggro, Equipment, Survival logic.
- `Consumables/`: Food, Water, Potions.
- `Healing/`: Healing logic.
- `Utils/`: Generic helpers (e.g. `Utils/GetTankInfo.lua`).
- `Tests/`: Framework and runners.
- `Constants/`: Data tables.

## 3. Testing

- Every public function MUST have a corresponding `.test.lua` file colocated or in logical structure.
- Test keys MUST be prefixed with the function name: `ScriptExtender_Tests["FunctionName_Description"]`.
- Run tests with `./RunTests.bat` before committing.

## 4. Execution

- Avoid `require` or `dofile`. Files are loaded via `ScriptExtender.toc` order.
- Ensure new files are added to the TOC immediately.
