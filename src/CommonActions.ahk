open(param) {
    run, %param%
}

reload(param) {
    Reload
}

enter(param) {
    global currentList
    currentList := param
    GuiResetInput()
    return [false, "next command"]
}
