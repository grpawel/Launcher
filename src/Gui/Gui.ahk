#Include %A_ScriptDir%\src\Events\EventBus.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk
#Include %A_ScriptDir%\src\Gui\ListViewControl.ahk
#Include %A_ScriptDir%\src\Gui\TextInput.ahk
#Include %A_ScriptDir%\src\Gui\TextView.ahk

class Gui {
    _state := "destroyed"
    _nextControlName := 0
    _controls := []
    _eventBus := new EventBus()
    _isSetup := false
    static _nextName := 1

    static guiList := []


    ; Options common for all controls:
    ; width (int) - width of control in px
    ; textColor (string)
    ; windowColor (string) - background color of GUI window
    ; controlColor (string) - background color of controls
    ; Options for window:
    ; position.x (int) - x position of window in px, default is middle of the screen
    ; position.y (int) - y position of window in px, default is middle of the screen
    __New(options = "") {
        this._name := Gui._nextName
        Gui._nextName += 1
        Gui.guiList[this._name] := this
        this._options := this._GetGlobalOptions(options)
    }

    _GetGlobalOptions(options) {
        static DEFAULT_OPTIONS := { width: "220"
                , textColor: Colors.LIGHT_GRAY
                , windowColor: Colors.ALMOST_BLACK
                , controlColor: Colors.DARK_GRAY }
        static V := new ValidatorFactory()
        static VAL := V.Object({ "width": V.PositiveInt()
                               , "textColor": V.String()
                               , "windowColor": V.String()
                               , "controlColor": V.String()
                               , "position": V.Object({ "x": V.Integer()
                                                      , "y": V.Integer() }
                                                     , { allowMissingKeys: true }) }
                            , { allowMissingKeys: true })
        options := MergeArrays(DEFAULT_OPTIONS, options)
        VAL.ValidateAndShow(options)
        return options
    }

    AddTextInput(options = "") {
        return this._AddControl("TextInput", options)
    }

    ; Options:
    ; position ("right"|"normal") - where to put control
    AddListView(options = "") {
        return this._AddControl("ListViewControl", options)
    }

    ; Options:
    ; text (string) - text to show
    ; textColorDisabled (string) - text color when disabled. If not specified, text is grayed out by AHK.
    AddText(options := "") {
        return this._AddControl("TextView", options)
    }

    _AddControl(controlClassName, options = "") {
        if (!this._isSetup) {
            this._Setup()
            this._isSetup := true
        }
        mergedOptions := MergeArrays(this._options, options)
        controlName := this._nextControlName
        this._nextControlName += 1
        control := new %controlClassName%(this, controlName, mergedOptions)
        control.Show()
        this._controls[controlName] := control
        return control
    }

    Show() { 
        this._state := "opened"
        if (!this._isSetup) {
            this._Setup()
            this._isSetup := true
        }
        name := this._name
        style := this._GetShowOptionsString(this._options)
        Gui, %name%: Show, AutoSize %style%, %name%
    }

    _GetShowOptionsString(options) {
        style := ""
        if (options.position.x != "") {
            style .= " x" options.position.x
        }
        if (options.position.y != "") {
            style .= " y" options.position.y
        }
        return style
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
        this._eventBus.Emit("returnPressed", focusedControl, focusedControl._controlName)
        focusedControl.NotifyReturnPressed()
    }

    _FindFocusedControl() {
        name := this._name
        GuiControlGet, focusedControlName, %name%:FocusV
        return this._controls[focusedControlName]
    }

    ; Payload: `focusedControl, name`
    ; name - name of focused control
    SubscribeReturnPressed(subscriber, options = "") {
        return this._eventBus.Subscribe("returnPressed", subscriber, options)
    }

    Hide() {
        this._state := "hidden"
        name := this._name
        Gui, %name%: Hide
    }

    Destroy() {
        this._Destroy()
        this._eventBus.Emit("guiDestroyed")
    }

    Reset() {
        this._Destroy()
    }

    _Destroy() {
        this._state := "destroyed"
        this._isSetup := false
        name := this._name
        Gui, %name%: Destroy
        this._nextControlName := 0
        this._DestroyControls(this._controls)
        this._controls := []
    }

    _DestroyControls(controls) {
        for i, control in controls {
            control.Destroy()
        }
    }

    IsVisible() {
        return this._state == "opened"
    }

    GetName() {
        name := this._name
        return this._name
    }

    ; Payload is empty
    SubscribeGuiDestroyed(subscriber, options = "") {
        return this._eventBus.Subscribe("guiDestroyed", subscriber, options)
    }
}
