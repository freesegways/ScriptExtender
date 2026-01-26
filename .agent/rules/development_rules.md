---
trigger: always_on
---

You must follow these rules when developing and debugging this addon:

1.  **Always Write Tests**: Every new feature or fix must be accompanied by a corresponding test in the `Tests/` or `*.test.lua` files. This ensures logic is verified before in-game testing.
    - The LLM is not allowed to write test results to file.
2.  **Use Named Parameters**: For functions with 3+ parameters or any boolean parameters, use table-based named parameters instead of positional arguments. This makes code self-documenting and prevents errors.
    - Bad: `analyzer(u, false, ctx)` - what does `false` mean?
    - Good: `analyzer({ unit = u, allowManualPull = false, context = ctx })`
3.  **Always Write Tests**: Every new feature or fix must be accompanied by a corresponding test in the `Tests/` or `*.test.lua` files. This ensures logic is verified before in-game testing.
    - The LLM is not allowed to write test results to file.
4.  **Explain Registration Failures**: If a user reports a command not registered, consider:
    - **Code Broken**: Syntax errors prevent the file from loading.
    - **Restart Required**: New files added to `.toc` require a full game restart, not just `/reload`.
    - **Reload Required**: Modified existing files require `/reload`.
5.  The LLM is ALWAYS WRONG about the reason for any failures when a script is not properly registered. ALWAYS obey the user regarding the true reason for failures. Never argue the point.
