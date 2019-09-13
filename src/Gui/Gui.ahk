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
    static _nextName := 2
    _options := { style: "xm w220 " . (Colors.foreground) . " -E0x200"
                , backgroundColor: Colors.background
                , currentLineColor: Colors.currentLine}

    __New() {
        this._name := Gui._nextName
        Gui._nextName += 1
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
        name := this._name
        Gui, %name%: Margin, 16, 16
        colorBackground := this._options.backgroundColor
        colorCurrentLine := this._options.currentLineColor
        Gui, %name%: Color, %colorBackground%, %colorCurrentLine%
        Gui, %name%: +AlwaysOnTop -SysMenu +ToolWindow -caption +Border
        Gui, %name%: Font, s10, Segoe UI
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
    ; title (string) - will be shown above input
    AddTextInput(options = "") {
        mergedOptions := MergeArrays(this._options, options)
        control := new TextInput(this, this._nextControlName, mergedOptions)
        control.Show(this._nextControlName)
        this._nextControlName += 1

        this._controls.Push(control)
        return control
    }

    AddListView() {
        control := new ListViewControl(this, this._nextControlName, this._options)
        control.Show(this._nextControlName)
        this._controls.Push(control)
        this._nextControlName += 1
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
