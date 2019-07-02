open(param) {
    run, %param%
}

reload(param) {
    Reload
}

enter(param) {
    global currentList
    global Commands
    currentList := Commands[param]
    GuiAddInput()
    return
}