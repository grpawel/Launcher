#Include %A_ScriptDir%\src\Events\EventBus.ahk
#Include %A_ScriptDir%\src\Utils\StringUtils.ahk

class TextInput {
    _isSetup := false
    _eventBus := new EventBus()
    _doNotEmitEventsOnThisValue := {}

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
    }

    _Setup() {
        local guiName := this._gui.GetName()
        local controlName := this._controlName
        local style := this._GetStyle(this._options)
        local keyPressHandler := this._OnKeyPressed.Bind(this)
        local returnPressHandler := this._OnReturnPressed.Bind(this)
        Gui, %guiName%: Add, Edit, %style% v%controlName% -WantReturn
        GuiControl, %guiName%: +g, %controlName%, %keyPressHandler%
        Gui, %guiName%: Margin, 15, 15
        return
    }

    _GetStyle(options) {
        return Join([ " -E0x200" ; no borders
                    , "xm"
                    , "w" . options.width
                    , "c" . options.textColor ]
                , " ")
    }

    ; Payload: input text (string)
    SubscribeInputChanged(subscriber, options = "") {
        return this._eventBus.Subscribe("inputChanged", subscriber, options)
    }

    ; Payload: input text (string)
    SubscribeReturnPressed(subscriber, options = "") {
        return this._eventBus.Subscribe("returnPressed", subscriber, options)
    }

    ; Payload is empty
    SubscribeDestroyed(subscriber, options = "") {
        return this._eventBus.Subscribe("destroyed", subscriber, options)
    }

    ; Payload is empty
    SubscribeDisabled(subscriber, options = "") {
        return this._eventBus.Subscribe("disabled", subscriber, options)
    }

    NotifyReturnPressed() {
        this._OnReturnPressed()
    }

    _OnKeyPressed() {
        controlName := this._controlName
        GuiControlGet, value,, %controlName%
        if (this._doNotEmitEventsOnThisValue == value) {
            this._doNotEmitEventsOnThisValue := {}
        } else {
            this._eventBus.Emit("inputChanged", value)
        }
    }

    _OnReturnPressed() {
        controlName := this._controlName
        GuiControlGet, value,, %controlName%
        this._eventBus.Emit("returnPressed", value)
    }

    ; Options:
    ; "noEvents": boolean (default false) - Do not emit "inputChanged" event
    SetText(value, options = "") {
        controlName := this._controlName
        guiName := this._gui.GetName()
        if (options.noEvents) {
            ; As it turns out vlabels are not reliable.
            ; Sometimes when using this method `_OnKeyPressed` is not called.
            this._doNotEmitEventsOnThisValue := value
        }
        GuiControl, %guiName%: Text, %controlName%, %value%
    }

    GetText() {
        guiName := this._gui.GetName()
        controlName := this._controlName
        GuiControlGet, value,, %controlName%
        return value
    }

    Disable() {
        global
        local guiName := this._gui.GetName()
        local controlName := this._controlName
        GuiControl, %guiName%: Disable, %controlName%
        GuiControl, %guiName%: -g, %controlName%
        this._eventBus.Emit("disabled")
    }

    Destroy() {
        ; Break circular references (https://www.autohotkey.com/docs/Objects.htm#Circular_References).
        this._eventBus.Emit("destroyed")
        this._eventBus.UnsubscribeAll()
        this._gui := ""
        this._eventBus := ""
    }
}
