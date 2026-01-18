# Development Rules for ScriptExtender

## Target Environment
- **Game**: Turtle WoW (World of Warcraft)
- **Game Version**: 1.12.1 (Vanilla)
- **Interface**: 11200

## API & Coding Guidelines
1. **Lua Version**: Lua 5.0 (approx).
    - No `local function foo()` syntax (sugar). Use `local foo = function()` or `local function foo` if strictly supporting 5.1 features that got backported, but vanilla is 5.0. Actually 1.12 is Lua 5.1 but missing many libs. Safest to write compatible code.
    - *Correction*: WoW 1.x used Lua 5.0. WoW 2.x switched to 5.1.
    - **Important**: `for k,v in pairs(t) do` works. `for i=1, #t do` (using `#` operator) DOES NOT WORK in Lua 5.0. Use `table.getn(t)`.
    - No `%` modulus operator in 5.0? It exists.
    - `loadstring` vs `load`.

2. **WoW API (1.12)**
    - No `print("...")`. Use `DEFAULT_CHAT_FRAME:AddMessage("...")`.
    - Events: In `SetScript("OnEvent", func)`, parameters are NOT passed to `func`. You must access global `event`, `arg1`, `arg2`, `this`.
    - No Secure execution system. `CastSpellByName` works freely.
    - No `C_Timer` or similar modern namespaces.

3. **Turtle WoW Specifics**
    - May have custom API extensions. Check Turtle WoW forums/wiki if needed.
