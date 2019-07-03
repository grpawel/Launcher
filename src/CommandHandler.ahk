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
    global previousInputs
    title := currentExecutable["title"]
    titleFactory := currentExecutable["titleFactory"]
    
    if (titleFactory <> "") {
        return %titleFactory%(previousInputs)
    } else if (title <> "") {
        return title
    } else {
        return DefaultTitleFactory(previousInputs, currentExecutable)
    }
}

DefaultTitleFactory(previousCommands, currentExecutable) {
    if (previousCommands == "" || previousCommands.Length == 0) {
        return "¯\_(ツ)_/¯"
    }
    lastIndex := previousCommands.MaxIndex()
    for index, previousCommand in previousCommands
        title := title "->" previousCommand["input"]
    return title    

}

RunCommand(input) {
    global currentExecutable
    return currentExecutable.Execute(input)
}