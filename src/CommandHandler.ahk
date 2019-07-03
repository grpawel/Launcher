ResetCommands() {
    global previousInputs := []
    global topLevelExecutable
    global currentExecutable := topLevelExecutable
}

Initialize() {
    ResetCommands()
}

GetTitle() {
    global currentExecutable
    return currentExecutable["title"]
}

RunCommand(input) {
    global currentExecutable
    return currentExecutable.Execute(input)
}