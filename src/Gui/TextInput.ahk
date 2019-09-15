#Include %A_ScriptDir%\src\Events\EventBus.ahk

class TextInput {
    _isSetup := false
    _eventBus := new EventBus()

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
        GuiControl, %guiName%: Enable, %controlName%
        GuiControl, %guiName%: Focus, %controlName%
        Gui, %guiName%: Show, AutoSize
    }

    _Setup() {
        local guiName := this._gui.GetName()
        local controlName := this._controlName
        local style := this._options.style
        local keyPressHandler := this._OnKeyPressed.Bind(this)
        local returnPressHandler := this._OnReturnPressed.Bind(this)
        if (this._options.header != "") {
            header := this._options.header
            Gui, %guiName%: Add, Text, %style% v%controlName%Header, %header%
        }
        Gui, %guiName%: Add, Edit, %style% v%controlName% -WantReturn
        GuiControl, %guiName%: +g, %controlName%, %keyPressHandler%
        return
    }

    SubscribeInputChanged(subscriber, duration = "everytime") {
        return this._eventBus.Subscribe("inputChanged", subscriber, duration)
    }

    SubscribeReturnPressed(subscriber, duration = "everytime") {
        return this._eventBus.Subscribe("returnPressed", subscriber, duration)
    }

    NotifyReturnPressed() {
        this._OnReturnPressed()
    }

    _OnKeyPressed() {
        controlName := this._controlName
        GuiControlGet, value,, %controlName%
        this._eventBus.Emit("inputChanged", value)
    }

    _OnReturnPressed() {
        controlName := this._controlName
        GuiControlGet, value,, %controlName%
        this._eventBus.Emit("returnPressed", value)
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
        GuiControl, %guiName%: Disable, %controlName%Header
        GuiControl, %guiName%: -g, %controlName%
    }

    Destroy() {
        ; Break circular references (https://www.autohotkey.com/docs/Objects.htm#Circular_References).
        this._gui := ""
        this._eventBus := ""
    }
}
