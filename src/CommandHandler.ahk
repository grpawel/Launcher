ResetCommands() {
    global Commands
    global currentList := Commands["topLevel"]
    global previousInputs := []
}

Initialize() {
    global previousInputs := []
}

GetTitle() {
    global currentList
    global previousInputs
    title := currentList["title"]
    titleFactory := currentList["titleFactory"]
    
    if (titleFactory <> "") {
        return %titleFactory%(previousInputs)
    } else if (title <> "") {
        return title
    } else {
        return DefaultTitleFactory(previousInputs, currentList)
    }
}

DefaultTitleFactory(previousCommands, currentList) {
    if (previousCommands == "" || previousCommands.Length == 0) {
        return "¯\_(ツ)_/¯"
    }
    lastIndex := previousCommands.MaxIndex()
    for index, previousCommand in previousCommands
        title := title "->" previousCommand["input"]
    return title    

}

RunCommand(input) {
    global currentList
    global previousInputs
    commands := currentList["commands"]
    if (commands.HasKey(input)) {
        command := commands[input]
        action := command[1]
        param := command[2]
        previousInputs.Push({input: input, action: action, param: param})
        result := %action%(param)
        if (result == "") {
            return [true, "found"]
        }
        return result
    }
    return [false, "not found"]
}