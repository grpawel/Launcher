ResetCommands() {
    global Commands
    global currentList := Commands["topLevel"]

}

GetTitle() {
    global currentList
    title := currentList["title"]
    if (title == "") {
        title := "¯\_(ツ)_/¯"
    }
    return title
}

RunCommand(input) {
    global currentList
    commands := currentList["commands"]
    if (commands.HasKey(input)) {
        command := commands[input]
        action := command[1]
        param := command[2]
        result := %action%(param)
        if (result == "") {
            return [true, "found"]
        }
        return result
    }
    return [false, "not found"]
}

