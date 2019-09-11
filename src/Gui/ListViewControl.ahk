class ListViewControl {
    _isSetup := false

    __New(gui, name, options) {
        this._gui := gui
        this._controlName := name
        this._options := options
    }

    Show() {
        if (!this._isSetup) {
            this._Setup()
            this._isSetup := true
        }
        guiName := this._gui.GetName()
        controlName := this._controlName
        GuiControl, %guiName%: Show, %controlName%
        Gui, %guiName%: Show, AutoSize
    }

    _Setup() {
        local guiName := this._gui.GetName()
        local controlName := this._controlName
        local style := this._options.style
        local doubleClickHandler := this._OnRowDoubleClicked.Bind(this)
        
        Gui, %guiName%: Default
        colorBackground := this._options.backgroundColor
        colorCurrentLine := this._options.currentLineColor
        Gui, %guiName%: Color, %colorBackground%, %colorCurrentLine%
        ; Initial height must be 0, 
        ; because next input position is calculated
        ; using previous control initial position, ignoring further changes.
        ; TODO: remove margin around
        Gui, %guiName%: Add, ListView, h0 -Hdr %style% v%controlName%, Command|Title
        GuiControl, %guiName%: +g, %controlName%, %doubleClickHandler%
        LV_ModifyCol()
        GuiControl, %guiName%: Move, %controlName%, h150
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
