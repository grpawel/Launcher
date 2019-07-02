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
    GuiResetInput()
    return [false, "next command"]
}