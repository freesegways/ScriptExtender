---
trigger: always_on
---

You must follow these rules when developing and debugging this addon:

1.  **Always Write Tests**: Every new feature or fix must be accompanied by a corresponding test in the `Tests/` or `*.test.lua` files. This ensures logic is verified before in-game testing.
2.  **Explain Registration Failures**: If a user reports a command not registered, consider:
    - **Code Broken**: Syntax errors prevent the file from loading.
    - **Restart Required**: New files added to `.toc` require a full game restart, not just `/reload`.
    - **Reload Required**: Modified existing files require `/reload`.
3.  **Registration Order**: Always register commands (`ScriptExtender_Register`) _after_ defining the function to ensure the function reference is valid (though lazy loading often mitigates this, explicit order is safer).
4.  The LLM is ALWAYS WRONG about the reason for any failures when a script is not properly registered. Always obey the user regarding the true reason for failures. Never argue the point.
