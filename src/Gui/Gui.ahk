#Include %A_ScriptDir%\src\Gui\TextInput.ahk
#Include %A_ScriptDir%\src\Gui\ListViewControl.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Events\EventBus.ahk

class Gui {
    _state := "closed"
    _nextControlName := 0
    _controls := []
    _eventBus := new EventBus()
    _isSetup := false
    static _nextName := 1
    _options := { style: "xm w220 " . (Colors.foreground) . " -E0x200"
                , backgroundColor: Colors.background
                , currentLineColor: Colors.currentLine}

    static guiList := []

    __New() {
        this._name := Gui._nextName
        Gui._nextName += 1
        Gui.guiList[this._name] := this
    }

    Show() { 
        this._eventBus.Emit("guiShowing")
        this._state := "opened"
        if (!this._isSetup) {
            this._Setup()
            this._isSetup := true
        }
        name := this._name
        Gui, %name%: Show,, %name%
    }

    _Setup() {
        local name := this._name
        Gui, %name%: Margin, 16, 16
        local colorBackground := this._options.backgroundColor
        local colorCurrentLine := this._options.currentLineColor
        Gui, %name%: Color, %colorBackground%, %colorCurrentLine%
        Gui, %name%: +AlwaysOnTop -SysMenu +ToolWindow -caption +Border
        Gui, %name%: Font, s10, Segoe UI
        ; Button is common for all controls. This allows selecting rows by using Return key.
        Gui, %name%: Add, Button, x-10 y-10 w1 h1 vDefaultButton +default -Tabstop
        local returnPressHandler := this._OnReturnPressed.Bind(this)
        GuiControl, %name%: +g, DefaultButton, %returnPressHandler%
    }

    _OnReturnPressed() {
        focusedControl := this._FindFocusedControl()
        focusedControl.NotifyReturnPressed()
    }

    _FindFocusedControl() {
        name := this._name
        GuiControlGet, focusedControlName, %name%:FocusV
        return this._controls[focusedControlName]
    }

    Hide() {
        this._state := "hidden"
        name := this._name
        Gui, %name%: Hide
    }

    Destroy() {
        this._state := "closed"
        this._isSetup := false
        name := this._name
        this._eventBus.Emit("guiClosing") 
        Gui, %name%: Destroy
        this._nextControlName := 0
        this._DestroyControls(this._controls)
        this._controls := []
        #WinActivateForce
        WinActivate
    }

    _DestroyControls(controls) {
        for i, control in controls {
            control.Destroy()
        }
    }

    ToggleWindow() {
        if (this._state == "closed" || this._state == "hidden") {
            this.Show()
        } else {
            this.Destroy()
        }
    }

    IsVisible() {
        return this._state == "opened"
    }

    ; Options:
    ; header (string) - will be shown above input
    AddTextInput(options = "") {
        return this._AddControl("TextInput", options)
    }

    AddListView() {
        return this._AddControl("ListViewControl")
    }

    _AddControl(controlClassName, options = "") {
        mergedOptions := MergeArrays(this._options, options)
        controlName := this._nextControlName
        this._nextControlName += 1
        control := new %controlClassName%(this, controlName, mergedOptions)
        control.Show()
        this._controls[controlName] := control
        return control
    }

    DisableAll() {
        for i, control in this._controls {
            control.Disable()
        }
    }

    GetName() {
        name := this._name
        return this._name
    }

    SubscribeGuiShowing(subscriber, duration = "everytime") {
        return this._eventBus.Subscribe("guiShowing", subscriber, duration)
    }

    SubscribeGuiClosing(subscriber, duration = "everytime") {
        return this._eventBus.Subscribe("guiClosing", subscriber, duration)
    }
}
