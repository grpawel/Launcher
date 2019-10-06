#Include %A_ScriptDir%\src\Events\EventBus.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Gui\ListViewControl.ahk
#Include %A_ScriptDir%\src\Gui\TextInput.ahk
#Include %A_ScriptDir%\src\Gui\TextView.ahk

class Gui {
    _state := "closed"
    _nextControlName := 0
    _controls := []
    _eventBus := new EventBus()
    _isSetup := false
    static _nextName := 1
    static DEFAULT_OPTIONS := { width: "220"
                , textColor: Colors.LIGHT_GRAY
                , windowColor: Colors.ALMOST_BLACK
                , controlColor: Colors.DARK_GRAY }

    static guiList := []


    ; Options common for all controls:
    ; width (int) - width of control in px
    ; textColor (string)
    ; windowColor (string) - background color of GUI window
    ; controlColor (string) - background color of controls
    __New(options = "") {
        this._name := Gui._nextName
        Gui._nextName += 1
        Gui.guiList[this._name] := this
        this._options := MergeArrays(this.DEFAULT_OPTIONS, options)
    }

    AddTextInput(options = "") {
        return this._AddControl("TextInput", options)
    }

    AddListView(options = "") {
        return this._AddControl("ListViewControl", options)
    }

    ; Options:
    ; text (string) - text to show
    AddText(options := "") {
        return this._AddControl("TextView", options)
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
        local windowColor := "c" . this._options.windowColor
        local controlColor := "c" . this._options.controlColor
        Gui, %name%: Color, %windowColor%, %controlColor%
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
        Gui, %name%: Destroy
        this._nextControlName := 0
        this._DestroyControls(this._controls)
        this._controls := []
        this._eventBus.Emit("guiClosing") 
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
