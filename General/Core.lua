-- General utility scripts
function General_Test()
    ScriptExtender_Log("General script loaded function call")
end
ScriptExtender_Log("General module loaded")

function HelloWorld()
    ScriptExtender_Print("Hello World from General!")
end
ScriptExtender_Register("HelloWorld", "Prints a hello message to the chat.")




ScriptExtender_Log('General Core Loaded successfully')
