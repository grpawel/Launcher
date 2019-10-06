#Include %A_ScriptDir%\src\Commands\Command.ahk

class RunOtherScript extends Command {
    ; command = "open" | "close" | "toggle"
    __New(command, name = "", path = "") {
        this._command := command
        this._name := name
        this._path := path
        this._description := command " " name " script"
    }

    Run(mainController) {
        if (this._command == "open") {
            this._Open()
        } else if (this._command == "close") {
            this._Close()
        } else if (this._command == "toggle") {
            this._Toggle()
        }
    }

    _Toggle() {
        if (this._IsScriptRunning()) {
            this._Close()
        } else {
            this._Open()
        }
    }

    _Open() {
        path := this._path
        Run, %path%
    }

    _Close() {
        DetectHiddenWindows On
        SetTitleMatchMode RegEx
        name := this._name
        IfWinExist, i)%name%.* ahk_class AutoHotkey
        {
            WinClose
            WinWaitClose, i)%name%.* ahk_class AutoHotkey, , 2
            if (ErrorLevel) {
                MsgBox Unable to close %name%, error:%ErrorLevel%
                return false
            } else
                return true
        } else {
            MsgBox, script %name% not found
            return false
        }
    }

    _IsScriptRunning() {
        DetectHiddenWindows, On
        SetTitleMatchMode, 2
        ;SetTitleMatchMode, Slow
        name := this._name
        IfWinExist, %name%
        {
            return true
        }
        return false
    }
}
