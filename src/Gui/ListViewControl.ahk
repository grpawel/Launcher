class ListViewControl {
    __New(gui, name, options) {
        this._gui := gui
        this._controlName := name
        this._options := options
    }

    Show() {
        global
        local guiName := this._gui.GetName()
        local controlName := this._controlName
        local style := this._options.style
        local doubleClickHandler := this._OnRowDoubleClicked.Bind(this)
        try {
            ; initial height must be 0, 
            ; because next input positions itself using previous control initial position ignoring further of changes
            ; so adding next input creates empty space where listview is hidden, even if listview height is changed to 0
            ; TODO: remove margin around
            Gui, %guiName%: Default
            colorBackground := this._options.backgroundColor
            colorCurrentLine := this._options.currentLineColor
            Gui, %guiName%: Color, %colorBackground%, %colorCurrentLine%
            Gui, %guiName%: Add, ListView, h0 -Hdr %style% v%controlName%, Command|Title
            GuiControl, %guiName%: +g, %controlName%, %doubleClickHandler%
            LV_ModifyCol()
        } catch e {
            GuiControl, %guiName%: Show, %controlName%
        }
        GuiControl, %guiName%: Move, %controlName%, h150
        Gui, %guiName%: Show, AutoSize
    }

    Populate(rows) {
        for index, row in rows {
            LV_Add("", row[1], row[2])
        }
        LV_ModifyCol()
    }

    RemoveRows() {
        LV_Delete()
    }

    Hide() {
        guiName := this._gui.GetName()
        controlName := this._controlName
        GuiControl, %guiName%: Hide, %controlName%
        Gui, %guiName%: Show, AutoSize
    }

    Disable() {
        this.Hide()
    }

    _OnRowDoubleClicked() {
        if (A_GuiEvent == "DoubleClick") {
            LV_GetText(rowText, A_EventInfo)
        }
    }
}
