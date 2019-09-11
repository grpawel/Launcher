#Include %A_ScriptDir%\src\Gui\TextInput.ahk
#Include %A_ScriptDir%\src\Gui\ListViewControl.ahk
#Include %A_ScriptDir%\src\Gui\Colors.ahk

class Gui {
    _state := "closed"
    _nextControlName := 0
    _controls := []
    static _nextName := 2
    _options := { style: "xm w220 " . (Colors.foreground) . " -E0x200"
                , backgroundColor: Colors.background
                , currentLineColor: Colors.currentLine}

    __New() {
        this._name := Gui._nextName
        Gui._nextName += 1
    }

    Show() { 
        this._state := "opened"
        name := this._name
        Gui, %name%: Margin, 16, 16
        colorBackground := this._options.backgroundColor
        colorCurrentLine := this._options.currentLineColor
        Gui, %name%: Color, %colorBackground%, %colorCurrentLine%
        Gui, %name%: +AlwaysOnTop -SysMenu +ToolWindow -caption +Border
        Gui, %name%: Font, s10, Segoe UI
        Gui, %name%: Show,, %name%
    }

    Hide() {
        this._state := "closed"
        name := this._name
        Gui, %name%: Destroy
        #WinActivateForce
        WinActivate
    }

    ToggleVisibility() {
        if (this._state == "closed") {
            this.Show()
        } else {
            this.Hide()
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
}
