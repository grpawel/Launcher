; Show window separate from gui containing `argument`
InWindowShower(env, setting, argument) {
    local guiName := RandomAzString(5)
    local controlName := RandomAzString(2)

    ; Clip height to max size
    rows := CountOccurences(argument, "`n")
    rows += 2 ; Space for scroll bar
    rows := EnsureBetween(rows, 2, 30)

    Gui, %guiName%: Font, s10, Consolas
    Gui, %guiName%: Add, Edit, v%controlName% Multi ReadOnly -Wrap HScroll r%rows%, %argument%

    ; Clip window to max size
	GuiControlGet, size, %guiName%: Pos, %controlName%
    sizeW += 10
	sizeW := EnsureBetween(sizeW, 200, 700)
	GuiControl, %guiName%: Move, %controlName%, w%sizeW%

    Gui, %guiName%: Show, AutoSize
}
