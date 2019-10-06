#Include %A_ScriptDir%\src\Events\EventBus.ahk

class TextView {
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
        Gui, %guiName%: Show, AutoSize
    }

    _Setup() {
        local guiName := this._gui.GetName()
        local controlName := this._controlName
        textColor := this._options.textColor
        ;Gui, %guiName%: Font, c%textColor%
        text := this._options.text
        local style := this._options.style
        Gui, %guiName%: Add, Text, xm %style% v%controlName%, %text%
        return
    }

    SetText(value) {
        controlName := this._controlName
        guiName := this._gui.GetName()
        GuiControl, %guiName%: Text, %controlName%, %value%
    }

    Disable() {
        global
        local guiName := this._gui.GetName()
        local controlName := this._controlName
        GuiControl, %guiName%: Disable, %controlName%
    }
}
