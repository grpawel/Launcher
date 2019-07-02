ResetCommands() {
    global Commands
    global currentList := Commands
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
    return currentList.Execute(input)
}