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