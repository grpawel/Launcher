ShowInWindow(env, setting, argument) {
    guiName := RandomAzString(5)
    Gui, %guiName%: Add, Edit, r4 w300, %setting% `n %argument%
    Gui, %guiName%: Font, s12, Segoe UI
    Gui, %guiName%: Show, AutoSize
}
