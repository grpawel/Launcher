class TextInput {
    _isSetup := false
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
        local keyPressHandler := this._OnKeyPressed.Bind(this)
        local returnPressHandler := this._OnReturnPressed.Bind(this)
        Gui, %guiName%: Add, Edit, %style% v%controlName% -WantReturn
        GuiControl, %guiName%: +g, %controlName%, %keyPressHandler%
        Gui, %guiName%: Add, Button, x-10 y-10 w1 h1 v%controlName%Button +default
        GuiControl, %guiName%: +g, %controlName%Button, %returnPressHandler%
        return
    }

    _OnKeyPressed() {
        controlName := this._controlName
        GuiControlGet, value,, %controlName%
        global globalEventBus
        globalEventBus.Emit("keyPressed", value)
    }

    _OnReturnPressed() {
        controlName := this._controlName
        GuiControlGet, value,, %controlName%
        global globalEventBus
        globalEventBus.Emit("returnPressed", value)
    }

    SetText(value) {
        controlName := this._controlName
        guiName := this._gui.GetName()
        GuiControl, %guiName%: Text, %controlName%, %value%
        this._OnKeyPressed()
    }

    Disable() {
        global
        local guiName := this._gui.GetName()
        local controlName := this._controlName
        GuiControl, %guiName%: Disable, %controlName%
        GuiControl, %guiName%: Disable, %controlName%Button
        GuiControl, %guiName%: -g, %controlName%
        GuiControl, %guiName%: -g, %controlName%Button
    }
}
